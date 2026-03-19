package com.emops.app.data.local

import androidx.room.Database
import androidx.room.RoomDatabase
import com.emops.app.data.local.dao.*
import com.emops.app.data.local.entity.*

@Database(
    entities = [
        WeeklySheetEntity::class,
        HabitEntity::class,
        HabitLogEntity::class,
        DsaaLogEntity::class,
        ReminderEntity::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun weeklySheetDao(): WeeklySheetDao
    abstract fun habitDao(): HabitDao
    abstract fun habitLogDao(): HabitLogDao
    abstract fun dsaaLogDao(): DsaaLogDao
    abstract fun reminderDao(): ReminderDao
}
