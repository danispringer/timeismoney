//
//  Constants.swift
//  Money
//
//  Created by Daniel Springer on 11/17/22.
//  Copyright © 2024 Daniel Springer. All rights reserved.
//

import UIKit
// swiftlint:disable identifier_name
let UD: UserDefaults = UserDefaults.standard
let NC = NotificationCenter.default
// swiftlint:enable identifier_name
let calendar = Calendar.current

var startDate: Date!
var endDate: Date!

struct Const {

    struct API {
        static let key = "exhaust"
        static let code = "baubles"
        static let user = "@"
        static let password = "_01"
    }

    struct IDIB {
        static let tutorialViewController = "TutorialViewController"
        static let settingsViewController = "SettingsViewController"
    }

    struct UDef {
        static let hourlyRate = "hourlyRate"
        static let startTime = "startTime"
        static let endTime = "endTime"
        static let userSawTutorial = "userSawTutorial"
        static let weekdaysIWorkOn = "weekdaysIWorkOn"
    }

    struct UIMsg {
        static let timeToWorkEnd = "Workday ends in:"
        static let timeToWorkStart = "Workday starts in:"
        static let dailyMakeableRemaining = "How Much More You Can Make Today:"
        static let dailyOutsideWorkingHours = "How Much You Can Make Daily:"
        static let shareTitleMessage = "Tell a friend"
        static let leaveReview = "Leave a review"
        static let contact = "Email Me"
        static let apple = "icloud.com"
        static let showAppsButtonTitle = "More By Daniel Springer"
        static let appsLink = "https://apps.apple.com/developer/id1402417666"
        static let appVersion = "CFBundleShortVersionString"
        static let version = "v."
        static let appName = "Motivator - Money Counter"
        static let reviewLink = "https://apps.apple.com/app/id6444535220?action=write-review"
        static let tutorial = "Tutorial"
//        static let weekdaysNamesArr = ["S", "M", "T", "W", "T", "F", "S"]
        static let aWeekdayAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(for: .body, weight: .bold)
        ]
    }
}
