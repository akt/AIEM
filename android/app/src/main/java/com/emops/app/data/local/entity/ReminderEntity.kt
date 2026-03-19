package com.emops.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "reminders")
data class ReminderEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val title: String,
    val body: String?,
    val reminderType: String,
    val scheduleType: String,
    val scheduledTime: String?,
    val scheduledDaysJson: String?,
    val scheduledDate: String?,
    val isActive: Boolean
)
