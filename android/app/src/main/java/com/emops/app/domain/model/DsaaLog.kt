package com.emops.app.domain.model

data class DsaaLog(
    val id: String = "",
    val userId: String = "",
    val sheetId: String? = null,
    val logDate: String = "",
    val frictionPoint: String = "",
    val dsaaAction: String = "",
    val microArtifactType: String? = null,
    val microArtifactDescription: String? = null,
    val expectedLeverage: String? = null,
    val startedAt: String? = null,
    val completedAt: String? = null,
    val durationMinutes: Int? = null,
    val aiSuggestedAction: String? = null,
    val aiSuggestionAccepted: Boolean = false
)

data class DsaaSuggestion(
    val dsaaAction: String = "",
    val actionDescription: String = "",
    val microArtifact: String = "",
    val teamMessage: String = "",
    val expectedLeverage: String = ""
)
