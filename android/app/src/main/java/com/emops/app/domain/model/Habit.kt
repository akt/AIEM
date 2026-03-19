package com.emops.app.domain.model

data class Habit(
    val id: String = "",
    val userId: String = "",
    val name: String = "",
    val description: String = "",
    val category: String = "",
    val frequency: String = "daily",
    val customDays: List<String>? = null,
    val targetValue: Double? = null,
    val targetUnit: String? = null,
    val reminderTime: String? = null,
    val reminderEnabled: Boolean = true,
    val streakCurrent: Int = 0,
    val streakBest: Int = 0,
    val isActive: Boolean = true,
    val sortOrder: Int = 0
)

data class HabitLog(
    val id: String = "",
    val habitId: String = "",
    val userId: String = "",
    val logDate: String = "",
    val value: Double? = null,
    val isCompleted: Boolean = false,
    val notes: String? = null
)
