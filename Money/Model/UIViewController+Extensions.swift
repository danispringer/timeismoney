//
//  UIViewController+Extensions.swift
//  Money
//
//  Created by Daniel Springer on 11/22/22.
//


import UIKit
import MessageUI

extension UIViewController: MFMailComposeViewControllerDelegate {

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
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        """, isHTML: false)
        return mailComposerVC
    }


    func showSendMailErrorAlert() {
        let alert = createAlert(alertReasonParam: .emailError)
        showViaGCD(caller: self as! HomeViewController, alert: alert) { _ in }
    }


    // MARK: MFMailComposeViewControllerDelegate

    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
        controller.dismiss(animated: true)
    }

    func sendEmailTapped() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }


    func getWeekdayIntFrom(someDate: Date) -> Int {
        let components = Calendar.current.dateComponents(in: NSTimeZone.default, from: someDate)
        let weekday = components.weekday!-1
        // ☝️ so sunday is 0
        return weekday
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


    func getWeekdaysArrBool() -> [Bool] {
        return UD.value(forKey: Const.UDef.weekdaysIWorkOn) as! [Bool]
    }

    func setThemeColorTo(myThemeColor: UIColor) {
        UIProgressView.appearance().progressTintColor = myThemeColor
        self.navigationController?.navigationBar.tintColor = myThemeColor
        UINavigationBar.appearance().tintColor = myThemeColor
        UIView.appearance(
            whenContainedInInstancesOf: [
                UIAlertController.self]).tintColor = myThemeColor
        UIView.appearance(
            whenContainedInInstancesOf: [
                UIToolbar.self]).tintColor = myThemeColor

        UIButton.appearance().tintColor = myThemeColor

        UISwitch.appearance().onTintColor = myThemeColor

        UIDatePicker.appearance().tintColor = myThemeColor

        for state: UIControl.State in [.application, .highlighted, .normal, .selected] {
            UIBarButtonItem.appearance().setTitleTextAttributes([
                NSAttributedString.Key.foregroundColor: myThemeColor
            ], for: state)
        }
    }


    enum AlertReason {
        case unknown
        case emailError
    }


    func createAlert(alertReasonParam: AlertReason) -> UIAlertController {

        var alertTitle = ""
        var alertMessage = ""
        switch alertReasonParam {
            case .emailError:
                alertTitle = "Email Not Sent"
                alertMessage = """
                Your device could not send email. Please check email configuration and \
                try again.
                """
            default:
                alertTitle = "An Error Occurred"
                alertMessage = """
            Please screenshot this and send it to be by tapping "\(Const.UIMsg.contact)"
            """
        }

        let alert = UIAlertController(title: alertTitle, message: alertMessage,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Not now", style: .cancel)
        alert.addAction(alertAction)

        let emailAction = UIAlertAction(title: Const.UIMsg.contact, style: .default) { _ in
            self.sendEmailTapped()
        }
        alert.addAction(emailAction)

        return alert
    }


    func showViaGCD(caller: HomeViewController, alert: UIAlertController,
                    completionHandler: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            if caller.is😎Visible && caller.presentedViewController == nil {
                self.present(alert, animated: true)
                if let safeCompletionHandler = completionHandler {
                    safeCompletionHandler(true)
                }
            } else {
                if let safeCompletionHandler = completionHandler {
                    safeCompletionHandler(false)
                }
            }
        }
    }


    func getNow() -> Date {
        let now = Date()
        if CommandLine.arguments.contains("--moneyScreenshots") {
            // We are in testing mode, make arrangements if needed
            return calendar.date(byAdding: .hour, value: 5, to: now)!
        }
        return now
    }

}
