package com.emops.app.data.repository

import com.emops.app.data.remote.ApiService
import com.emops.app.data.remote.dto.WeeklySheetDto
import com.emops.app.domain.model.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WeeklySheetRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getCurrentSheet(): Result<WeeklySheet> {
        return try {
            val response = apiService.getCurrentSheet()
            if (response.isSuccessful) {
                Result.success(response.body()!!.toDomain())
            } else {
                Result.failure(Exception("Failed to get current sheet"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getSheetById(id: String): Result<WeeklySheet> {
        return try {
            val response = apiService.getSheetById(id)
            if (response.isSuccessful) {
                Result.success(response.body()!!.toDomain())
            } else {
                Result.failure(Exception("Failed to get sheet"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getSheets(page: Int = 1): Result<List<WeeklySheet>> {
        return try {
            val response = apiService.getWeeklySheets(page)
            if (response.isSuccessful) {
                Result.success(response.body()!!.map { it.toDomain() })
            } else {
                Result.failure(Exception("Failed to get sheets"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun updateSheet(id: String, updates: Map<String, Any>): Result<WeeklySheet> {
        return try {
            val response = apiService.updateSheet(id, updates)
            if (response.isSuccessful) {
                Result.success(response.body()!!.toDomain())
            } else {
                Result.failure(Exception("Failed to update sheet"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun completeSheet(id: String): Result<WeeklySheet> {
        return try {
            val response = apiService.completeSheet(id)
            if (response.isSuccessful) {
                Result.success(response.body()!!.toDomain())
            } else {
                Result.failure(Exception("Failed to complete sheet"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun carryForward(id: String): Result<WeeklySheet> {
        return try {
            val response = apiService.carryForward(id)
            if (response.isSuccessful) {
                Result.success(response.body()!!.toDomain())
            } else {
                Result.failure(Exception("Failed to carry forward"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private fun WeeklySheetDto.toDomain() = WeeklySheet(
        id = id,
        userId = userId,
        weekStart = weekStart,
        weekLabel = weekLabel ?: "",
        status = status,
        surfacesInScope = surfacesInScope ?: emptyList(),
        oncallOwnership = oncallOwnership ?: "",
        keyDependencies = keyDependencies ?: "",
        nonNegotiableConstraints = nonNegotiableConstraints ?: "",
        constraintStatement = constraintStatement ?: "",
        constraintErrorBudgetStatus = constraintErrorBudgetStatus ?: "healthy",
        dsaaFocusThisWeek = dsaaFocusThisWeek ?: "",
        aiWeeklySummary = aiWeeklySummary,
        aiCoachingNotes = aiCoachingNotes,
        outcomes = outcomes?.map { it.toDomain() } ?: emptyList(),
        decisions = decisions?.map { it.toDomain() } ?: emptyList(),
        createdAt = createdAt ?: "",
        updatedAt = updatedAt ?: "",
        completedAt = completedAt
    )

    private fun com.emops.app.data.remote.dto.OutcomeDto.toDomain() = Outcome(
        id = id,
        sheetId = sheetId ?: "",
        position = position,
        outcomeText = outcomeText,
        impact = impact ?: "",
        definitionOfDone = definitionOfDone ?: "",
        owner = owner ?: "",
        riskAndMitigation = riskAndMitigation ?: "",
        status = status,
        completedAt = completedAt
    )

    private fun com.emops.app.data.remote.dto.DecisionDto.toDomain() = LeadershipDecision(
        id = id,
        sheetId = sheetId ?: "",
        position = position,
        decisionText = decisionText,
        byWhen = byWhen,
        inputsNeeded = inputsNeeded ?: "",
        status = status,
        decisionResult = decisionResult
    )
}
