//
//  Created by Shawn McKee on 7/29/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import Foundation

/// The interface to the optional data source that can be provided to the `DateAndTimeSelector`
/// which provides the selector with event data to be visualized.
public protocol DateAndTimeSelectorDataSource {
    
    /// The function that all data sources must implement, providing the `DateAndTimeSelector` with
    /// `DateAndTimeSelectorActivities` to be displayed. The activities returned should only be for the dates
    /// on and between the given `starting` and `ending` dates.
    func getDateAndTimeData(starting: Date, ending: Date) -> DateAndTimeSelectorActivities
}

