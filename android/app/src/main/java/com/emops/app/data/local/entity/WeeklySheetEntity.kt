package com.emops.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "weekly_sheets")
data class WeeklySheetEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val weekStart: String,
    val weekLabel: String,
    val status: String,
    val constraintStatement: String?,
    val constraintErrorBudgetStatus: String?,
    val dsaaFocusThisWeek: String?,
    val aiWeeklySummary: String?,
    val dataJson: String,
    val updatedAt: String
)
