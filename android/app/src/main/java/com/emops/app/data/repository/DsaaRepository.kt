package com.emops.app.data.repository

import com.emops.app.data.remote.ApiService
import com.emops.app.data.remote.dto.CreateDsaaLogRequest
import com.emops.app.data.remote.dto.DsaaLogDto
import com.emops.app.domain.model.DsaaLog
import com.emops.app.domain.model.DsaaSuggestion
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DsaaRepository @Inject constructor(
    private val apiService: ApiService
) {
    suspend fun getToday(): Result<DsaaLog?> {
        return try {
            val response = apiService.getDsaaToday()
            if (response.isSuccessful) {
                Result.success(response.body()?.toDomain())
            } else {
                Result.success(null)
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun logRitual(request: CreateDsaaLogRequest): Result<DsaaLog> {
        return try {
            val response = apiService.createDsaaLog(request)
            if (response.isSuccessful) {
                Result.success(response.body()!!.toDomain())
            } else {
                Result.failure(Exception("Failed to log DSAA ritual"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getHistory(page: Int = 1): Result<List<DsaaLog>> {
        return try {
            val response = apiService.getDsaaHistory(page)
            if (response.isSuccessful) {
                Result.success(response.body()!!.map { it.toDomain() })
            } else {
                Result.failure(Exception("Failed to get DSAA history"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getAiSuggestion(): Result<DsaaSuggestion> {
        return try {
            val response = apiService.getDsaaAiSuggestion()
            if (response.isSuccessful) {
                val dto = response.body()!!
                Result.success(DsaaSuggestion(
                    dsaaAction = dto.dsaaAction,
                    actionDescription = dto.actionDescription,
                    microArtifact = dto.microArtifact,
                    teamMessage = dto.teamMessage,
                    expectedLeverage = dto.expectedLeverage
                ))
            } else {
                Result.failure(Exception("Failed to get AI suggestion"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getStats(): Result<Map<String, Any>> {
        return try {
            val response = apiService.getDsaaStats()
            if (response.isSuccessful) {
                val stats = response.body()!!
                Result.success(mapOf(
                    "totalRituals" to stats.totalRituals,
                    "currentStreak" to stats.currentStreak,
                    "categoryDistribution" to (stats.categoryDistribution ?: emptyMap()),
                    "avgDurationMinutes" to (stats.avgDurationMinutes ?: 0.0)
                ))
            } else {
                Result.failure(Exception("Failed to get DSAA stats"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private fun DsaaLogDto.toDomain() = DsaaLog(
        id = id, userId = userId, sheetId = sheetId, logDate = logDate,
        frictionPoint = frictionPoint, dsaaAction = dsaaAction,
        microArtifactType = microArtifactType, microArtifactDescription = microArtifactDescription,
        expectedLeverage = expectedLeverage, startedAt = startedAt, completedAt = completedAt,
        durationMinutes = durationMinutes, aiSuggestedAction = aiSuggestedAction,
        aiSuggestionAccepted = aiSuggestionAccepted ?: false
    )
}
