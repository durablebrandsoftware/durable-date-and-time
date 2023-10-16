//
//  Created by Shawn McKee on 7/29/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

/// The internal popover view that the `DateAndTimeSelector` opens when the date selector button is tapped.
struct DateAndTimeSelectorCalendarPopover: View {
    
    @Binding private var selectedDate: Date
    private var configuration: DateAndTimeSelectorConfiguration
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    /// The designated initializer for the `DateAndTimeSelectorCalendarPopover`, requiring a binding
    /// to the `Date` currently selected, and the selector's `DateAndTimeSelectorConfiguration` to
    /// assist it with rendering.
    public init(selectedDate: Binding<Date>, configuration: DateAndTimeSelectorConfiguration) {
        self.configuration = configuration
        self._selectedDate = selectedDate
    }
    
    /// Returns the fully composed `DateAndTimeSelectorCalendarPopover` view.
    public var body: some View {
        if DateAndTimeSelector.isOnSmallScreen {
            buildSmallScreenCalendarView()
        }
        else {
            buildLargeScreenCalendarView()
        }
    }
    
    /// The internal view builder for creating the the small screen version of the date selector.
    private func buildSmallScreenCalendarView() -> some View {
        DateAndTimeSelector(selectedDate: $selectedDate)
            .dateOnly()
            .expanded()
            .dataSource(configuration.dataSource)
            .dismissOnSelection()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
   }
    
    /// The internal view builder for creating the the large screen version of the date selector.
    private func buildLargeScreenCalendarView() -> some View {
        DateAndTimeSelector(selectedDate: $selectedDate)
            .dateOnly()
            .expanded()
            .dataSource(configuration.dataSource)
            .dismissOnSelection()
            .frame(width: 450, height: 350)
    }

}

