//
//  Created by Shawn McKee on 7/29/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import Foundation

/// A suite of utility features added to the system's `Date` struct for manipulating and working with dates.
extension Date {
    
    /// Provides a way for you to override and simulate a specific date and time for the device's "now" date. Make sure your code
    /// always uses the `currentDateAndTime` computed property provided in this `Date` extension, when getting
    /// the device's current date and time, for this to work properly
    ///
    /// Overriding and controlling the "now" date can be helpful during development when you need to test how your app will function on a specific dates.
    /// As long as your code is written to get the current date and time by calling the `currentDateAndTime` computed property provided in this `Date`
    /// extension, you will always have the ability to better test current date and time logic.
    public static func simulateCurrentDateAndTime(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        deviceCurrentDateAndTime.set(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    
    /// Clears any date and time that may have been set with `simulateCurrentDateAndTime()`, restoring
    /// the `Date` returned by `currentDateAndTime` to the device's actual date and time.
    public static func restoreCurrentDateAndTime() {
        deviceCurrentDateAndTime.useActualDateAndTime()
    }
    
    
    /// A way to get the device's current date and time, which can be overriden and controlled with `seCurrentDateAndTime()`
    /// for development and testing purposes.
    ///
    /// Apps should always use this read-only computed `Date` property when it needs to know the device's current date and time so that
    /// the device's date can be simulated and controlled as needed during development and testing.
    public static var currentDateAndTime: Date {
        return deviceCurrentDateAndTime.date
    }
    
    
    /// A convenience "getter" that returns a new `Date` set to the beginning of the day (i.e. 12:00:00 AM) for the device's current date.
    ///
    /// The `Date` returned is based on the date returned by `currentDateAndTime` so that `today` can be overridden and simulated
    /// for development and testing purposes, too.
    public static var today: Date {
        return currentDateAndTime.beginningOfDay
    }
    
    
    /// Returns the year of this date.
    public var isToday: Bool {
        return (self.beginningOfDay == Date.currentDateAndTime.beginningOfDay)
    }

    public var isThisMonth: Bool {
        return (self.beginningOfMonth >= Date.currentDateAndTime.beginningOfMonth && self.endOfMonth <= Date.currentDateAndTime.endOfMonth)
    }

    public func isInSameMonthAs(date: Date) -> Bool {
        return (self.beginningOfMonth >= date.beginningOfMonth && self.endOfMonth <= date.endOfMonth)
    }

    /// Returns whether or not the date is any day before today.
    public var isInThePast: Bool {
        return (self.beginningOfDay < Date.currentDateAndTime.beginningOfDay)
    }

    /// Returns the year of this date.
    public var year: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: self).year ?? 0
    }


    /// Returns the month of this date.
    public var month: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.month], from: self).month ?? 0
    }

    
    /// Returns the day of the month of this date.
    public var day: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: self).day ?? 0
    }

    
    /// Returns the hour of this date.
    public var hour: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.hour], from: self).hour ?? 0
    }

    
    /// Returns the minute of this date.
    public var minute: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.minute], from: self).minute ?? 0
    }

    
    /// Returns the second of this date.
    public var second: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.second], from: self).second ?? 0
    }

    
    /// Returns a new `Date` set to beginning of the day (i.e. 12:00:00 AM) for this date.
    public var beginningOfDay: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? self
    }
    
    
    /// Returns a new `Date` set to end of the day (i.e. 11:59:59 PM) for this date.
    public var endOfDay: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59
        return calendar.date(from: components) ?? self
    }
    

    /// Returns a new `Date` for the beginning of the week this date falls in, set to the beginning of that day (i.e. 12:00:00 AM).
    ///
    /// If this date is already the beginning of the week, then it returns a new `Date` set to beginning of that day (i.e. 12:00:00 AM).
    public var beginningOfWeek: Date {
        var customCalendar = Calendar(identifier: .gregorian)
        customCalendar.firstWeekday = 1
        var beginningOfWeekDate = Date.currentDateAndTime
        var interval = TimeInterval()
        if customCalendar.dateInterval(of: .weekOfMonth, start: &beginningOfWeekDate, interval: &interval, for: self) {
            return beginningOfWeekDate
        }
        return self
    }
    
    
    /// Returns a new `Date` for the beginning of the month this date is in, with the time set to the beginning of that day (i.e. 12:00:00 AM).
    public var beginningOfMonth: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.day = 1
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? self
    }
    
    
    /// Returns a new `Date` for the end of the month for this date, with the time set to the end of that day (i.e. 11:59:59 PM).
    public var endOfMonth: Date {
        let date = beginningOfMonth.within(months: 1).within(days: 1)

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = 23
        components.minute = 59
        components.second = 59

        return calendar.date(from: components) ?? self
    }
    
    
    /// Returns the number of weeks in the month that this date falls in.
    public var weeksInMonth: Int {
        let calendar = Calendar.current
        let weekRange = calendar.range(of: .weekOfYear,
                                       in: .month,
                                       for: self)
        return weekRange?.count ?? 0
    }
    
    /// Returns the date as a new `Date` adjusted by the given `years`. The given `years` can be positive or negative.
    public func within(years: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .year, value: years, to: self)!
    }
    
    
    /// Returns the date as a new `Date` adjusted by the given `months`. The given `months` can be positive or negative.
    public func within(months: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: months, to: self)!
    }
    
    
    /// Returns the date as a new `Date` adjusted by the given `weeks`. The given `weeks` can be positive or negative.
    public func within(weeks: Int) -> Date {
        return Date(timeIntervalSince1970: self.timeIntervalSince1970 + (TimeInterval(weeks) * 60 * 60 * 24 * 7))
    }

    
    /// Returns the date as a new `Date` adjusted by the given `days`. The given `days` can be positive or negative.
    public func within(days: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
    
    
    /// Returns the date as a new `Date` adjusted by the given `hours`. The given `hours` can be positive or negative.
    public func within(hours: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: hours, to: self)!
    }
    
    
    /// Returns the date as a new `Date` adjusted by the given `minutes`. The given `minutes` can be positive or negative.
    public func within(minutes: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    
    /// Returns the date as a new `Date` adjusted by the given `seconds`. The given `seconds` can be positive or negative.
    public func within(seconds: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .second, value: seconds, to: self)!
    }
    
    
    /// Returns the date as a new `Date` with the time set to the same time as the given `as` date.
    public func setTime(as date: Date) -> Date {
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        dateComponents.year = dateComponents.year
        dateComponents.month = dateComponents.month
        dateComponents.day = dateComponents.day
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        return calendar.date(from: dateComponents)!
    }

    
    /// Returns the date as a new `Date` with the time set to the given `hours`, `minutes`, and `seconds`. If `nil`
    /// is passed to any of the vales, it keeps the save value as this date.
    public func setTime(hours: Int? = nil, minutes: Int? = nil, seconds: Int? = nil) -> Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        dateComponents.year = dateComponents.year
        dateComponents.month = dateComponents.month
        dateComponents.day = dateComponents.day
        dateComponents.hour = hours ?? dateComponents.hour
        dateComponents.minute = minutes ?? dateComponents.minute
        dateComponents.second = seconds ?? dateComponents.second
        return calendar.date(from: dateComponents)!
    }


    public func formattedAs(_ format: DateAndTimeFormat = .dateAndTime) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = format.rawValue
        return dateFormatterPrint.string(from: self)
    }

    /// A static convience variable that contains a computed `String` array of localized, abbreviated weekday labels ("Sun", "Mon", "Tue", etc.)
    public static var abbreviatedWeekDayLabels: [String] {
        if privateLocalizedWeekDayLabels == nil {
            privateLocalizedWeekDayLabels = [String]()
            let firstDayOfWeek = Date.currentDateAndTime.beginningOfWeek
            for weekDay in 0..<7 {
                privateLocalizedWeekDayLabels?.append(firstDayOfWeek.within(days: weekDay).formattedAs(.abbreviatedWeekDay))
            }
        }
        return privateLocalizedWeekDayLabels!
    }
}

/// Common date formats, defined as an `enum` of strings, for implementing type-checked date formatting code.
public enum DateAndTimeFormat: String {
    case utc = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    case monthAndYear = "MMMM yyyy"
    case yearMonthDay = "yyyy-MM-dd"
    case yearMonthDayShort = "yyMMdd"
    case monthDayYear = "MMMM d, yyyy"
    case abbreviatedMonthDayYear = "MMM d, yyyy"
    case weekDay = "EEEE"
    case abbreviatedWeekDay = "EEE"
    case monthAndDayOfMonth = "MMMM d"
    case abbreviatedMonthAndDayOfMonth = "MMM d"
    case hourMinutes = "h:mm aa"
    case hourMinutesSeconds = "hh:mm:ss aa"
    case dateAndTime = "MMM d, yyyy hh:mm:ss aa"
}

/// Private global storage for localized weekday labels.
private var privateLocalizedWeekDayLabels: [String]? = nil

/// A private class used to help support a simulated current device date and time for development and testing purposes.
/// See `currentDateAndTime`, `simulateCurrentDateAndTime()`, and `restoreCurrentDateAndTime()`.
private class CurrentDateAndTime {

    var year: Int? = nil
    var month: Int? = nil
    var day: Int? = nil
    var hour: Int? = nil
    var minute: Int? = nil
    var second: Int? = nil

    var date: Date {
        var date = Date.now
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.year = year ?? components.year
        components.month = month ?? components.month
        components.day = day ?? components.day
        components.hour = hour ?? components.hour
        components.minute = minute ?? components.minute
        components.second = second ?? components.second
        date = calendar.date(from: components) ?? date
        return date
    }
    
    func set(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        self.year = year
        self.month = month
        self.day = day
        self.hour = hour
        self.minute = minute
        self.second = second
    }

    func useActualDateAndTime() {
        set() // passing no parammeters defaults all date components to nil, which causes the actual device date to be used.
    }

}
/// Private global storage for maintaining a simulated current date and time for the device.
private var deviceCurrentDateAndTime = CurrentDateAndTime()


