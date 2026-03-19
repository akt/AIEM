package com.emops.app.di

import android.content.Context
import androidx.room.Room
import com.emops.app.data.local.AppDatabase
import com.emops.app.data.local.dao.*
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "emops_database"
        ).fallbackToDestructiveMigration()
            .build()
    }

    @Provides
    fun provideWeeklySheetDao(db: AppDatabase): WeeklySheetDao = db.weeklySheetDao()

    @Provides
    fun provideHabitDao(db: AppDatabase): HabitDao = db.habitDao()

    @Provides
    fun provideHabitLogDao(db: AppDatabase): HabitLogDao = db.habitLogDao()

    @Provides
    fun provideDsaaLogDao(db: AppDatabase): DsaaLogDao = db.dsaaLogDao()

    @Provides
    fun provideReminderDao(db: AppDatabase): ReminderDao = db.reminderDao()
}
