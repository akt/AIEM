import Foundation

struct ConstraintEvidence: Codable, Equatable {
    let sliDashboards: String
    let incidentPattern: String
    let queueLag: String
    let costRegression: String

    enum CodingKeys: String, CodingKey {
        case sliDashboards = "sli_dashboards"
        case incidentPattern = "incident_pattern"
        case queueLag = "queue_lag"
        case costRegression = "cost_regression"
    }
}

struct DsaaQueue: Codable, Equatable {
    let delete: [String]
    let simplify: [String]
    let accelerate: [String]
    let automate: [String]

    enum CodingKeys: String, CodingKey {
        case delete
        case simplify
        case accelerate
        case automate
    }
}

struct DayTimeBlock: Codable, Equatable {
    let deepWork: String
    let freeThinking: String
    let reactiveBudget: String
    let keyMeeting: String

    enum CodingKeys: String, CodingKey {
        case deepWork = "deep_work"
        case freeThinking = "free_thinking"
        case reactiveBudget = "reactive_budget"
        case keyMeeting = "key_meeting"
    }
}

struct AiTask: Codable, Equatable {
    let task: String
    let enabled: Bool
    let owner: String

    enum CodingKeys: String, CodingKey {
        case task
        case enabled
        case owner
    }
}

struct IncidentChecklist: Codable, Equatable {
    let p0p1Reviewed: Bool
    let postmortemScheduled: Bool
    let actionItemsOwned: Bool
    let runbooksUpdated: Bool
    let preventionBetChosen: Bool

    enum CodingKeys: String, CodingKey {
        case p0p1Reviewed = "p0p1_reviewed"
        case postmortemScheduled = "postmortem_scheduled"
        case actionItemsOwned = "action_items_owned"
        case runbooksUpdated = "runbooks_updated"
        case preventionBetChosen = "prevention_bet_chosen"
    }
}

struct AdrChecklist: Codable, Equatable {
    let adrLinkExists: Bool
    let alternativesConsidered: Bool
    let rolloutRollbackPlan: Bool
    let observabilityPlan: Bool
    let dataContractsChecked: Bool

    enum CodingKeys: String, CodingKey {
        case adrLinkExists = "adr_link_exists"
        case alternativesConsidered = "alternatives_considered"
        case rolloutRollbackPlan = "rollout_rollback_plan"
        case observabilityPlan = "observability_plan"
        case dataContractsChecked = "data_contracts_checked"
    }
}

struct MetricEntry: Codable, Equatable {
    let definition: String
    let thisWeek: String
    let target: String
    let notes: String

    enum CodingKeys: String, CodingKey {
        case definition
        case thisWeek = "this_week"
        case target
        case notes
    }
}

struct WeeklyScorecard: Codable, Equatable {
    let dora: DoraMetrics
    let slo: SloMetrics
    let space: SpaceMetrics
    let aiHealth: AiHealthMetrics

    enum CodingKeys: String, CodingKey {
        case dora
        case slo
        case space
        case aiHealth = "ai_health"
    }

    struct DoraMetrics: Codable, Equatable {
        let deployFreq: MetricEntry
        let leadTime: MetricEntry
        let changeFailRate: MetricEntry
        let timeToRestore: MetricEntry

        enum CodingKeys: String, CodingKey {
            case deployFreq = "deploy_freq"
            case leadTime = "lead_time"
            case changeFailRate = "change_fail_rate"
            case timeToRestore = "time_to_restore"
        }
    }

    struct SloMetrics: Codable, Equatable {
        let compliance: MetricEntry
        let errorBudgetBurn: MetricEntry

        enum CodingKeys: String, CodingKey {
            case compliance
            case errorBudgetBurn = "error_budget_burn"
        }
    }

    struct SpaceMetrics: Codable, Equatable {
        let deepWorkHours: MetricEntry
        let frictionPulse: MetricEntry

        enum CodingKeys: String, CodingKey {
            case deepWorkHours = "deep_work_hours"
            case frictionPulse = "friction_pulse"
        }
    }

    struct AiHealthMetrics: Codable, Equatable {
        let assistedPct: MetricEntry
        let riskCatches: MetricEntry

        enum CodingKeys: String, CodingKey {
            case assistedPct = "assisted_pct"
            case riskCatches = "risk_catches"
        }
    }
}

struct WeeklySheet: Codable, Identifiable, Equatable {
    let id: String
    let userId: String
    let weekStart: String
    let weekLabel: String
    let status: SheetStatus
    let surfacesInScope: [String]
    let oncallOwnership: String
    let keyDependencies: String
    let nonNegotiableConstraints: String
    let constraintStatement: String
    let constraintEvidence: ConstraintEvidence
    let constraintSloService: String
    let constraintSloTargets: String
    let constraintErrorBudgetStatus: ErrorBudgetStatus
    let constraintExhaustedAction: String
    let dsaaQueue: DsaaQueue
    let dsaaFocusThisWeek: DsaaFocus
    let aiTasks: [AiTask]
    let aiGuardrailsChecked: [String]
    let timeBlocks: [String: DayTimeBlock]
    let incidentChecklist: IncidentChecklist
    let adrChecklist: AdrChecklist
    let scorecard: WeeklyScorecard?
    let aiWeeklySummary: String?
    let aiCoachingNotes: String?
    let outcomes: [Outcome]
    let decisions: [LeadershipDecision]
    let createdAt: String
    let updatedAt: String
    let completedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case weekStart = "week_start"
        case weekLabel = "week_label"
        case status
        case surfacesInScope = "surfaces_in_scope"
        case oncallOwnership = "oncall_ownership"
        case keyDependencies = "key_dependencies"
        case nonNegotiableConstraints = "non_negotiable_constraints"
        case constraintStatement = "constraint_statement"
        case constraintEvidence = "constraint_evidence"
        case constraintSloService = "constraint_slo_service"
        case constraintSloTargets = "constraint_slo_targets"
        case constraintErrorBudgetStatus = "constraint_error_budget_status"
        case constraintExhaustedAction = "constraint_exhausted_action"
        case dsaaQueue = "dsaa_queue"
        case dsaaFocusThisWeek = "dsaa_focus_this_week"
        case aiTasks = "ai_tasks"
        case aiGuardrailsChecked = "ai_guardrails_checked"
        case timeBlocks = "time_blocks"
        case incidentChecklist = "incident_checklist"
        case adrChecklist = "adr_checklist"
        case scorecard
        case aiWeeklySummary = "ai_weekly_summary"
        case aiCoachingNotes = "ai_coaching_notes"
        case outcomes
        case decisions
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }

    enum SheetStatus: String, Codable, CaseIterable {
        case draft
        case active
        case completed
        case archived
    }

    enum ErrorBudgetStatus: String, Codable, CaseIterable {
        case healthy
        case burning
        case exhausted
    }

    enum DsaaFocus: String, Codable, CaseIterable {
        case delete
        case simplify
        case accelerate
        case automate
    }
}
