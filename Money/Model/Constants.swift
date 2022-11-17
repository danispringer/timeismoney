//
//  Constants.swift
//  Money
//
//  Created by dani on 11/17/22.
//

import UIKit
// swiftlint:disable identifier_name
let UD: UserDefaults = UserDefaults(suiteName: "io.danispringer.github.money")!
let NC = NotificationCenter.default
// swiftlint:enable identifier_name
let calendar = Calendar.current

let secondsInADay: Double = 24 * 60 * 60

struct Const {
    struct UDef {
        static let hourlyRate = "hourlyRate"
        static let startTime = "startTime"
        static let endTime = "endTime"
    }
    struct UIMsg {
        static let timeTillWorkdayEnds = "Time till workday ends:"
        static let timeTillWorkdayBegins = "Time till workday begins:"
        static let dailyMakeableRemaining = "Daily Makeable Remaining:"
    }
}
