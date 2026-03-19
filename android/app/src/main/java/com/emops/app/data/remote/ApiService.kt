package com.emops.app.data.remote

import com.emops.app.data.remote.dto.*
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    // === Auth ===
    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): Response<AuthResponseDto>

    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): Response<AuthResponseDto>

    @POST("auth/refresh")
    suspend fun refreshToken(@Body request: RefreshRequest): Response<AuthResponseDto>

    @PUT("auth/profile")
    suspend fun updateProfile(@Body request: ProfileUpdateRequest): Response<UserDto>

    @PUT("auth/push-token")
    suspend fun updatePushToken(@Body request: PushTokenRequest): Response<Unit>

    // === Weekly Sheets ===
    @GET("weekly-sheets")
    suspend fun getWeeklySheets(
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 20
    ): Response<List<WeeklySheetDto>>

    @GET("weekly-sheets/current")
    suspend fun getCurrentSheet(): Response<WeeklySheetDto>

    @GET("weekly-sheets/{id}")
    suspend fun getSheetById(@Path("id") id: String): Response<WeeklySheetDto>

    @POST("weekly-sheets")
    suspend fun createSheet(@Body body: Map<String, Any>): Response<WeeklySheetDto>

    @PUT("weekly-sheets/{id}")
    suspend fun updateSheet(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<WeeklySheetDto>

    @PUT("weekly-sheets/{id}/constraint")
    suspend fun updateConstraint(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<WeeklySheetDto>

    @PUT("weekly-sheets/{id}/dsaa-queue")
    suspend fun updateDsaaQueue(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<WeeklySheetDto>

    @PUT("weekly-sheets/{id}/ai-plan")
    suspend fun updateAiPlan(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<WeeklySheetDto>

    @PUT("weekly-sheets/{id}/time-blocks")
    suspend fun updateTimeBlocks(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<WeeklySheetDto>

    @PUT("weekly-sheets/{id}/incident")
    suspend fun updateIncidentChecklist(
        @Path("id") id: String,
        @Body body: Map<String, Boolean>
    ): Response<WeeklySheetDto>

    @PUT("weekly-sheets/{id}/adr")
    suspend fun updateAdrChecklist(
        @Path("id") id: String,
        @Body body: Map<String, Boolean>
    ): Response<WeeklySheetDto>

    @PUT("weekly-sheets/{id}/scorecard")
    suspend fun updateScorecard(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<WeeklySheetDto>

    @POST("weekly-sheets/{id}/complete")
    suspend fun completeSheet(@Path("id") id: String): Response<WeeklySheetDto>

    @POST("weekly-sheets/{id}/carry-forward")
    suspend fun carryForward(@Path("id") id: String): Response<WeeklySheetDto>

    // === Outcomes ===
    @GET("weekly-sheets/{sheetId}/outcomes")
    suspend fun getOutcomes(@Path("sheetId") sheetId: String): Response<List<OutcomeDto>>

    @POST("weekly-sheets/{sheetId}/outcomes")
    suspend fun createOutcome(
        @Path("sheetId") sheetId: String,
        @Body body: Map<String, Any>
    ): Response<OutcomeDto>

    @PUT("weekly-sheets/{sheetId}/outcomes/{id}")
    suspend fun updateOutcome(
        @Path("sheetId") sheetId: String,
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<OutcomeDto>

    @DELETE("weekly-sheets/{sheetId}/outcomes/{id}")
    suspend fun deleteOutcome(
        @Path("sheetId") sheetId: String,
        @Path("id") id: String
    ): Response<Unit>

    @PUT("weekly-sheets/{sheetId}/outcomes/{id}/status")
    suspend fun updateOutcomeStatus(
        @Path("sheetId") sheetId: String,
        @Path("id") id: String,
        @Body body: Map<String, String>
    ): Response<OutcomeDto>

    // === Decisions ===
    @GET("weekly-sheets/{sheetId}/decisions")
    suspend fun getDecisions(@Path("sheetId") sheetId: String): Response<List<DecisionDto>>

    @POST("weekly-sheets/{sheetId}/decisions")
    suspend fun createDecision(
        @Path("sheetId") sheetId: String,
        @Body body: Map<String, Any>
    ): Response<DecisionDto>

    @PUT("weekly-sheets/{sheetId}/decisions/{id}")
    suspend fun updateDecision(
        @Path("sheetId") sheetId: String,
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<DecisionDto>

    @PUT("weekly-sheets/{sheetId}/decisions/{id}/resolve")
    suspend fun resolveDecision(
        @Path("sheetId") sheetId: String,
        @Path("id") id: String,
        @Body body: Map<String, String>
    ): Response<DecisionDto>

    // === Habits ===
    @GET("habits")
    suspend fun getHabits(): Response<List<HabitDto>>

    @POST("habits")
    suspend fun createHabit(@Body body: Map<String, Any>): Response<HabitDto>

    @PUT("habits/{id}")
    suspend fun updateHabit(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<HabitDto>

    @DELETE("habits/{id}")
    suspend fun deleteHabit(@Path("id") id: String): Response<Unit>

    @PUT("habits/reorder")
    suspend fun reorderHabits(@Body body: Map<String, List<Map<String, Any>>>): Response<Unit>

    @GET("habits/{id}/stats")
    suspend fun getHabitStats(@Path("id") id: String): Response<Map<String, Any>>

    // === Habit Logs ===
    @GET("habit-logs")
    suspend fun getHabitLogs(
        @Query("date") date: String? = null,
        @Query("from") from: String? = null,
        @Query("to") to: String? = null
    ): Response<List<HabitLogDto>>

    @POST("habit-logs")
    suspend fun createHabitLog(@Body request: CreateHabitLogRequest): Response<HabitLogDto>

    @PUT("habit-logs/{id}")
    suspend fun updateHabitLog(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<HabitLogDto>

    @POST("habit-logs/bulk")
    suspend fun bulkCreateHabitLogs(@Body request: BulkHabitLogRequest): Response<List<HabitLogDto>>

    @GET("habit-logs/summary")
    suspend fun getHabitLogSummary(
        @Query("period") period: String = "week"
    ): Response<HabitSummaryDto>

    // === DSAA ===
    @GET("dsaa/today")
    suspend fun getDsaaToday(): Response<DsaaLogDto?>

    @POST("dsaa/log")
    suspend fun createDsaaLog(@Body request: CreateDsaaLogRequest): Response<DsaaLogDto>

    @PUT("dsaa/log/{id}")
    suspend fun updateDsaaLog(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<DsaaLogDto>

    @GET("dsaa/history")
    suspend fun getDsaaHistory(
        @Query("page") page: Int = 1,
        @Query("limit") limit: Int = 20
    ): Response<List<DsaaLogDto>>

    @GET("dsaa/stats")
    suspend fun getDsaaStats(): Response<DsaaStatsDto>

    @POST("dsaa/ai-suggest")
    suspend fun getDsaaAiSuggestion(): Response<DsaaSuggestionDto>

    // === Reminders ===
    @GET("reminders")
    suspend fun getReminders(): Response<List<ReminderDto>>

    @POST("reminders")
    suspend fun createReminder(@Body body: Map<String, Any>): Response<ReminderDto>

    @PUT("reminders/{id}")
    suspend fun updateReminder(
        @Path("id") id: String,
        @Body body: Map<String, Any>
    ): Response<ReminderDto>

    @DELETE("reminders/{id}")
    suspend fun deleteReminder(@Path("id") id: String): Response<Unit>

    @POST("reminders/setup-defaults")
    suspend fun setupDefaultReminders(): Response<List<ReminderDto>>

    // === AI Services ===
    @POST("ai/weekly-summary")
    suspend fun generateWeeklySummary(@Body body: Map<String, String>): Response<AiInsightDto>

    @POST("ai/daily-coaching")
    suspend fun getDailyCoaching(): Response<AiInsightDto>

    @POST("ai/dsaa-suggest")
    suspend fun getAiDsaaSuggestion(): Response<DsaaSuggestionDto>

    @POST("ai/constraint-analysis")
    suspend fun getConstraintAnalysis(@Body body: Map<String, String>): Response<AiInsightDto>

    @POST("ai/trend-insight")
    suspend fun getTrendInsight(): Response<AiInsightDto>

    @POST("ai/habit-insight")
    suspend fun getHabitInsight(): Response<AiInsightDto>

    @POST("ai/scorecard-insight")
    suspend fun getScorecardInsight(@Body body: Map<String, Any>): Response<AiInsightDto>

    // === Trends ===
    @GET("trends/weekly")
    suspend fun getWeeklyTrends(@Query("weeks") weeks: Int = 12): Response<List<TrendDataDto>>

    @GET("trends/habits")
    suspend fun getHabitTrends(@Query("period") period: String = "month"): Response<List<TrendDataDto>>

    @GET("trends/dsaa")
    suspend fun getDsaaTrends(@Query("period") period: String = "quarter"): Response<Map<String, Any>>

    @GET("trends/deep-work")
    suspend fun getDeepWorkTrends(@Query("period") period: String = "month"): Response<List<TrendDataDto>>

    @GET("trends/outcomes")
    suspend fun getOutcomeTrends(@Query("period") period: String = "quarter"): Response<List<TrendDataDto>>

    @GET("trends/dashboard")
    suspend fun getTrendsDashboard(): Response<Map<String, Any>>
}
