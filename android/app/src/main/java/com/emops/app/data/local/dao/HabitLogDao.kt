package com.emops.app.data.local.dao

import androidx.room.*
import com.emops.app.data.local.entity.HabitLogEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface HabitLogDao {
    @Query("SELECT * FROM habit_logs WHERE userId = :userId AND logDate = :date")
    fun getLogsByDate(userId: String, date: String): Flow<List<HabitLogEntity>>

    @Query("SELECT * FROM habit_logs WHERE userId = :userId AND logDate BETWEEN :from AND :to")
    fun getLogsByDateRange(userId: String, from: String, to: String): Flow<List<HabitLogEntity>>

    @Query("SELECT * FROM habit_logs WHERE habitId = :habitId ORDER BY logDate DESC")
    fun getLogsByHabit(habitId: String): Flow<List<HabitLogEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLog(log: HabitLogEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLogs(logs: List<HabitLogEntity>)

    @Delete
    suspend fun deleteLog(log: HabitLogEntity)

    @Query("DELETE FROM habit_logs")
    suspend fun deleteAll()
}
