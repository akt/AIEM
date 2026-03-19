package com.emops.app.data.local.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "dsaa_logs")
data class DsaaLogEntity(
    @PrimaryKey val id: String,
    val userId: String,
    val sheetId: String?,
    val logDate: String,
    val frictionPoint: String,
    val dsaaAction: String,
    val microArtifactType: String?,
    val microArtifactDescription: String?,
    val expectedLeverage: String?,
    val startedAt: String?,
    val completedAt: String?,
    val durationMinutes: Int?,
    val aiSuggestedAction: String?,
    val aiSuggestionAccepted: Boolean
)
