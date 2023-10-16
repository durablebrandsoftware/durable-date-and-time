//
//  Created by Shawn McKee on 7/29/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

/// The internal popover view that the `DateAndTimeSelector` opens when the time selector button is tapped.
struct DateAndTimeSelectorTimePopover: View {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?

    @Binding private var selectedDate: Date
    private var configuration: DateAndTimeSelectorConfiguration

    @State private var hourSelection = 1
    let hourChoices = [Int](1...12)
    @State private var minuteSelection = 0
    let minuteChoices = [Int](0...59)
    @State private var meridiemSelection = 0
    let meridiumChoices = ["AM","PM"]

    /// The designated initializer for the `DateAndTimeSelectorTimePopover`, requiring a binding
    /// to the `Date` currently selected, and the selector's `DateAndTimeSelectorConfiguration` to
    /// assist it with rendering.
    public init(date: Binding<Date>, configuration: DateAndTimeSelectorConfiguration) {
        self.configuration = configuration
        self._selectedDate = date
        
        var meridium = 0
        var hour = (date.wrappedValue).hour
        if hour > 12 {
            hour -= 12
            meridium = 1
        }

        self._hourSelection = State(initialValue: hour - 1)
        self._minuteSelection = State(initialValue: (date.wrappedValue).minute)
        self._meridiemSelection = State(initialValue: meridium)
    }

    /// Returns the fully composed `DateAndTimeSelectorTimePopover` view.
    public var body: some View {
        if DateAndTimeSelector.isOnSmallScreen {
            buildSmallScreenTimeView()
        }
        else {
            buildLargeScreenTimeView()
        }
    }

    /// The internal view builder for creating the the small screen version of the time selector.
    private func buildSmallScreenTimeView() -> some View {
        buildTimeView()
    }

    /// The internal view builder for creating the the large screen version of the time selector.
    private func buildLargeScreenTimeView() -> some View {
        buildTimeView()
            .frame(width: 250, height: 250)
    }

    /// The internal view builder for creating the the actual time selector.
    private func buildTimeView() -> some View {
        VStack {
            #if os(iOS)
            HStack(spacing: 0) {
                Picker("", selection: $hourSelection) {
                    ForEach(0..<hourChoices.count, id: \.self) { index in
                        Text("\(hourChoices[index])")
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                
                Text(":")

                Picker("", selection: $minuteSelection) {
                    ForEach(0..<minuteChoices.count, id: \.self) { index in
                        Text(doubleDigitMinutes(minuteChoices[index]))
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()

                Picker("", selection: $meridiemSelection) {
                    ForEach(0..<meridiumChoices.count, id: \.self) { index in
                        Text("\(meridiumChoices[index])")
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
            }
            #endif
        }
        .frame(width: 225, alignment: .bottom)
        .onChange(of: hourSelection) { _ in
            updateDateWithNewTime()
        }
        .onChange(of: minuteSelection) { _ in
            updateDateWithNewTime()
        }
        .onChange(of: meridiemSelection) { _ in
            updateDateWithNewTime()
        }
    }
    
    /// Internal helper function called whenever one of the spinner wheels in the selector has stopped spinning
    /// and creates a new time from each of the wheel values.
    private func updateDateWithNewTime() {
        let hours = meridiemSelection == 0 ? (hourSelection + 1) : (hourSelection + 13)
        let minutes = minuteSelection
        selectedDate = selectedDate.setTime(hours: hours, minutes: minutes)
    }
    
    /// Internal helper function to add a leading zero if the minutes is less than 10.
    private func doubleDigitMinutes(_ minutes: Int) -> String {
        return minutes < 10 ? "0\(minutes)" : "\(minutes)"
    }



}
