//
//  Created by Shawn McKee on 9/7/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import Foundation
import DurableDateAndTime

class DemoAppSampleData: DateAndTimeSelectorDataSource {
    
    static var data: DateAndTimeSelectorEvents!
    
    func getDateAndTimeData(starting: Date, ending: Date) -> DateAndTimeSelectorEvents {
        
        if DemoAppSampleData.data == nil {
            DemoAppSampleData.data = DateAndTimeSelectorEvents()

            add(count: 5, inDays: -3)   // Three days ago
            add(count: 7, inDays: -2)   // Two days ago
            add(count: 8, inDays: 0)    // Today
            add(count: 1, inDays: 1)    // Tomorrow
            add(count: 16, inDays: 4)   // In four days, extreamly busy
            add(count: 11, inDays: 5)   // In five days, overly busy
            add(count: 10, inDays: 8)   // In eight days, full day
            add(count: 7, inDays: 10)   // In ten days
        }

        return DemoAppSampleData.data
    }
    
    private func add(count: Int, inDays: Int) {
        for _ in 0..<count {
            DemoAppSampleData.data.add(event: Date.currentDateAndTime.within(days: inDays))
        }
    }
    
}
