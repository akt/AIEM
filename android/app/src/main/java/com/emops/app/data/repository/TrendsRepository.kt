package com.emops.app.data.repository

import com.emops.app.data.remote.ApiService
import com.emops.app.domain.model.TrendData
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class TrendsRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getWeeklyTrends(weeks: Int = 12): Result<List<TrendData>> {
        return try {
            val response = apiService.getWeeklyTrends(weeks)
            if (response.isSuccessful) {
                Result.success(response.body()!!.map {
                    TrendData(
                        weekStart = it.weekStart,
                        deepWorkHoursTotal = it.deepWorkHoursTotal ?: 0.0,
                        dsaaRitualsCompleted = it.dsaaRitualsCompleted ?: 0,
                        habitsCompletionRate = it.habitsCompletionRate ?: 0.0,
                        outcomesCompleted = it.outcomesCompleted ?: 0,
                        outcomesTotal = it.outcomesTotal ?: 0,
                        errorBudgetStatus = it.errorBudgetStatus ?: "",
                        streakDays = it.streakDays ?: 0,
                        aiTrendInsight = it.aiTrendInsight
                    )
                })
            } else {
                Result.failure(Exception("Failed to get trends"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getDashboard(): Result<Map<String, Any>> {
        return try {
            val response = apiService.getTrendsDashboard()
            if (response.isSuccessful) {
                Result.success(response.body()!!)
            } else {
                Result.failure(Exception("Failed to get dashboard"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
