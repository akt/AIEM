package com.emops.app.data.local.dao

import androidx.room.*
import com.emops.app.data.local.entity.WeeklySheetEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface WeeklySheetDao {
    @Query("SELECT * FROM weekly_sheets WHERE userId = :userId ORDER BY weekStart DESC")
    fun getSheetsByUser(userId: String): Flow<List<WeeklySheetEntity>>

    @Query("SELECT * FROM weekly_sheets WHERE id = :id")
    suspend fun getSheetById(id: String): WeeklySheetEntity?

    @Query("SELECT * FROM weekly_sheets WHERE userId = :userId AND weekStart = :weekStart")
    suspend fun getSheetByWeek(userId: String, weekStart: String): WeeklySheetEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSheet(sheet: WeeklySheetEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSheets(sheets: List<WeeklySheetEntity>)

    @Delete
    suspend fun deleteSheet(sheet: WeeklySheetEntity)

    @Query("DELETE FROM weekly_sheets")
    suspend fun deleteAll()
}
