//
//  HomeViewController.swift
//  Money
//
//  Created by dani on 11/13/22.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var moneyMakeableLabel: UILabel!
    @IBOutlet weak var moneyHelperLabel: UILabel!
    @IBOutlet weak var timeWorkableLabel: UILabel!
    @IBOutlet weak var timeWorkableHelperLabel: UILabel!
    @IBOutlet weak var aboutButton: UIBarButtonItem!


    // MARK: Properties

    var timer = Timer()
    let numberFormatterCurrency = NumberFormatter()
    let dateFormatterHM = DateFormatter()
    let dateFormatterHMS = DateFormatter()
    var startTime: Date!
    var endTime: Date!
    var hourlyRate: Double!


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


        dateFormatterHM.dateFormat = "HH:mm"
        dateFormatterHMS.dateFormat = "HH:mm:ss"
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

        navigationController?.navigationBar.prefersLargeTitles = true

        setThemeColorTo(myThemeColor: .systemGreen)
        aboutButton.menu = infoMenu()
    }


    // MARK: Helpers

    @objc func fetchHourlyRate() {
        hourlyRate = UD.double(forKey: Const.UDef.hourlyRate)
    }


    @objc func fetchWorkHours() {
        let startTimeString: String = UD.string(forKey: Const.UDef.startTime)!
        let endTimeString: String = UD.string(forKey: Const.UDef.endTime)!

        let startTimeH = startTimeString.prefix(2)
        let startTimeM = startTimeString.suffix(2)
        let endTimeH = endTimeString.prefix(2)
        let endTimeM = endTimeString.suffix(2)
        let startTimeHourInt: Int = Int(startTimeH)!
        let startTimeMinInt: Int = Int(startTimeM)!
        let endTimeHourInt: Int = Int(endTimeH)!
        let endTimeMinInt: Int = Int(endTimeM)!

        let now = Date()

        startTime = calendar.date(bySettingHour: startTimeHourInt,
                                  minute: startTimeMinInt, second: 0, of: now)!
        endTime = calendar.date(bySettingHour: endTimeHourInt,
                                minute: endTimeMinInt, second: 0, of: now)!
    }


    func isNowWorkHours() -> Bool {
        let now = Date()
        return now >= startTime && now < endTime
    }


    @objc func tick() {
        if isNowWorkHours() {
            updateLabelsDuringWorkDay()
        } else {
            updateLabelsAfterHours()
        }
    }


    func updateLabelsDuringWorkDay() {
        timeWorkableHelperLabel.text = Const.UIMsg.timeTillWorkdayEnds
        moneyHelperLabel.text = Const.UIMsg.dailyMakeableRemaining
        let now = Date()

        let secsDiff = endTime.timeIntervalSince1970 - now.timeIntervalSince1970
        updateMoneyMakeableLabel(seconds: secsDiff)

        timeWorkableLabel.text = secondsToHoursMinutesSeconds(Int(secsDiff))
    }


    func updateMoneyMakeableLabel(seconds: Double) {
        let moneyLeft: Double = hourlyRate * seconds / 3600.0
        let moneyLeftFormatted = numberFormatterCurrency.string(from: moneyLeft as NSNumber)
        moneyMakeableLabel.text = "\(moneyLeftFormatted!)"
    }


    func updateLabelsAfterHours() {
        timeWorkableHelperLabel.text = Const.UIMsg.timeTillWorkdayBegins
        moneyHelperLabel.text = Const.UIMsg.dailyOutsideWorkingHours

        let secsBetweenStartAndEndTime = endTime
            .timeIntervalSince1970 - startTime.timeIntervalSince1970

        guard secsBetweenStartAndEndTime > 0 else {
            let alert = createAlert(alertReasonParam: .unknown)
            alert.message?.append("error: func \(#function), line \(#line)")
            alert.message?.append("startTime: \(startTime.timeIntervalSince1970), endTime: \(endTime.timeIntervalSince1970)")
            timer.invalidate()
            present(alert, animated: true)
            return
        }

        updateMoneyMakeableLabel(seconds: secsBetweenStartAndEndTime)

        var secsTillWorkdayBegins = 0.0

        if Date() < startTime { // if before work (as opposed to after)
            secsTillWorkdayBegins = startTime
                .timeIntervalSince1970 - Date().timeIntervalSince1970
        } else if Date() >= endTime {
            secsTillWorkdayBegins = startTime
                .timeIntervalSince1970.advanced(by: secondsInADay)
            - Date().timeIntervalSince1970
        } else {
            let alert = createAlert(alertReasonParam: .unknown)
            alert.message?.append("error: func \(#function), line \(#line)")
            alert.message?.append("startTime: \(startTime.timeIntervalSince1970), endTime: \(endTime.timeIntervalSince1970)")
            timer.invalidate()
            present(alert, animated: true)
            return
        }

        if secsTillWorkdayBegins < 0 {
            let alert = createAlert(alertReasonParam: .unknown)
            alert.message?.append("error: func \(#function), line \(#line)")
            alert.message?.append("startTime: \(startTime.timeIntervalSince1970), endTime: \(endTime.timeIntervalSince1970)")
            timer.invalidate()
            present(alert, animated: true)
        }

        timeWorkableLabel.text = secondsToHoursMinutesSeconds(Int(secsTillWorkdayBegins))
    }


    func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
        let hours = String(format: "%02d", seconds / 3600)
        let mins = String(format: "%02d", (seconds % 3600) / 60)
        let secs = String(format: "%02d", (seconds % 3600) % 60)
        return "\(hours):\(mins):\(secs)"
    }


    @IBAction func settingsTapped() {
        let toPresent = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SettingsViewController")
        as! SettingsViewController
        self.navigationController?.pushViewController(toPresent, animated: true)
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


        let version: String? = Bundle.main.infoDictionary![Const.UIMsg.appVersion] as? String
        var myTitle = Const.UIMsg.appName
        if let safeVersion = version {
            myTitle += " \(Const.UIMsg.version) \(safeVersion)"
        }

        let infoMenu = UIMenu(title: myTitle, image: nil, identifier: .none,
                              options: .displayInline,
                              children: [review, shareApp, moreApps])
        return infoMenu
    }


    func showApps() {

        let myURL = URL(string: Const.UIMsg.appsLink)
        guard let safeURL = myURL else {
            let alert = createAlert(alertReasonParam: .unknown)
            present(alert, animated: true)
            return
        }
        UIApplication.shared.open(safeURL, options: [:], completionHandler: nil)
    }


    func shareApp() {
        let message = Const.UIMsg.appsLink
        let activityController = UIActivityViewController(activityItems: [message],
                                                          applicationActivities: nil)
        activityController.popoverPresentationController?.barButtonItem = aboutButton
        activityController
            .completionWithItemsHandler = { (_, _: Bool, _: [Any]?, error: Error?) in
                guard error == nil else {
                    let alert = self.createAlert(alertReasonParam: .unknown)
                    alert.view.layoutIfNeeded()
                    self.present(alert, animated: true)
                    return
                }
            }
        DispatchQueue.main.async {
            self.present(activityController, animated: true)
        }

    }

}


extension HomeViewController {


    func requestReview() {
        // Note: Replace the XXXXXXXXXX below with the App Store ID for your app
        //       You can find the App Store ID in your app's product URL
        guard let writeReviewURL = URL(string: Const.UIMsg.reviewLink)
        else {
            fatalError("expected valid URL")

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
