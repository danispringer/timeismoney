//
//  Constants.swift
//  Money
//
//  Created by dani on 11/17/22.
//

import UIKit
// swiftlint:disable identifier_name
let UD: UserDefaults = UserDefaults.standard
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
        static let dailyOutsideWorkingHours = """
        (💤 Outside working hours 💤)

        Your Daily Makeable:
        """
        static let shareTitleMessage = "Tell a friend"
        static let leaveReview = "Leave a review"
        static let contact = "Email Me"
        static let emailString = "00.segue_affix@icloud.com"
        static let showAppsButtonTitle = "More apps"
        static let appsLink = "https://apps.apple.com/developer/id1402417666"
        static let appVersion = "CFBundleShortVersionString"
        static let version = "v."
        static let appName = "Motivator"
        static let reviewLink = "https://apps.apple.com/app/id6444535220?action=write-review"
    }
}
