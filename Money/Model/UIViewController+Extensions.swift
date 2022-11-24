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
        self.navigationController!.navigationBar.tintColor = myThemeColor
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
                Your device could not send e-mail. Please check e-mail configuration and \
                try again.
                """
            default:
                alertTitle = "Unknown error"
                alertMessage = """
            Please screenshot this message and email it to me:
            Tap on the top left button, then tap "\(Const.UIMsg.contact)", \
            and add the screenshot to your message.

            Please relaunch the app to retry.
            """
        }

        let alert = UIAlertController(title: alertTitle, message: alertMessage,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(alertAction)

        return alert
    }


}
