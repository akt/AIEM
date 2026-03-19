package com.emops.app.data.repository

import com.emops.app.data.remote.ApiService
import com.emops.app.domain.model.Reminder
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ReminderRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getReminders(): Result<List<Reminder>> {
        return try {
            val response = apiService.getReminders()
            if (response.isSuccessful) {
                Result.success(response.body()!!.map {
                    Reminder(
                        id = it.id, userId = it.userId, title = it.title,
                        body = it.body ?: "", reminderType = it.reminderType,
                        scheduleType = it.scheduleType, scheduledTime = it.scheduledTime,
                        scheduledDays = it.scheduledDays, scheduledDate = it.scheduledDate,
                        isActive = it.isActive
                    )
                })
            } else {
                Result.failure(Exception("Failed to get reminders"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun setupDefaults(): Result<List<Reminder>> {
        return try {
            val response = apiService.setupDefaultReminders()
            if (response.isSuccessful) {
                Result.success(response.body()!!.map {
                    Reminder(
                        id = it.id, userId = it.userId, title = it.title,
                        body = it.body ?: "", reminderType = it.reminderType,
                        scheduleType = it.scheduleType, scheduledTime = it.scheduledTime,
                        scheduledDays = it.scheduledDays, scheduledDate = it.scheduledDate,
                        isActive = it.isActive
                    )
                })
            } else {
                Result.failure(Exception("Failed to setup defaults"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
