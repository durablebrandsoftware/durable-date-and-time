//
//  Created by Shawn McKee on 7/29/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

/// The internal SwiftUI view that renders calendar views for the `DateAndTimeSelector`, including the navigation
/// UI for moving between months and returning back to "today".
struct DateAndTimeCalendarView: View {
    
    @Binding private var selectedDate: Date
    @State private var navigationDate: Date
    
    /// The configuration passed by the selector to help render the calendar view.
    private var configuration: DateAndTimeSelectorConfiguration

    @State private var calendarCells = [DateAndTimeSelectorCalendarCell]() // The current date cells being displayed in the calendar view, one for each day in the month.

    private var tintColor: Color = .accentColor
    private var foregroundColor: Color { return (colorScheme == .light ? Color.black : Color.white) }
    private var backgroundColor: Color { return (colorScheme == .light ? Color.white : Color.black) }
    
    private var textColor: Color { return (colorScheme == .light ? foregroundColor : foregroundColor) }
    private var pastTextColor: Color { return (colorScheme == .light ? foregroundColor.opacity(0.25) : foregroundColor.opacity(0.18)) }
    private var fillColor: Color { return (colorScheme == .light ? textColor.opacity(0.15) : textColor.opacity(0.3)) }
    private var pastFillColor: Color { return (colorScheme == .light ? textColor.opacity(0.045) : textColor.opacity(0.1)) }
    private var overlyFullDayFillColor: Color { return (colorScheme == .light ? Color(red: 1.00, green: 0.82, blue: 0.48) : Color(red: 0.65, green: 0.50, blue: 0.22)) }
    private var extremelyFullDayFillColor: Color { return (colorScheme == .light ? Color(red: 1.00, green: 0.49, blue: 0.45) : Color(red: 0.70, green: 0.23, blue: 0.20)) }

    /// The size of the selection ring around the selected date in the calendar view.
    private let selectedDateRingThickness: CGFloat = 3
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme

    
    /// The designated initializer for the `DateAndTimeCalendarView`, requiring a binding
    /// to the `Date` currently selected, and the selector's `DateAndTimeSelectorConfiguration` to
    /// assist it with rendering.
    public init(date: Binding<Date>, configuration: DateAndTimeSelectorConfiguration) {
        self.configuration = configuration
        self._selectedDate = date
        self._navigationDate = State(initialValue: date.wrappedValue)
    }


    /// Returns the fully composed `DateAndTimeCalendarView` view.
    var body: some View {
        GeometryReader { geometry in
            buildCalendarView()
        }
    }
    
    
    /// The internal view builder for creating the the actual calendar view, including its navigation.
    private func buildCalendarView() -> some View {
        var selectTodayText = "Today"
        let selectTodayIsActive = !(selectedDate.beginningOfDay == Date.today && navigationDate.isThisMonth)
        if selectTodayIsActive { selectTodayText = "Select Today" }
        
        return VStack(spacing: 0) {
            HStack {
                Button {
                    navigationDate = navigationDate.within(months: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(tintColor)
                }
                .buttonStyle(.plain)
                Spacer()
                VStack {
                    Text(navigationDate.formattedAs(.monthAndYear))
                        .font(Font.system(.headline))
                    Button {
                        if selectTodayIsActive {
                            select(date: Date.currentDateAndTime.beginningOfDay)
                        }
                    } label: {
                        Text(selectTodayText)
                            .font(Font.system(.subheadline))
                            .foregroundColor(selectTodayIsActive ? tintColor : foregroundColor)
                    }
                    .buttonStyle(.plain)
                    
                }
                Spacer()
                Button {
                    navigationDate = navigationDate.within(months: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(tintColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 25)
            .padding(.bottom, 8)
            
            GeometryReader { geometry in
                buildCalendarGrid(geometry: geometry)
            }

        }
        .padding(.leading, 15)
        .padding(.trailing, 15)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    
    /// The internal view builder for creating the calendar grid with the day-of-week headers and the cell views
    /// for each day in the calendar.
    private func buildCalendarGrid(geometry: GeometryProxy) -> some View {
        let weeksInMonth = navigationDate.weeksInMonth
        let headerHeight = geometry.size.height / 6
        let cellWidth = geometry.size.width / 7
        let cellHeight = (geometry.size.height - headerHeight) / CGFloat(weeksInMonth)
        
        return VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Date.abbreviatedWeekDayLabels, id: \.self) { weekDayLabel in
                    Text(weekDayLabel.uppercased())
                        .font(Font.system(size: 14, weight: .medium))
                        .frame(width: cellWidth, height: headerHeight)
                        .padding(0)
                }
            }

            ZStack {
                ForEach(Array(calendarCells.enumerated()), id: \.offset) { index, cell in
                    buildCalendarCellView(cell: cell, cellWidth: cellWidth, cellHeight: cellHeight)
                        .offset(offsetForIndex(index, cellWidth: cellWidth, cellHeight: cellHeight))
                }
            }
            .frame(width: geometry.size.width, height: cellHeight * CGFloat(weeksInMonth), alignment: .topLeading)
        }
        .padding(0)
        .onAppear() {
            calendarCells = generateCalendarCellData(configuration.dataSource)
        }
        .onChange(of: navigationDate) { newValue in
            calendarCells = generateCalendarCellData(configuration.dataSource)
        }

    }
    
    
    /// The internal view builder for generating the view for an individual cell in the calendar grid.
    private func buildCalendarCellView(cell: DateAndTimeSelectorCalendarCell, cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        
        let isToday = cell.date.isToday
        let isInThePast = cell.date.isInThePast
        let isThisMonth = cell.date.isInSameMonthAs(date: navigationDate)
        let isSelectedDate = cell.date.beginningOfDay == selectedDate.beginningOfDay
        
        var selectionRingSize = cellWidth
        if selectionRingSize > cellHeight { selectionRingSize = cellHeight }
        selectionRingSize = abs(selectionRingSize - selectedDateRingThickness)
        
        var textColor = self.textColor
        var textWeight: Font.Weight = .light
        if isToday { textWeight = .black }

        var fillColor = self.fillColor
        var fillSize = 0.0
        if (configuration.dataSource != nil) {
            if let data = cell.data {
                if data.count > 0 {
                    if !isToday { textWeight = .medium }
                    let count = data.count
                    let percent = Double(count) / Double(configuration.fullDayCount)
                    
                    let min = CGFloat(selectionRingSize * 0.1)
                    let max = selectionRingSize
                    
                    fillSize = min + ((max - min) * percent)
                    if fillSize > max { fillSize = max }
                    
                    if percent > 1.0 { fillColor = overlyFullDayFillColor }
                    if percent > 1.5 { fillColor = extremelyFullDayFillColor }
                }
            }
        }
        
        if isInThePast {
            fillColor = pastFillColor
            textColor = pastTextColor
        }

        return ZStack {
            if (isThisMonth) {
                if fillSize > 0 {
                   Circle()
                        .fill(fillColor)
                        .frame(width: fillSize, height: fillSize)
                }
                Text("\(cell.date.day)")
                    .font(Font.system(size: 17, weight: textWeight))
                    .foregroundColor(textColor)
                if isSelectedDate {
                    Circle()
                        .stroke(tintColor, lineWidth: selectedDateRingThickness)
                        .frame(width: selectionRingSize, height: selectionRingSize)
                }
            }
        }
        .frame(width: cellWidth, height: cellHeight)
        .onTapGesture {
            select(date: cell.date)
        }

    }

    
    /// Internal helper function called whenever a new date in the calendar view is selected
    /// to update the component's state.
    private func select(date: Date) {
        selectedDate = date.setTime(as: selectedDate)
        navigationDate = date.setTime(as: selectedDate)
    }


    /// Internal helper function to calculate the X and Y offset of an individual day cell in the calendar view based on
    /// the index of the cell.
    private func offsetForIndex(_ index: Int, cellWidth: CGFloat, cellHeight: CGFloat) -> CGSize {
        let y = index / 7
        let x: Int = index % 7
        return CGSize(width: CGFloat(x) * cellWidth, height: CGFloat(y) * cellHeight)
    }
    
    
    /// Internal helper function that generates all the cell data for the calendar view gride, one cell for every day
    /// of the month that is currently being displayed.
    private func generateCalendarCellData(_ dataSource: DateAndTimeSelectorDataSource? = nil) -> [DateAndTimeSelectorCalendarCell] {
        
        let beginningOfMonth = navigationDate.beginningOfMonth
        let endOfMonth = navigationDate.endOfMonth
        
        let events = (dataSource?.getDateAndTimeData(starting: beginningOfMonth, ending: endOfMonth) ?? DateAndTimeSelectorEvents()).events

        let weeksInMonth = navigationDate.weeksInMonth
        var newCells = [DateAndTimeSelectorCalendarCell]()
        var cellDate = beginningOfMonth.beginningOfWeek
        
        for _ in 0..<(weeksInMonth * 7) {
            newCells.append(DateAndTimeSelectorCalendarCell(date: cellDate, data: events[cellDate.formattedAs(.abbreviatedMonthDayYear)]))
            cellDate = cellDate.within(days: 1)
        }
        
        return newCells
    }
    
    
    /// Internal helper function that returns whether or not the current month being displayed by the calendar view is
    /// the month of the current device date.
    private var inCurrentMonthx: Bool {
        return (navigationDate.beginningOfDay.month == Date.currentDateAndTime.beginningOfDay.month)
    }
    
    
    /// Internal helper function that returns whether or not the current year being displayed by the calendar view is
    /// the month of the current device date.
    private var inCurrentYearx: Bool {
        return (navigationDate.beginningOfDay.year == Date.currentDateAndTime.beginningOfDay.year)
    }

}


private struct DateAndTimeSelectorCalendarCell: Identifiable {
    public var id: String = UUID().uuidString
    public var date: Date
    public var data: [DateAndTimeSelectorEvent]? = nil
}

