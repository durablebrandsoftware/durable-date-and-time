//
//  Created by Shawn McKee on 7/29/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

/// A configurable, data-driven SwiftUI component for selecting dates and times.
///
/// By default, the selector appears as a button that opens a popover with the selector.
/// It can be set to display expanded, inline within its container view with the `.expanded()` modifier.
///
/// By default, the selector allows for both a date and a time selection. You can limit it to either date or time
/// selection with the `.dateOnly()` and `.timeOnly()` modifiers.
///
/// The selector's calendar view can show a visual representation of how
/// busy each day is if a `DateAndTimeSelectorDataSource` is provided
/// with the `.dataSource()` modifier.
///
/// By default, the selector will stay visible, allowing users to keep selecting dates and times.
/// You can have the selector attempt to dismiss its container view as soon as the user makes a selection
/// with the `.dismissOnSelection()` modifier.
public struct DateAndTimeSelector: View {
    
    /// Internal state for the date and time that's currently being selected, and the date shown in the calendar view
    /// with the selection ring...
    @Binding private var selectedDate: Date

    /// Internal state for whether or not the calendar popover is currently being presented for the date selector button.
    @State private var calendarPopoverIsPresented = false

    /// Internal state for whether or not the time popover is currently being presented for the time selector button.
    @State private var timePopoverIsPresented = false
    
    /// Internal configuration details for the selector (whether it's expanded or not, it's data source, full day count, etc.)
    /// This configuration is initialized and set up internally to default values, and is modified by the calling code with its
    /// modifiers.
    private var configuration = DateAndTimeSelectorConfiguration()

    private var tintColor: Color = .accentColor
    private var foregroundColor: Color { return (colorScheme == .light ? Color.black : Color.white) }
    private var backgroundColor: Color { return (colorScheme == .light ? Color.white : Color.black) }
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    
    /// The designated initializer for the `DateAndTimeSelector`, requiring the initial `Date` that will be selected by default.
    public init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    
    /// Returns the fully composed `DateAndTimeSelector` view.
    public var body: some View {
        ZStack {
            if configuration.isExpanded {
                expandedView()
            } else {
                buttonView()
            }
        }
    }
    
    
    /// Internal helper function that returns the expanded version of the `DateAndTimeSelector` view.
    private func expandedView() -> some View {
        return VStack(spacing: 4) {
            if configuration.components == .date || configuration.components == .dateAndTime {
                DateAndTimeCalendarView(date: $selectedDate, configuration: configuration)
                    .onChange(of: selectedDate) { newValue in
                        if configuration.shouldDismissOnSelection {
                            dismiss()
                        }
                    }
            }
            if configuration.components == .time || configuration.components == .dateAndTime {
                HStack {
                    timeButtonView()
                }
            }
        }
    }
        
    
    /// Internal helper function that returns the button version of the `DateAndTimeSelector` view.
    private func buttonView() -> some View {
        HStack(spacing: 4) {
            if configuration.components == .date || configuration.components == .dateAndTime { dateButtonView() }
            if configuration.components == .time || configuration.components == .dateAndTime { timeButtonView() }
        }
    }
    
    
    /// Internal helper function that returns the date button used in the button version of
    /// the `DateAndTimeSelector` view.
    private func dateButtonView() -> some View {
        Button {
            calendarPopoverIsPresented = true
        } label: {
            ZStack {
                Text(selectedDate.formattedAs(.abbreviatedMonthDayYear))
                    .font(Font.system(.body))
                    .padding(5)
                    .padding(.leading, 8)
                    .padding(.trailing, 8)
                    .background(foregroundColor.opacity(0.05))
                    .foregroundColor(tintColor)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5,height: 8)))
            }        }
        .buttonStyle(.plain)
        .popover(isPresented: $calendarPopoverIsPresented) {
            DateAndTimeSelectorCalendarPopover(selectedDate: $selectedDate, configuration: configuration)
                .presentationDetents([.fraction(0.4), .medium])
        }
    }
    
    
    /// Internal helper function that returns the time button used in the button version of
    /// the `DateAndTimeSelector` view, and the `.dateAndTime` expended version.
    private func timeButtonView() -> some View {
        Button {
            timePopoverIsPresented = true
        } label: {
            ZStack {
                Text(selectedDate.formattedAs(.hourMinutes))
                    .font(Font.system(.body))
                    .padding(5)
                    .padding(.leading, 8)
                    .padding(.trailing, 8)
                    .background(foregroundColor.opacity(0.05))
                    .foregroundColor(tintColor)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5,height: 8)))
            }        }
        .buttonStyle(.plain)
        .popover(isPresented: $timePopoverIsPresented) {
            DateAndTimeSelectorTimePopover(date: $selectedDate, configuration: configuration)
                .presentationDetents([.height(200)])
        }
    }
    
    
// MARK: - View Modifiers for the DateAndTimeSelector
    
    
    /// This view modifier causes the `DateAndTimerSelector` to only show UI for selecting a date.
    /// (Default is to show both date and time UI.)
    public func dateOnly() -> DateAndTimeSelector {
        let modifiedView = self
        modifiedView.configuration.components = .date
        return modifiedView
    }
    
    
    /// This view modifier causes the `DateAndTimerSelector` to only show UI for selecting a time.
    /// (Default is to show both date and time UI.)
    public func timeOnly() -> DateAndTimeSelector {
        let modifiedView = self
        modifiedView.configuration.components = .time
        return modifiedView
    }
    
    
    /// This view modifier causes the `DateAndTimeSelector` to be displayed fully expanded within
    /// it's container view, instead of being presented as a button. (Default is to show the selector as a button.)
    public func expanded() -> DateAndTimeSelector {
        let modifiedView = self
        modifiedView.configuration.isExpanded = true
        return modifiedView
    }
    
    
    /// This view modifier provides the `DateAndTimeSelector` with an optional data source
    /// (`DateAndTimeSelectorDataSource`) so it can display visuals in the calendar view
    /// indicating which dates have events.
    public func dataSource(_ dataSource: DateAndTimeSelectorDataSource?) -> DateAndTimeSelector {
        let modifiedView = self
        modifiedView.configuration.dataSource = dataSource
        return modifiedView
    }
    
    
    /// This view modifier sets the value indicating how many events in a day make it a "full day". The selector
    /// bases its visualizations on this number to determine how large to make the circle in the calendar view,
    /// and whether or not to show the circle as yellow or red for days that have more events than this count.
    /// (The default is 10.)
    public func fullDayCount(_ count: Int) -> DateAndTimeSelector {
        let modifiedView = self
        modifiedView.configuration.fullDayCount = count
        return modifiedView
    }

    
    /// This view modifier causes the `DateAndTimeSelector` to attempt to dismiss its container view
    /// when a selection is made. (Default is leave the selector visible and allow selecting other dates.)
    public func dismissOnSelection() -> DateAndTimeSelector {
        let modifiedView = self
        modifiedView.configuration.shouldDismissOnSelection = true
        return modifiedView
    }
    
    
    public static var isOnSmallScreen: Bool {
#if os(OSX)
        return false
#else
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        } else {
            return true
        }
#endif
    }


}



// MARK: - Support Enums and Structs

/// An `enum` with the components of a `Date` that is available for selecting with the `DateAndTimeSelector`.
public enum DateAndTimeSelectorComponents {
    
    /// Allow both the date and the time of the `Date` to be selected by the `DateAndTimeSelector`.
    /// This is the default behavior of the selector.
    case dateAndTime
    
    /// Allow only the date of the `Date`  to be selected by the `DateAndTimeSelector`,
    /// keeping the time unchanged.
    case date
    
    /// Allow only the time of the `Date`  to be selected by the `DateAndTimeSelector`,
    /// keeping the date unchanged.
    case time
}


/// The internal configuration used by the selector and its various supporting views.
class DateAndTimeSelectorConfiguration {
    
    /// The date components that the selector should allow to be selected.
    var components: DateAndTimeSelectorComponents = .dateAndTime
    
    /// Whether the selector should be presented fully expended inline within its container view, or as a button.
    var isExpanded: Bool = false
    
    /// The data source, if provided, that gives the selector the event data it needs for visualization in the calendar view.
    var dataSource: DateAndTimeSelectorDataSource? = nil
    
    /// The number of events in a day that is considered a full day.
    var fullDayCount = 10
    
    /// Whether or not the selector should attempt ti dismiss its container view when a date is selected.
    var shouldDismissOnSelection: Bool = false
}


// MARK: - Data Used By the DateAndTimeSelector

/// The complete set of event data the selector should use to visualize events on the calendar. This is the struct
/// that should be returned by the optional `DateAndTimeSelectorDataSource` provided to the selector
/// via its `getDateAndTimeData()` function.
public struct DateAndTimeSelectorEvents {
    
    public var events = [String: [DateAndTimeSelectorEvent]]()
    
    public init() {}
    
    public mutating func add(event: Date) {
        let key = event.formattedAs(.abbreviatedMonthDayYear)
        var dateEvents = events[key]
        if dateEvents == nil { dateEvents = [DateAndTimeSelectorEvent]() }
        dateEvents?.append(DateAndTimeSelectorEvent())
        events[key] = dateEvents
    }
}


/// The event data that's stored for each individual event on each day within the
/// selector's `DateAndTimeSelectorEvents` data source.
public struct DateAndTimeSelectorEvent {
    public init() {}
    // TODO: For future use, and future event properites that might help data visualization.
}



