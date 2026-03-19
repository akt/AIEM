package com.emops.app.domain.model

data class WeeklySheet(
    val id: String = "",
    val userId: String = "",
    val weekStart: String = "",
    val weekLabel: String = "",
    val status: String = "draft",
    val surfacesInScope: List<String> = emptyList(),
    val oncallOwnership: String = "",
    val keyDependencies: String = "",
    val nonNegotiableConstraints: String = "",
    val constraintStatement: String = "",
    val constraintEvidence: ConstraintEvidence = ConstraintEvidence(),
    val constraintSloService: String = "",
    val constraintSloTargets: String = "",
    val constraintErrorBudgetStatus: String = "healthy",
    val constraintExhaustedAction: String = "",
    val dsaaQueue: DsaaQueue = DsaaQueue(),
    val dsaaFocusThisWeek: String = "",
    val aiTasks: List<AiTask> = emptyList(),
    val aiGuardrailsChecked: List<String> = emptyList(),
    val timeBlocks: Map<String, DayTimeBlock> = emptyMap(),
    val incidentChecklist: IncidentChecklist = IncidentChecklist(),
    val adrChecklist: AdrChecklist = AdrChecklist(),
    val scorecard: WeeklyScorecard? = null,
    val aiWeeklySummary: String? = null,
    val aiCoachingNotes: String? = null,
    val outcomes: List<Outcome> = emptyList(),
    val decisions: List<LeadershipDecision> = emptyList(),
    val createdAt: String = "",
    val updatedAt: String = "",
    val completedAt: String? = null
)

data class ConstraintEvidence(
    val sliDashboards: String = "",
    val incidentPattern: String = "",
    val queueLag: String = "",
    val costRegression: String = ""
)

data class DsaaQueue(
    val delete: List<String> = emptyList(),
    val simplify: List<String> = emptyList(),
    val accelerate: List<String> = emptyList(),
    val automate: List<String> = emptyList()
)

data class DayTimeBlock(
    val deepWork: String = "",
    val freeThinking: String = "",
    val reactiveBudget: String = "",
    val keyMeeting: String = ""
)

data class AiTask(
    val task: String = "",
    val enabled: Boolean = true,
    val owner: String = ""
)

data class IncidentChecklist(
    val p0p1Reviewed: Boolean = false,
    val postmortemScheduled: Boolean = false,
    val actionItemsOwned: Boolean = false,
    val runbooksUpdated: Boolean = false,
    val preventionBetChosen: Boolean = false
)

data class AdrChecklist(
    val adrLinkExists: Boolean = false,
    val alternativesConsidered: Boolean = false,
    val rolloutRollbackPlan: Boolean = false,
    val observabilityPlan: Boolean = false,
    val dataContractsChecked: Boolean = false
)

data class WeeklyScorecard(
    val dora: DoraMetrics = DoraMetrics(),
    val slo: SloMetrics = SloMetrics(),
    val space: SpaceMetrics = SpaceMetrics(),
    val aiHealth: AiHealthMetrics = AiHealthMetrics()
)

data class DoraMetrics(
    val deployFreq: MetricEntry = MetricEntry(),
    val leadTime: MetricEntry = MetricEntry(),
    val changeFailRate: MetricEntry = MetricEntry(),
    val timeToRestore: MetricEntry = MetricEntry()
)

data class SloMetrics(
    val compliance: MetricEntry = MetricEntry(),
    val errorBudgetBurn: MetricEntry = MetricEntry()
)

data class SpaceMetrics(
    val deepWorkHours: MetricEntry = MetricEntry(),
    val frictionPulse: MetricEntry = MetricEntry()
)

data class AiHealthMetrics(
    val assistedPct: MetricEntry = MetricEntry(),
    val riskCatches: MetricEntry = MetricEntry()
)

data class MetricEntry(
    val definition: String = "",
    val thisWeek: String = "",
    val target: String = "",
    val notes: String = ""
)
