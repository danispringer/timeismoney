//
//  HomeViewController.swift
//  Money
//
//  Created by Daniel Springer on 11/13/22.
//

import UIKit
import MessageUI


class HomeViewController: UIViewController, SettingsPresenter, DeclaresVisibility {

    // MARK: Outlets

    @IBOutlet weak var moneyMakeableLabel: UILabel!
    @IBOutlet weak var moneyHelperLabel: UILabel!
    @IBOutlet weak var timeWorkableLabel: UILabel!
    @IBOutlet weak var timeWorkableHelperLabel: UILabel!
    @IBOutlet weak var helpButton: UIBarButtonItem!
    @IBOutlet weak var myToolbar: UIToolbar!


    // MARK: Properties

    // swiftlint:disable identifier_name
    var is😎Visible: Bool = false
    // swiftlint:enable identifier_name

    var timer = Timer()
    let numberFormatterCurrency = NumberFormatter()
    let myDateCompForm = DateComponentsFormatter()
    var startDate: Date!
    var endDate: Date!
    var hourlyRate: Double!

    enum WorkHoursStatus {
        case before
        case during
    }


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if CommandLine.arguments.contains("--moneyScreenshots") {
            // We are in testing mode, make arrangements if needed
            UIView.setAnimationsEnabled(false)
        }

        timer = Timer.scheduledTimer(
            timeInterval: 1.0, target: self,
            selector: #selector(self.tick), userInfo: nil, repeats: true)

        numberFormatterCurrency.numberStyle = .currency
        numberFormatterCurrency.roundingMode = .down

        for label: UILabel in [moneyHelperLabel, timeWorkableHelperLabel,
                               moneyMakeableLabel, timeWorkableLabel] {
            label.text = " "
        }

        fetchWorkHours()
        fetchHourlyRate()

        NC.addObserver(self, selector: #selector(fetchWorkHours),
                       name: .hoursDidChange, object: nil)
        NC.addObserver(self, selector: #selector(fetchHourlyRate),
                       name: .hourlyRateDidChange, object: nil)

        setThemeColorTo(myThemeColor: .systemGreen)
        helpButton.menu = infoMenu()

        myToolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        myToolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        is😎Visible = true

        if !UD.bool(forKey: Const.UDef.userSawTutorial) {
            showHelp()
            UD.set(true, forKey: Const.UDef.userSawTutorial)
        }
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        is😎Visible = false
    }


    // MARK: Helpers

    func showHelp() {

        let tutorialVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(
            withIdentifier: Const.IDIB.tutorialViewController) as! TutorialViewController

        tutorialVC.delegate = self

        present(tutorialVC, animated: true)
    }


    @objc func fetchHourlyRate() {
        hourlyRate = UD.double(forKey: Const.UDef.hourlyRate)
    }


    @objc func fetchWorkHours() {
        guard let startTimeString: String = UD.string(forKey: Const.UDef.startTime) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let startTimeString",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let endTimeString: String = UD.string(forKey: Const.UDef.endTime) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let endTimeString",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        let startTimeH = startTimeString.prefix(2)
        let startTimeM = startTimeString.suffix(2)
        let endTimeH = endTimeString.prefix(2)
        let endTimeM = endTimeString.suffix(2)

        guard let startTimeHourInt: Int = Int(startTimeH) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let startTimeHourInt",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let startTimeMinInt: Int = Int(startTimeM) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let startTimeMinInt",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let endTimeHourInt: Int = Int(endTimeH) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let endTimeHourInt",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let endTimeMinInt: Int = Int(endTimeM) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let endTimeMinInt",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let nextWorkingDate = calendar.date(byAdding: .day,
                                                  value: daysToNextWorkWeekday(),
                                                  to: getNow()) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let nextWorkingDate",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let safeStartDate = calendar.date(bySettingHour: startTimeHourInt,
                                                minute: startTimeMinInt, second: 0,
                                                of: nextWorkingDate) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let safeStartDate",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        guard let safeEndDate = calendar.date(bySettingHour: endTimeHourInt,
                                              minute: endTimeMinInt, second: 0,
                                              of: nextWorkingDate) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "guard let safeEndDate",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        startDate = safeStartDate
        endDate = safeEndDate
    }


    func daysToNextWorkWeekday() -> Int {
        let workdaysArr = getWeekdaysArrBool()
        guard workdaysArr.contains(true) else {
            return 0
        }
        let nowWeekdayInt = getWeekdayIntFrom(someDate: getNow())
        var daysToNextWorkWeekdayInt = 0

        var newArr: [Bool] = []
        var skipTodayBoolInt = 0

        let endTimeString: String = UD.string(forKey: Const.UDef.endTime)!
        let endTimeH = endTimeString.prefix(2)
        let endTimeM = endTimeString.suffix(2)
        let endTimeHourInt: Int = Int(endTimeH)!
        let endTimeMinInt: Int = Int(endTimeM)!

        if getNow() > calendar.date(bySettingHour: endTimeHourInt,
                                    minute: endTimeMinInt,
                                    second: 0, of: getNow())! {
            skipTodayBoolInt = 1
        }

        newArr += workdaysArr[(nowWeekdayInt+skipTodayBoolInt)...]
        newArr += workdaysArr[...(nowWeekdayInt-1)]

        for day in newArr {
            if day {
                break
            } else {
                daysToNextWorkWeekdayInt += 1
            }
        }

        if getNow() > calendar.date(bySettingHour: endTimeHourInt,
                                    minute: endTimeMinInt,
                                    second: 0, of: getNow())! {
            daysToNextWorkWeekdayInt += 1
        }

        return daysToNextWorkWeekdayInt
    }


    func getWeekdayIntFrom(someDate: Date) -> Int {
        let components = Calendar.current.dateComponents(in: NSTimeZone.default, from: someDate)
        let weekday = components.weekday!-1
        // ☝️ so sunday is 0
        return weekday
    }


    func getWeekdayNameFromNow() -> String {
        let components = Calendar.current.dateComponents(in: NSTimeZone.default, from: getNow())
        let someWeekday = components.weekday!-1
        let someWeekdayName = DateFormatter().weekdaySymbols[someWeekday]
        return someWeekdayName
    }


    func tomorrow() -> Date {
        return Calendar.current.date(byAdding: .weekday, value: 1, to: getNow())!
    }


    func isAWorkWeekdayOn(someDate: Date) -> Bool {
        let someWeekday = getWeekdayIntFrom(someDate: someDate)
        let workdaysArr = getWeekdaysArrBool()
        return workdaysArr[someWeekday]
    }


    func getWorkHoursStatus() -> WorkHoursStatus {

        let now = getNow()

        guard startDate < endDate else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "startTime < endTime",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return .before
        }

        if (startDate...endDate).contains(now) {
            return .during
        } else if now < startDate {
            return .before
        } else if now > endDate {
            return .before
        } else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(alert: alert, condition: "else",
                     someFunc: #function, someLine: #line)
            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
        }
        return .before
    }


    @objc func tick() {
        fetchWorkHours() // needed? causes issues?
        switch getWorkHoursStatus() {
            case .before:
                updateLabelsIfNextDayIsWorkday()
            case .during:
                updateLabelsDuringWorkHours()
        }
    }


    func updateLabelsDuringWorkHours() {
        timeWorkableHelperLabel.text = Const.UIMsg.timeToWorkEnd
        moneyHelperLabel.text = Const.UIMsg.dailyMakeableRemaining
        let now = getNow()

        let secsDiff = endDate.timeIntervalSince1970 - now.timeIntervalSince1970
        updateMoneyMakeableLabel(seconds: secsDiff)

        timeWorkableLabel.text = formTimerFrom(Int(secsDiff))
    }


    func updateLabelsIfNextDayIsWorkday() {
        timeWorkableHelperLabel.text = Const.UIMsg.timeToWorkStart
        moneyHelperLabel.text = Const.UIMsg.dailyOutsideWorkingHours

        let secsInFullWorkday = endDate
            .timeIntervalSince1970 - startDate.timeIntervalSince1970

        guard secsInFullWorkday > 0 else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "secsInFullWorkday > 0",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        updateMoneyMakeableLabel(seconds: secsInFullWorkday)

        var secsTillWorkdayBegins = 0.0

        let now = getNow()

        guard now < startDate || now >= endDate else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "now < startTime || now >= endTime",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        secsTillWorkdayBegins = startDate.timeIntervalSince1970 -
        now.timeIntervalSince1970

        guard secsTillWorkdayBegins >= 0 else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "secsTillWorkdayBegins >= 0",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return
        }

        timeWorkableLabel.text = formTimerFrom(Int(secsTillWorkdayBegins))
    }


    func updateMoneyMakeableLabel(seconds: Double?) {

        guard let safeSeconds = seconds else {
            moneyMakeableLabel.text = " "
            return
        }

        let moneyLeft: Double = hourlyRate * safeSeconds / 3600.0
        let moneyLeftFormatted = numberFormatterCurrency.string(from: moneyLeft as NSNumber)
        moneyMakeableLabel.text = "\(moneyLeftFormatted!)"
    }


    func appendTo(alert: UIAlertController, condition: String,
                  someFunc: String, someLine: Int) {
        alert.message?.append("\n\n(Notes for the devs)")
        alert.message?.append("\n\(someFunc), \(someLine)")
        alert.message?.append("\n\(condition)")
        alert.message?.append("\nstart: \(startDate!)")
        alert.message?.append("\nend: \(endDate!)")
        alert.message?.append("\nnow: \(getNow())")
        alert.message?.append("daysToNextWorkWeekday: \(daysToNextWorkWeekday())")
        alert.message?.append("getWorkHoursStatus: \(getWorkHoursStatus())")
    }


    func formTimerFrom(_ seconds: Int) -> String {

        myDateCompForm.allowedUnits = [.day, .hour, .minute, .second]
        myDateCompForm.unitsStyle = .abbreviated
        myDateCompForm.zeroFormattingBehavior = [.dropAll]

        guard let mySafeString = myDateCompForm.string(
            from: DateComponents(second: seconds)) else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(
                alert: alert,
                condition: "let mySafeString = myDateCompForm.string",
                someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { shown in
                if shown {
                    self.invalTimerAndSetHelperLabel()
                }
            }
            return "error getting time"
        }
        return mySafeString
    }


    @IBAction func settingsTapped() {
        presentSettings()
    }


    func presentSettings() {
        let settingsVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: Const.IDIB.settingsViewController)
        as! SettingsViewController
        is😎Visible = false
        settingsVC.delegate = self
        present(settingsVC, animated: true)
    }


    func invalTimerAndSetHelperLabel() {
        self.timer.invalidate()
        timeWorkableLabel.text = ""
        moneyHelperLabel.text = " "
        timeWorkableHelperLabel.text = "Error: Adjust in-app Settings and restart app"
    }


    func infoMenu() -> UIMenu {
        let shareApp = UIAction(title: Const.UIMsg.shareTitleMessage,
                                image: UIImage(systemName: "heart"),
                                state: .off) { _ in
            self.shareApp()
        }
        let review = UIAction(title: Const.UIMsg.leaveReview,
                              image: UIImage(systemName: "hand.thumbsup"), state: .off) { _ in
            self.requestReview()
        }
        let moreApps = UIAction(title: Const.UIMsg.showAppsButtonTitle,
                                image: UIImage(systemName: "apps.iphone"),
                                state: .off) { _ in
            self.showApps()
        }

        let emailAction = UIAction(title: Const.UIMsg.contact,
                                   image: UIImage(systemName: "envelope.badge"),
                                   state: .off) { _ in
            self.sendEmailTapped()
        }

        let tutorial = UIAction(title: Const.UIMsg.tutorial,
                                image: UIImage(systemName: "info.circle"),
                                state: .off) { _ in
            self.showHelp()
        }


        let version: String? = Bundle.main.infoDictionary![Const.UIMsg.appVersion] as? String
        var myTitle = Const.UIMsg.appName
        if let safeVersion = version {
            myTitle += " \(Const.UIMsg.version) \(safeVersion)"
        }

        let infoMenu = UIMenu(title: myTitle, image: nil, identifier: .none,
                              options: .displayInline,
                              children: [emailAction, tutorial, review, shareApp, moreApps])
        return infoMenu
    }


    func showApps() {

        let myURL = URL(string: Const.UIMsg.appsLink)
        guard let safeURL = myURL else {
            let alert = createAlert(alertReasonParam: .unknown)
            appendTo(alert: alert, condition: "safeURL = myURL", someFunc: #function,
                     someLine: #line)
            showViaGCD(caller: self, alert: alert) { _ in }
            return
        }
        UIApplication.shared.open(safeURL, options: [:], completionHandler: nil)
    }


    func shareApp() {
        let message = Const.UIMsg.appsLink
        let activityController = UIActivityViewController(activityItems: [message],
                                                          applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = helpButton
        activityController
            .completionWithItemsHandler = { (_, _: Bool, _: [Any]?, error: Error?) in
                guard error == nil else {
                    let alert = self.createAlert(alertReasonParam: .unknown)
                    alert.view.layoutIfNeeded()
                    self.appendTo(alert: alert, condition: "error == nil", someFunc: #function,
                                  someLine: #line)
                    self.showViaGCD(caller: self, alert: alert) { _ in }
                    return
                }
            }
        DispatchQueue.main.async {
            self.present(activityController, animated: true)
        }

    }

}


protocol SettingsPresenter {
    func presentSettings()
}


protocol DeclaresVisibility {
    // swiftlint:disable identifier_name
    var is😎Visible: Bool { get set }
    // swiftlint:enable identifier_name
}


extension HomeViewController {

    func requestReview() {
        // Note: Replace the XXXXXXXXXX below with the App Store ID for your app
        //       You can find the App Store ID in your app's product URL
        guard let writeReviewURL = URL(string: Const.UIMsg.reviewLink)
        else {
            let alert = createAlert(alertReasonParam: .unknown)

            appendTo(alert: alert, condition: "expected valid URL",
                     someFunc: #function, someLine: #line)

            showViaGCD(caller: self, alert: alert) { _ in }
            return
        }
        UIApplication.shared.open(
            writeReviewURL,
            options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
            completionHandler: nil)
    }
}


// Helper function inserted by Swift 4.2 migrator.

private func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(
    _ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in
            (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }


extension HomeViewController: MFMailComposeViewControllerDelegate {

    func sendEmailTapped() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }


    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the
        // --mailComposeDelegate-- property, NOT the --delegate-- property

        mailComposerVC.setToRecipients([Const.UIMsg.emailString])
        let version: String? = Bundle.main.infoDictionary![Const.UIMsg.appVersion] as? String
        var myTitle = Const.UIMsg.appName
        if let safeVersion = version {
            myTitle += " \(Const.UIMsg.version) \(safeVersion)"
        }
        mailComposerVC.setSubject(myTitle)
        mailComposerVC.setMessageBody("""
        Hi, I have a question about your app:
        \n\n\n\n\n\n\n
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        startTime: \(startDate!)
        endTime: \(endDate!)
        now: \(getNow())
        daysToNextWorkWeekday: \(daysToNextWorkWeekday())
        getWorkHoursStatus: \(getWorkHoursStatus())
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        """, isHTML: false)
        return mailComposerVC
    }


    func showSendMailErrorAlert() {
        let alert = createAlert(alertReasonParam: .emailError)
        showViaGCD(caller: self, alert: alert) { _ in }
    }


    // MARK: MFMailComposeViewControllerDelegate

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
