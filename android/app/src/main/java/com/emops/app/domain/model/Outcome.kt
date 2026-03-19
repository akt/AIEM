package com.emops.app.domain.model

data class Outcome(
    val id: String = "",
    val sheetId: String = "",
    val position: Int = 1,
    val outcomeText: String = "",
    val impact: String = "",
    val definitionOfDone: String = "",
    val owner: String = "",
    val riskAndMitigation: String = "",
    val status: String = "in_progress",
    val completedAt: String? = null
)

data class LeadershipDecision(
    val id: String = "",
    val sheetId: String = "",
    val position: Int = 1,
    val decisionText: String = "",
    val byWhen: String? = null,
    val inputsNeeded: String = "",
    val status: String = "pending",
    val decisionResult: String? = null
)
