package com.emops.app.data.remote.dto

import com.google.gson.annotations.SerializedName

data class LoginRequest(
    val email: String,
    val password: String
)

data class RegisterRequest(
    val email: String,
    val password: String,
    @SerializedName("display_name") val displayName: String,
    val timezone: String = "Indian/Maldives"
)

data class AuthResponseDto(
    val token: String,
    @SerializedName("refresh_token") val refreshToken: String,
    val user: UserDto
)

data class UserDto(
    val id: String,
    val email: String,
    @SerializedName("display_name") val displayName: String,
    val timezone: String,
    val role: String,
    val surfaces: List<String>,
    @SerializedName("dsaa_trigger_time") val dsaaTriggerTime: String?,
    @SerializedName("dsaa_trigger_event") val dsaaTriggerEvent: String?,
    @SerializedName("deep_work_hours_target") val deepWorkHoursTarget: Double?
)

data class RefreshRequest(
    @SerializedName("refresh_token") val refreshToken: String
)

data class PushTokenRequest(
    @SerializedName("push_token") val pushToken: String,
    val platform: String = "android"
)

data class ProfileUpdateRequest(
    @SerializedName("display_name") val displayName: String? = null,
    val timezone: String? = null,
    @SerializedName("notification_preferences") val notificationPreferences: Map<String, Boolean>? = null,
    @SerializedName("dsaa_trigger_time") val dsaaTriggerTime: String? = null,
    @SerializedName("deep_work_hours_target") val deepWorkHoursTarget: Double? = null
)

data class WeeklySheetDto(
    val id: String,
    @SerializedName("user_id") val userId: String,
    @SerializedName("week_start") val weekStart: String,
    @SerializedName("week_label") val weekLabel: String?,
    val status: String,
    @SerializedName("surfaces_in_scope") val surfacesInScope: List<String>?,
    @SerializedName("oncall_ownership") val oncallOwnership: String?,
    @SerializedName("key_dependencies") val keyDependencies: String?,
    @SerializedName("non_negotiable_constraints") val nonNegotiableConstraints: String?,
    @SerializedName("constraint_statement") val constraintStatement: String?,
    @SerializedName("constraint_error_budget_status") val constraintErrorBudgetStatus: String?,
    @SerializedName("dsaa_focus_this_week") val dsaaFocusThisWeek: String?,
    @SerializedName("dsaa_queue") val dsaaQueue: Map<String, List<String>>?,
    @SerializedName("ai_tasks") val aiTasks: List<Map<String, Any>>?,
    @SerializedName("time_blocks") val timeBlocks: Map<String, Map<String, String>>?,
    @SerializedName("incident_checklist") val incidentChecklist: Map<String, Boolean>?,
    @SerializedName("adr_checklist") val adrChecklist: Map<String, Boolean>?,
    val scorecard: Map<String, Any>?,
    @SerializedName("ai_weekly_summary") val aiWeeklySummary: String?,
    @SerializedName("ai_coaching_notes") val aiCoachingNotes: String?,
    val outcomes: List<OutcomeDto>?,
    val decisions: List<DecisionDto>?,
    @SerializedName("created_at") val createdAt: String?,
    @SerializedName("updated_at") val updatedAt: String?,
    @SerializedName("completed_at") val completedAt: String?
)

data class OutcomeDto(
    val id: String,
    @SerializedName("sheet_id") val sheetId: String?,
    val position: Int,
    @SerializedName("outcome_text") val outcomeText: String,
    val impact: String?,
    @SerializedName("definition_of_done") val definitionOfDone: String?,
    val owner: String?,
    @SerializedName("risk_and_mitigation") val riskAndMitigation: String?,
    val status: String,
    @SerializedName("completed_at") val completedAt: String?
)

data class DecisionDto(
    val id: String,
    @SerializedName("sheet_id") val sheetId: String?,
    val position: Int,
    @SerializedName("decision_text") val decisionText: String,
    @SerializedName("by_when") val byWhen: String?,
    @SerializedName("inputs_needed") val inputsNeeded: String?,
    val status: String,
    @SerializedName("decision_result") val decisionResult: String?
)

data class HabitDto(
    val id: String,
    @SerializedName("user_id") val userId: String,
    val name: String,
    val description: String?,
    val category: String,
    val frequency: String,
    @SerializedName("custom_days") val customDays: List<String>?,
    @SerializedName("target_value") val targetValue: Double?,
    @SerializedName("target_unit") val targetUnit: String?,
    @SerializedName("reminder_time") val reminderTime: String?,
    @SerializedName("reminder_enabled") val reminderEnabled: Boolean,
    @SerializedName("streak_current") val streakCurrent: Int,
    @SerializedName("streak_best") val streakBest: Int,
    @SerializedName("is_active") val isActive: Boolean,
    @SerializedName("sort_order") val sortOrder: Int
)

data class HabitLogDto(
    val id: String,
    @SerializedName("habit_id") val habitId: String,
    @SerializedName("user_id") val userId: String,
    @SerializedName("log_date") val logDate: String,
    val value: Double?,
    @SerializedName("is_completed") val isCompleted: Boolean,
    val notes: String?
)

data class CreateHabitLogRequest(
    @SerializedName("habit_id") val habitId: String,
    @SerializedName("log_date") val logDate: String,
    val value: Double? = null,
    @SerializedName("is_completed") val isCompleted: Boolean = true,
    val notes: String? = null
)

data class BulkHabitLogRequest(
    val logs: List<CreateHabitLogRequest>
)

data class DsaaLogDto(
    val id: String,
    @SerializedName("user_id") val userId: String,
    @SerializedName("sheet_id") val sheetId: String?,
    @SerializedName("log_date") val logDate: String,
    @SerializedName("friction_point") val frictionPoint: String,
    @SerializedName("dsaa_action") val dsaaAction: String,
    @SerializedName("micro_artifact_type") val microArtifactType: String?,
    @SerializedName("micro_artifact_description") val microArtifactDescription: String?,
    @SerializedName("expected_leverage") val expectedLeverage: String?,
    @SerializedName("started_at") val startedAt: String?,
    @SerializedName("completed_at") val completedAt: String?,
    @SerializedName("duration_minutes") val durationMinutes: Int?,
    @SerializedName("ai_suggested_action") val aiSuggestedAction: String?,
    @SerializedName("ai_suggestion_accepted") val aiSuggestionAccepted: Boolean?
)

data class CreateDsaaLogRequest(
    @SerializedName("friction_point") val frictionPoint: String,
    @SerializedName("dsaa_action") val dsaaAction: String,
    @SerializedName("micro_artifact_type") val microArtifactType: String? = null,
    @SerializedName("micro_artifact_description") val microArtifactDescription: String? = null,
    @SerializedName("expected_leverage") val expectedLeverage: String? = null,
    @SerializedName("duration_minutes") val durationMinutes: Int? = null,
    @SerializedName("ai_suggestion_accepted") val aiSuggestionAccepted: Boolean? = null
)

data class ReminderDto(
    val id: String,
    @SerializedName("user_id") val userId: String,
    val title: String,
    val body: String?,
    @SerializedName("reminder_type") val reminderType: String,
    @SerializedName("schedule_type") val scheduleType: String,
    @SerializedName("scheduled_time") val scheduledTime: String?,
    @SerializedName("scheduled_days") val scheduledDays: List<String>?,
    @SerializedName("scheduled_date") val scheduledDate: String?,
    @SerializedName("is_active") val isActive: Boolean
)

data class TrendDataDto(
    @SerializedName("week_start") val weekStart: String,
    @SerializedName("deep_work_hours_total") val deepWorkHoursTotal: Double?,
    @SerializedName("dsaa_rituals_completed") val dsaaRitualsCompleted: Int?,
    @SerializedName("habits_completion_rate") val habitsCompletionRate: Double?,
    @SerializedName("outcomes_completed") val outcomesCompleted: Int?,
    @SerializedName("outcomes_total") val outcomesTotal: Int?,
    @SerializedName("decisions_made") val decisionsMade: Int?,
    @SerializedName("decisions_total") val decisionsTotal: Int?,
    @SerializedName("error_budget_status") val errorBudgetStatus: String?,
    @SerializedName("streak_days") val streakDays: Int?,
    @SerializedName("ai_trend_insight") val aiTrendInsight: String?
)

data class DsaaSuggestionDto(
    @SerializedName("dsaa_action") val dsaaAction: String,
    @SerializedName("action_description") val actionDescription: String,
    @SerializedName("micro_artifact") val microArtifact: String,
    @SerializedName("team_message") val teamMessage: String,
    @SerializedName("expected_leverage") val expectedLeverage: String
)

data class AiInsightDto(
    val summary: String?,
    val wins: List<String>?,
    val blockers: List<String>?,
    @SerializedName("reliability_health") val reliabilityHealth: String?,
    @SerializedName("dsaa_rating") val dsaaRating: String?,
    val recommendation: String?,
    @SerializedName("coaching_note") val coachingNote: String?,
    @SerializedName("positive_trend") val positiveTrend: String?,
    @SerializedName("concerning_trend") val concerningTrend: String?,
    @SerializedName("hidden_pattern") val hiddenPattern: String?,
    val suggestion: String?
)

data class HabitSummaryDto(
    @SerializedName("total_habits") val totalHabits: Int,
    @SerializedName("completed_today") val completedToday: Int,
    @SerializedName("completion_rate") val completionRate: Double,
    @SerializedName("current_streak") val currentStreak: Int
)

data class DsaaStatsDto(
    @SerializedName("total_rituals") val totalRituals: Int,
    @SerializedName("current_streak") val currentStreak: Int,
    @SerializedName("category_distribution") val categoryDistribution: Map<String, Int>?,
    @SerializedName("avg_duration_minutes") val avgDurationMinutes: Double?
)
