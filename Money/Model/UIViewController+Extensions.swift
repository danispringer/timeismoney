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
    }


    func createAlert(alertReasonParam: AlertReason,
                     levelIndex: Int = 0, points: Int = 0,
                     secondsLeft: Int = 0, livesLeft: Int = 0) -> UIAlertController {

        var alertTitle = ""
        var alertMessage = ""
        switch alertReasonParam {
            default:
                alertTitle = "Unknown error"
                alertMessage = """
            Please let me know the steps or events that occurred before this error (visit the App Store page for this app, then tap on App Support).
            You may quit and relaunch the app to try again.
            """
        }

        let alert = UIAlertController(title: alertTitle, message: alertMessage,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(alertAction)

        return alert
    }


}
