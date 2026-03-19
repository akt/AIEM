import { v4 as uuid } from 'uuid';
import db from '../config/database';

// ── Push notification interfaces ────────────────────────────

interface PushPayload {
  title: string;
  body: string;
  data?: Record<string, string>;
}

interface SendResult {
  success: boolean;
  messageId?: string;
  error?: string;
}

// ── FCM (Firebase Cloud Messaging) — Android ────────────────

export async function sendFcmPush(token: string, payload: PushPayload): Promise<SendResult> {
  // In production, integrate with Firebase Admin SDK:
  //   import * as admin from 'firebase-admin';
  //   const message = { notification: { title, body }, data, token };
  //   const response = await admin.messaging().send(message);
  console.log(`[FCM] Sending to ${token.slice(0, 12)}...`, payload.title);
  return { success: true, messageId: `fcm_${uuid()}` };
}

// ── APNs (Apple Push Notification Service) — iOS ────────────

export async function sendApnsPush(token: string, payload: PushPayload): Promise<SendResult> {
  // In production, integrate with @parse/node-apn or HTTP/2 APNs:
  //   const notification = new apn.Notification();
  //   notification.alert = { title, body };
  //   const result = await apnProvider.send(notification, token);
  console.log(`[APNs] Sending to ${token.slice(0, 12)}...`, payload.title);
  return { success: true, messageId: `apns_${uuid()}` };
}

// ── Unified send ────────────────────────────────────────────

export async function sendPushNotification(
  userId: string,
  tokens: { android?: string | null; ios?: string | null },
  payload: PushPayload,
  reminderId?: string,
): Promise<void> {
  const results: { channel: string; result: SendResult }[] = [];

  if (tokens.android) {
    const result = await sendFcmPush(tokens.android, payload);
    results.push({ channel: 'push', result });
  }

  if (tokens.ios) {
    const result = await sendApnsPush(tokens.ios, payload);
    results.push({ channel: 'push', result });
  }

  // Always create an in-app notification
  results.push({ channel: 'in_app', result: { success: true } });

  // Log all notifications
  for (const { channel, result } of results) {
    await db('notification_log').insert({
      id: uuid(),
      user_id: userId,
      reminder_id: reminderId || null,
      title: payload.title,
      body: payload.body,
      channel,
      status: result.success ? 'sent' : 'failed',
      sent_at: db.fn.now(),
    });
  }
}

// ── Notification log queries ────────────────────────────────

export async function getNotifications(
  userId: string,
  opts: { limit?: number; offset?: number; channel?: string } = {},
) {
  const query = db('notification_log')
    .where({ user_id: userId })
    .orderBy('sent_at', 'desc')
    .limit(opts.limit || 50)
    .offset(opts.offset || 0);

  if (opts.channel) {
    query.where({ channel: opts.channel });
  }

  return query;
}

export async function markNotificationActioned(userId: string, notificationId: string) {
  const [row] = await db('notification_log')
    .where({ id: notificationId, user_id: userId })
    .update({ status: 'actioned', actioned_at: db.fn.now() })
    .returning('*');
  return row;
}

export async function getUnreadCount(userId: string): Promise<number> {
  const [{ count }] = await db('notification_log')
    .where({ user_id: userId, status: 'sent' })
    .count('id as count');
  return Number(count);
}
