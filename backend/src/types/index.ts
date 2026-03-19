// ============================================================
// Express Request augmentation
// ============================================================

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
      };
    }
  }
}

// ============================================================
// Shared Types — used by backend, generated for mobile clients
// ============================================================

export interface User {
  id: string;
  email: string;
  displayName: string;
  timezone: string;
  role: string;
  surfaces: string[];
  notificationPreferences: NotificationPreferences;
  dsaaTriggerTime: string;
  dsaaTriggerEvent: string;
  deepWorkHoursTarget: number;
  createdAt: string;
  updatedAt: string;
}

export interface NotificationPreferences {
  dailyDsaaReminder: boolean;
  weeklyFillReminder: boolean;
  deepWorkStartAlert: boolean;
  scorecardFridayReminder: boolean;
  reactiveWindowAlerts: boolean;
  incidentPipelineCheck: boolean;
}

export interface WeeklySheet {
  id: string;
  userId: string;
  weekStart: string;
  weekLabel: string;
  status: 'draft' | 'active' | 'completed' | 'archived';

  // Week Identity
  surfacesInScope: string[];
  oncallOwnership: string;
  keyDependencies: string;
  nonNegotiableConstraints: string;

  // Constraint Deep-Dive
  constraintStatement: string;
  constraintEvidence: ConstraintEvidence;
  constraintSloService: string;
  constraintSloTargets: string;
  constraintErrorBudgetStatus: 'healthy' | 'burning' | 'exhausted';
  constraintExhaustedAction: string;

  // DSAA
  dsaaQueue: DsaaQueue;
  dsaaFocusThisWeek: 'delete' | 'simplify' | 'accelerate' | 'automate';

  // AI Plan
  aiTasks: AiTask[];
  aiGuardrailsChecked: string[];

  // Time Blocks
  timeBlocks: Record<string, DayTimeBlock>;

  // Checklists
  incidentChecklist: IncidentChecklist;
  adrChecklist: AdrChecklist;

  // Scorecard
  scorecard: WeeklyScorecard | null;

  // AI-generated
  aiWeeklySummary: string | null;
  aiCoachingNotes: string | null;

  // Nested
  outcomes: Outcome[];
  decisions: LeadershipDecision[];

  createdAt: string;
  updatedAt: string;
  completedAt: string | null;
}

export interface ConstraintEvidence {
  sliDashboards: string;
  incidentPattern: string;
  queueLag: string;
  costRegression: string;
}

export interface DsaaQueue {
  delete: string[];
  simplify: string[];
  accelerate: string[];
  automate: string[];
}

export interface DayTimeBlock {
  deepWork: string;
  freeThinking: string;
  reactiveBudget: string;
  keyMeeting: string;
}

export interface AiTask {
  task: string;
  enabled: boolean;
  owner: string;
}

export interface IncidentChecklist {
  p0p1Reviewed: boolean;
  postmortemScheduled: boolean;
  actionItemsOwned: boolean;
  runbooksUpdated: boolean;
  preventionBetChosen: boolean;
}

export interface AdrChecklist {
  adrLinkExists: boolean;
  alternativesConsidered: boolean;
  rolloutRollbackPlan: boolean;
  observabilityPlan: boolean;
  dataContractsChecked: boolean;
}

export interface WeeklyScorecard {
  dora: {
    deployFreq: MetricEntry;
    leadTime: MetricEntry;
    changeFailRate: MetricEntry;
    timeToRestore: MetricEntry;
  };
  slo: {
    compliance: MetricEntry;
    errorBudgetBurn: MetricEntry;
  };
  space: {
    deepWorkHours: MetricEntry;
    frictionPulse: MetricEntry;
  };
  aiHealth: {
    assistedPct: MetricEntry;
    riskCatches: MetricEntry;
  };
}

export interface MetricEntry {
  definition: string;
  thisWeek: string;
  target: string;
  notes: string;
}

export interface Outcome {
  id: string;
  sheetId: string;
  position: number;
  outcomeText: string;
  impact: string;
  definitionOfDone: string;
  owner: string;
  riskAndMitigation: string;
  status: 'in_progress' | 'done' | 'blocked' | 'carried_over';
  completedAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface LeadershipDecision {
  id: string;
  sheetId: string;
  position: number;
  decisionText: string;
  byWhen: string;
  inputsNeeded: string;
  status: 'pending' | 'decided' | 'deferred';
  decisionResult: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface Habit {
  id: string;
  userId: string;
  name: string;
  description: string;
  category: HabitCategory;
  frequency: 'daily' | 'weekday' | 'weekly' | 'custom';
  customDays: string[] | null;
  targetValue: number;
  targetUnit: 'hours' | 'count' | 'boolean' | 'percentage';
  reminderTime: string | null;
  reminderEnabled: boolean;
  streakCurrent: number;
  streakBest: number;
  isActive: boolean;
  sortOrder: number;
  createdAt: string;
  updatedAt: string;
}

export type HabitCategory =
  | 'deep_work'
  | 'reliability'
  | 'delivery'
  | 'security'
  | 'ai_safety'
  | 'leadership'
  | 'health'
  | 'learning';

export interface HabitLog {
  id: string;
  habitId: string;
  userId: string;
  logDate: string;
  value: number | null;
  isCompleted: boolean;
  notes: string;
  createdAt: string;
  updatedAt: string;
}

export interface DsaaLog {
  id: string;
  userId: string;
  sheetId: string | null;
  logDate: string;
  frictionPoint: string;
  dsaaAction: 'delete' | 'simplify' | 'accelerate' | 'automate';
  microArtifactType: string;
  microArtifactDescription: string;
  expectedLeverage: string;
  startedAt: string | null;
  completedAt: string | null;
  durationMinutes: number | null;
  aiSuggestedAction: string | null;
  aiSuggestionAccepted: boolean;
  createdAt: string;
}

export interface Reminder {
  id: string;
  userId: string;
  title: string;
  body: string;
  reminderType: string;
  scheduleType: 'once' | 'daily' | 'weekly' | 'custom';
  scheduledTime: string | null;
  scheduledDays: string[] | null;
  scheduledDate: string | null;
  linkedEntityType: string | null;
  linkedEntityId: string | null;
  isActive: boolean;
  lastFiredAt: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface NotificationLogEntry {
  id: string;
  userId: string;
  reminderId: string | null;
  title: string;
  body: string;
  channel: 'push' | 'in_app';
  status: 'sent' | 'delivered' | 'failed' | 'dismissed' | 'actioned';
  sentAt: string;
  actionedAt: string | null;
}

export interface AiInteraction {
  id: string;
  userId: string;
  interactionType: string;
  contextData: Record<string, unknown>;
  aiResponse: string;
  modelUsed: string;
  tokensUsed: number | null;
  wasHelpful: boolean | null;
  userFeedback: string | null;
  createdAt: string;
}

export interface TrendData {
  weekStart: string;
  deepWorkHoursTotal: number;
  dsaaRitualsCompleted: number;
  habitsCompletionRate: number;
  outcomesCompleted: number;
  outcomesTotal: number;
  decisionsMade: number;
  decisionsTotal: number;
  incidentsReviewed: boolean;
  errorBudgetStatus: string;
  doraScores: Record<string, unknown>;
  aiAssistsCount: number;
  streakDays: number;
  frictionPulseAvg: number;
  aiTrendInsight: string | null;
}

export interface DashboardData {
  currentSheet: WeeklySheet | null;
  todayHabits: {
    total: number;
    completed: number;
    habits: (Habit & { todayLog: HabitLog | null })[];
  };
  dsaaStreak: number;
  todayDsaa: DsaaLog | null;
  upcomingReminders: Reminder[];
  aiCoachingNote: string | null;
  weeklyProgress: {
    outcomesCompleted: number;
    outcomesTotal: number;
    deepWorkHoursThisWeek: number;
    deepWorkHoursTarget: number;
  };
}
