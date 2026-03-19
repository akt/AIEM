import Foundation

struct NotificationPreferences: Codable, Equatable {
    let dailyDsaaReminder: Bool
    let weeklyFillReminder: Bool
    let deepWorkStartAlert: Bool
    let scorecardFridayReminder: Bool
    let reactiveWindowAlerts: Bool
    let incidentPipelineCheck: Bool

    enum CodingKeys: String, CodingKey {
        case dailyDsaaReminder = "daily_dsaa_reminder"
        case weeklyFillReminder = "weekly_fill_reminder"
        case deepWorkStartAlert = "deep_work_start_alert"
        case scorecardFridayReminder = "scorecard_friday_reminder"
        case reactiveWindowAlerts = "reactive_window_alerts"
        case incidentPipelineCheck = "incident_pipeline_check"
    }
}

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let displayName: String
    let timezone: String
    let role: String
    let surfaces: [String]
    let notificationPreferences: NotificationPreferences
    let dsaaTriggerTime: String
    let dsaaTriggerEvent: String
    let deepWorkHoursTarget: Double

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case timezone
        case role
        case surfaces
        case notificationPreferences = "notification_preferences"
        case dsaaTriggerTime = "dsaa_trigger_time"
        case dsaaTriggerEvent = "dsaa_trigger_event"
        case deepWorkHoursTarget = "deep_work_hours_target"
    }
}
