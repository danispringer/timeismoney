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

    struct IDIB {
        static let tutorialViewController = "TutorialViewController"
    }

    struct UDef {
        static let hourlyRate = "hourlyRate"
        static let startTime = "startTime"
        static let endTime = "endTime"
        static let userSawTutorial = "userSawTutorial"
    }

    struct UIMsg {
        static let timeToWorkEnd = "Workday ends in:"
        static let timeToWorkStart = "Workday starts in:"
        static let dailyMakeableRemaining = "How Much More You Can Make Today:"
        static let dailyOutsideWorkingHours = "How Much You Can Make Daily:"
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
        static let tutorial = "Tutorial"
    }
}
