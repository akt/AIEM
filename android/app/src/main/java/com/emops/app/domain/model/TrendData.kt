package com.emops.app.domain.model

data class TrendData(
    val weekStart: String = "",
    val deepWorkHoursTotal: Double = 0.0,
    val dsaaRitualsCompleted: Int = 0,
    val habitsCompletionRate: Double = 0.0,
    val outcomesCompleted: Int = 0,
    val outcomesTotal: Int = 0,
    val decisionsMAde: Int = 0,
    val decisionsTotal: Int = 0,
    val errorBudgetStatus: String = "",
    val streakDays: Int = 0,
    val aiTrendInsight: String? = null
)

data class Reminder(
    val id: String = "",
    val userId: String = "",
    val title: String = "",
    val body: String = "",
    val reminderType: String = "",
    val scheduleType: String = "",
    val scheduledTime: String? = null,
    val scheduledDays: List<String>? = null,
    val scheduledDate: String? = null,
    val isActive: Boolean = true
)

data class User(
    val id: String = "",
    val email: String = "",
    val displayName: String = "",
    val timezone: String = "Indian/Maldives",
    val role: String = "engineering_manager",
    val surfaces: List<String> = emptyList(),
    val dsaaTriggerTime: String = "09:00",
    val dsaaTriggerEvent: String = "morning standup",
    val deepWorkHoursTarget: Double = 1.5
)

data class AuthResponse(
    val token: String = "",
    val refreshToken: String = "",
    val user: User = User()
)
