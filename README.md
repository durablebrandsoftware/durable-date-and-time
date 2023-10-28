# **DurableDateAndTime** Swift Package

## Overview
A suite of useful date and time logic and utilities, plus a data-driven `DateAndTimeSelector` SwiftUI component for selecting dates and times.

**WARNING/NOTES:**
* This is an early, **PRE-RELEASE VERSION**, not ready for production apps. 
* Time selection in the `DateAndTimeSelector` is only available for iOS. It uses a picker wheel to select the time, which is not available on macOS. An implementation for this will be added later.

## Installation
This code is provided as **Swift Package** you can add to your Xcode project's "Package Dependencies" using the following URL:

<code>https://github.com/durablebrandsoftware/durable-date-and-time</code>

Or you can simply download the code in the `Sources` folder and add the files directly to your project if you do not want the versioning and update management provided by **Swift Package Manager**.


## Extended `Date` Functionality

Included in this package is a Swift `extension` to Apple's built-in `Date`, providing a suite of new logic and date manipulaiton functionality for working with dates and times. See `Date+Extension.swift` for all of the additional functionality that has been added.

In particular, consider switching to using the new `Date.currentDateAndTime` static property whenever your app needs the device's current date and time, instead of instantiating a new date (via `Date()`) or using `Date.now`.

Doing this throughout your code will allow you to override and simulate a specific current date and time to assist with development and testing date-related functionality in your app. Call the `Date.simulateCurrentDateAndTime(...)` static function to simulate a current date and time, and `Date.restoreCurrentDateAndTime()` reset it to the real date and time. 

Note that the `DateAndTimeSelector` (see below) uses `Date.currentDateAndTime` internally so that you can control the current date and time it uses as well.

## A SwiftUI `DateAndTimeSelector` Component

Also include in the package is a `DateAndTimeSelector` component for SwiftUI that provides a UI control for selecting dates and times. It is modeled after Apple's `DatePicker` in that it provides both an **expanded (inline) version** that can be displayed directly inside a view, and a **button version** that displays a button that opens a popover for picking dates and times.

The primary benefit of the new `DateAndTimeSelector` is its ability to visualize activities in its calendar view to help users see how busy each day is. This is accomplished by providing the selector with an optional `DateAndTimeSelectorDataSource` via the `.dataSource(...)` view modifier:

The following snippet, for example, shows how you would embed the expanded version of the selector in a `VStack` using the selector's `.expanded()` modifier. (Removing the `.expanded()` modifier will cause the selector to display as a button in the `VStack`, which will open a popover for choosing the date.)

```
import DurableDateAndTime
...
@State private var selectedDate: Date = Date.currentDateAndTime
private var myDataSource: DateAndTimeSelectorDataSource!
...
VStack {
    DateAndTimeSelector(selectedDate: $selectedDate)
        .dateOnly()
        .expanded()
        .dataSource(myDataSource)
        .frame(height: 350)
}
```

The `.dateOnly()` modifier restricts the UI of the selector to date selection only, keeping the time of `selectedDate` unchanged. Use the `.timeOnly()` modifier to restrict the UI to time selection, leaving the date unchanged. By default, the selector will show UI for selecting both a date and time.

The `.dataSource(...)` modifier is how you supply a `DateAndTimeSelectorDataSource` to the selector, allowing it to visualize dates in the calendar view.

Also note that you may often want to provide a `.frame(height:)` (and perhaps a `width:` on iPad) for the selector when it is used in its expanded form so that it is constrained to a particular area of your view. Otherwise it will fill the available space.

## Demo

There is a more complete Xcode demo project (`Demo/Demo.xcodeproj`) included in this repo that you can compile and run to see the `DateAndTimeSelector` SwiftUI component working in all its various configurations. See the `DemoView.swift` file for the code that generates those variations.

![demo](README_assets/demo.png)

