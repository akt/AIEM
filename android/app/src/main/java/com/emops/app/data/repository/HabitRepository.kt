package com.emops.app.data.repository

import com.emops.app.data.local.dao.HabitDao
import com.emops.app.data.local.dao.HabitLogDao
import com.emops.app.data.local.entity.HabitEntity
import com.emops.app.data.local.entity.HabitLogEntity
import com.emops.app.data.remote.ApiService
import com.emops.app.data.remote.dto.CreateHabitLogRequest
import com.emops.app.domain.model.Habit
import com.emops.app.domain.model.HabitLog
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class HabitRepository @Inject constructor(
    private val apiService: ApiService,
    private val habitDao: HabitDao,
    private val habitLogDao: HabitLogDao
) {
    fun getLocalHabits(userId: String): Flow<List<Habit>> {
        return habitDao.getActiveHabits(userId).map { entities ->
            entities.map { it.toDomain() }
        }
    }

    fun getLocalLogs(userId: String, date: String): Flow<List<HabitLog>> {
        return habitLogDao.getLogsByDate(userId, date).map { entities ->
            entities.map { it.toDomain() }
        }
    }

    suspend fun syncHabits(): Result<List<Habit>> {
        return try {
            val response = apiService.getHabits()
            if (response.isSuccessful) {
                val habits = response.body()!!
                habitDao.insertHabits(habits.map { it.toEntity() })
                Result.success(habits.map { it.toDomain() })
            } else {
                Result.failure(Exception("Failed to sync habits"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun syncLogs(date: String): Result<List<HabitLog>> {
        return try {
            val response = apiService.getHabitLogs(date = date)
            if (response.isSuccessful) {
                val logs = response.body()!!
                habitLogDao.insertLogs(logs.map { it.toEntity() })
                Result.success(logs.map { it.toDomain() })
            } else {
                Result.failure(Exception("Failed to sync habit logs"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun toggleHabit(habitId: String, date: String, completed: Boolean): Result<HabitLog> {
        return try {
            val response = apiService.createHabitLog(
                CreateHabitLogRequest(habitId = habitId, logDate = date, isCompleted = completed)
            )
            if (response.isSuccessful) {
                val log = response.body()!!
                habitLogDao.insertLog(log.toEntity())
                Result.success(log.toDomain())
            } else {
                Result.failure(Exception("Failed to toggle habit"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    private fun com.emops.app.data.remote.dto.HabitDto.toDomain() = Habit(
        id = id, userId = userId, name = name, description = description ?: "",
        category = category, frequency = frequency, customDays = customDays,
        targetValue = targetValue, targetUnit = targetUnit, reminderTime = reminderTime,
        reminderEnabled = reminderEnabled, streakCurrent = streakCurrent,
        streakBest = streakBest, isActive = isActive, sortOrder = sortOrder
    )

    private fun com.emops.app.data.remote.dto.HabitDto.toEntity() = HabitEntity(
        id = id, userId = userId, name = name, description = description,
        category = category, frequency = frequency, customDaysJson = customDays?.joinToString(","),
        targetValue = targetValue, targetUnit = targetUnit, reminderTime = reminderTime,
        reminderEnabled = reminderEnabled, streakCurrent = streakCurrent,
        streakBest = streakBest, isActive = isActive, sortOrder = sortOrder
    )

    private fun HabitEntity.toDomain() = Habit(
        id = id, userId = userId, name = name, description = description ?: "",
        category = category, frequency = frequency,
        customDays = customDaysJson?.split(",")?.filter { it.isNotEmpty() },
        targetValue = targetValue, targetUnit = targetUnit, reminderTime = reminderTime,
        reminderEnabled = reminderEnabled, streakCurrent = streakCurrent,
        streakBest = streakBest, isActive = isActive, sortOrder = sortOrder
    )

    private fun com.emops.app.data.remote.dto.HabitLogDto.toDomain() = HabitLog(
        id = id, habitId = habitId, userId = userId, logDate = logDate,
        value = value, isCompleted = isCompleted, notes = notes
    )

    private fun com.emops.app.data.remote.dto.HabitLogDto.toEntity() = HabitLogEntity(
        id = id, habitId = habitId, userId = userId, logDate = logDate,
        value = value, isCompleted = isCompleted, notes = notes
    )

    private fun HabitLogEntity.toDomain() = HabitLog(
        id = id, habitId = habitId, userId = userId, logDate = logDate,
        value = value, isCompleted = isCompleted, notes = notes
    )
}
