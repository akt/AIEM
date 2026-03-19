package com.emops.app.data.local.dao

import androidx.room.*
import com.emops.app.data.local.entity.DsaaLogEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface DsaaLogDao {
    @Query("SELECT * FROM dsaa_logs WHERE userId = :userId AND logDate = :date")
    suspend fun getLogByDate(userId: String, date: String): DsaaLogEntity?

    @Query("SELECT * FROM dsaa_logs WHERE userId = :userId ORDER BY logDate DESC")
    fun getLogsByUser(userId: String): Flow<List<DsaaLogEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLog(log: DsaaLogEntity)

    @Delete
    suspend fun deleteLog(log: DsaaLogEntity)

    @Query("DELETE FROM dsaa_logs")
    suspend fun deleteAll()
}
