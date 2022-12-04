//
//  UIViewController+Extensions.swift
//  Money
//
//  Created by dani on 11/22/22.
//


import UIKit

extension UIViewController {

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


    func createAlert(alertReasonParam: AlertReason,
                     levelIndex: Int = 0, points: Int = 0,
                     secondsLeft: Int = 0, livesLeft: Int = 0) -> UIAlertController {

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
            Please take a s screenshot of this error. Here is how to email it it us:
            Tap on the top left "Info" button, then tap "\(Const.UIMsg.contact)", \
            and attach the screenshot to the email.

            TIP: Ensure you set the work hours correctly, then quit and relaunch the app \
            to retry.
            """
        }

        let alert = UIAlertController(title: alertTitle, message: alertMessage,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(alertAction)

        return alert
    }


    func showViaGCD(caller: HomeViewController, alert: UIAlertController,
                    completionHandler: ((Bool) -> Void)?) {
        DispatchQueue.main.async {
            if caller.is😎Visible {
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

}
