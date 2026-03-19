package com.emops.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "habits")
data class HabitEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val name: String,
    val description: String?,
    val category: String,
    val frequency: String,
    val customDaysJson: String?,
    val targetValue: Double?,
    val targetUnit: String?,
    val reminderTime: String?,
    val reminderEnabled: Boolean,
    val streakCurrent: Int,
    val streakBest: Int,
    val isActive: Boolean,
    val sortOrder: Int
)
