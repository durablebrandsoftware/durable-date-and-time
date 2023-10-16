//
//  Created by Shawn McKee on 9/7/23.
//  Provided by Durable Brand Software LLC.
//  http://durablebrand.software
//

import SwiftUI

@main
struct DemoApp: App {
    var body: some Scene {
        WindowGroup {
            DemoView()
            #if os(OSX)
                .frame(minWidth: 800, minHeight: 700)
            #endif
        }
    }
}
