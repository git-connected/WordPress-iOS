import Foundation

/// Main interface for scheduling blogging reminders
///
class BloggingReminders {

    enum Schedule {
        /// No reminder schedule.
        ///
        case none

        /// Weekdays reminders
        ///
        case weekdays(_ days: [Weekday])
    }

    enum Weekday: Int {
        case sunday = 1 // Keep this at 1 to match Apple's `DateComponents`' weekday number.
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday

        /// The default reminder hour.  In the future we may want to replace this constant with a more customizable approach.
        ///
        static let defaultHour = 10
    }

    /// Singleton for use in the App.
    ///
    static let `shared` = BloggingReminders()

    /// The store for persisting our schedule.
    ///
    private let store: BloggingRemindersStore

    /// The notification center
    ///
    private let notificationCenter: UNUserNotificationCenter

    /// Active schedule.
    ///
    var schedule: Schedule {
        switch store.schedule {
        case .none:
            return .none
        case .weekdays(let days):
            return .weekdays(days.map({ $0.identifier }))
        }
    }

    // MARK: - Initializers

    /// Default initializer.  Allows overriding the blogging reminders store and the notification center for testing purposes.
    ///
    init(store: BloggingRemindersStore = .default, notificationCenter: UNUserNotificationCenter = .current()) {
        self.store = store
        self.notificationCenter = notificationCenter
    }

    // MARK: - Scheduling

    /// Main method for scheduling blogging reminder notifications.  This method will take care of scheduling the local notifications and
    /// persisting the user-defined reminder schedule.
    ///
    /// - Parameters:
    ///     - schedule: the blogging reminders schedule.
    ///
    func schedule(_ schedule: Schedule) {
        unschedule(store.schedule)

        switch schedule {
        case .none:
            store.schedule = .none
        case .weekdays(let days):
            store.schedule = .weekdays(scheduled(days))
        }
    }

    /// Schedules a notifications for the passed days, and returns another array with the days and their
    /// associated notification IDs.
    ///
    /// - Parameters:
    ///     - weekdays: the weekdays to schedule notifications for.
    ///
    /// - Returns: the weekdays with the associated notification IDs.
    ///
    private func scheduled(_ weekdays: [Weekday]) -> [BloggingRemindersStore.Weekday] {
        weekdays.map { scheduled($0) }
    }

    /// Schedules a notification for the passed day, and returns the day with the associated notification ID.
    ///
    /// - Parameters:
    ///     - weekday: the weekday to schedule a notification for.
    ///
    /// - Returns: the weekday with the associated notification ID.
    ///
    private func scheduled(_ weekday: Weekday) -> BloggingRemindersStore.Weekday {
        let notificationID = scheduleNotification(for: weekday)
        switch weekday {
        case .monday:
            return .monday(notificationID: notificationID)
        case .tuesday:
            return .tuesday(notificationID: notificationID)
        case .wednesday:
            return .wednesday(notificationID: notificationID)
        case .thursday:
            return .thursday(notificationID: notificationID)
        case .friday:
            return .friday(notificationID: notificationID)
        case .saturday:
            return .saturday(notificationID: notificationID)
        case .sunday:
            return .sunday(notificationID: notificationID)
        }
    }

    /// Schedules a notification for the specified weekday.
    ///
    private func scheduleNotification(for weekday: Weekday) -> String {
        let content = UNMutableNotificationContent()
        content.title = "Blogging Reminder"
        content.body = "It's time to post!"

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current

        dateComponents.weekday = weekday.rawValue
        dateComponents.hour = Weekday.defaultHour

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                DDLogError(error.localizedDescription)
            }
        }

        return uuidString
    }

    // MARK: - Unscheduling

    /// Unschedules all notifications for the passed schedule.
    ///
    private func unschedule(_ schedule: BloggingRemindersStore.Schedule) {
        switch schedule {
        case .none:
            return
        case .weekdays(let days):
            unschedule(days)
        }
    }

    /// Unschedules all notiication for the specified days.
    ///
    private func unschedule(_ days: [BloggingRemindersStore.Weekday]) {
        let notificationIDs = days.map { $0.notificationID }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIDs)
    }
}
