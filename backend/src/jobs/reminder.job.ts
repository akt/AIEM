import { Worker, Job } from 'bullmq';
import { createConnection } from '../services/scheduler.service';
import { getDueReminders, markFired } from '../services/reminder.service';
import { sendPushNotification } from '../services/notification.service';

export function startReminderWorker(): Worker {
  const worker = new Worker(
    'reminders',
    async (job: Job) => {
      console.log('[ReminderJob] Checking for due reminders...');

      const dueReminders = await getDueReminders();

      for (const { reminder, user } of dueReminders) {
        try {
          await sendPushNotification(
            user.id as string,
            {
              android: user.pushTokenAndroid as string | null,
              ios: user.pushTokenIos as string | null,
            },
            {
              title: reminder.title as string,
              body: reminder.body as string,
              data: {
                reminderType: reminder.reminder_type as string,
                reminderId: reminder.id as string,
              },
            },
            reminder.id as string,
          );

          await markFired(reminder.id as string);
          console.log(`[ReminderJob] Fired: ${reminder.title}`);
        } catch (err) {
          console.error(`[ReminderJob] Failed for reminder ${reminder.id}:`, err);
        }
      }

      return { processed: dueReminders.length };
    },
    { connection: createConnection() },
  );

  worker.on('completed', (job) => {
    if (job.returnvalue?.processed > 0) {
      console.log(`[ReminderJob] Processed ${job.returnvalue.processed} reminders`);
    }
  });

  worker.on('failed', (job, err) => {
    console.error(`[ReminderJob] Failed:`, err.message);
  });

  return worker;
}
