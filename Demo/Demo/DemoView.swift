//
//  Created by Shawn McKee on 9/7/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI
import DurableDateAndTime

struct DemoView: View {
    
    // Some sample data for demonstrating how the `DateAndTimeSelector` visualizes data.
    private var sampleDataSource = DemoAppSampleData()
    
    @State private var expandedSelectorDate: Date
    @State private var dateAndTimeSelectorDate: Date
    @State private var dateOnlySelectorDate: Date
    @State private var timeOnlySelectorDate: Date
    
    init() {
        // An example of how the device's current date and time can be overridden
        // for development and testing purposes. See the comment docs for details
        // (i.e. option-click the function name). Setting "today" to September 7th, 2023...
        Date.simulateCurrentDateAndTime(year: 2023, month: 9, day: 7)
        
        // Now set the dates used by each of the selectors to the
        // new "current" date and time...
        _expandedSelectorDate = State(initialValue: Date.currentDateAndTime)
        _dateAndTimeSelectorDate = State(initialValue: Date.currentDateAndTime)
        _dateOnlySelectorDate = State(initialValue: Date.currentDateAndTime)
        _timeOnlySelectorDate = State(initialValue: Date.currentDateAndTime)
    }

    var body: some View {
        ScrollView {
            
            VStack {
                SelectorHeader(text: "Expanded Date & Time Selector:")
                DateAndTimeSelector(selectedDate: $expandedSelectorDate)
                    .dateOnly() // remove this modifier to include a time selection button.
                    .expanded()
                    .dataSource(sampleDataSource)
                    .frame(height: 350)
            }
            
            
            Divider().padding()
            
            
            VStack {
                SelectorHeader(text: "Date & Time Selector as Button:")
                DateAndTimeSelector(selectedDate: $dateAndTimeSelectorDate)
                    .dataSource(sampleDataSource)
            }
            
            
            VStack {
                SelectorHeader(text: "Date Only Selector as Button:")
                DateAndTimeSelector(selectedDate: $dateOnlySelectorDate)
                    .dateOnly()
                    .dataSource(sampleDataSource)
            }
            
            
            VStack {
                SelectorHeader(text: "Time Only Selector as Button:")
                DateAndTimeSelector(selectedDate: $timeOnlySelectorDate)
                    .timeOnly()
            }
            
        }
    }
}


struct SelectorHeader: View {
    
    public var text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .textCase(.uppercase)
            .opacity(0.25)
            .padding(.top, 20)
    }
    
}

#Preview {
    return DemoView()
}
