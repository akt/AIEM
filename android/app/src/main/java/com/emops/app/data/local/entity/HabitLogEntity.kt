package com.emops.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "habit_logs")
data class HabitLogEntity(
    @PrimaryKey val id: String,
    val habitId: String,
    val userId: String,
    val logDate: String,
    val value: Double?,
    val isCompleted: Boolean,
    val notes: String?
)
