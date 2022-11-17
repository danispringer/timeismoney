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
    @IBOutlet weak var timeWorkableLabel: UILabel!
    @IBOutlet weak var timeWorkableHelperLabel: UILabel!
    @IBOutlet weak var moneyHelperLabel: UILabel!


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

        timer = Timer.scheduledTimer(
            timeInterval: 1.0, target: self,
            selector: #selector(self.tick), userInfo: nil, repeats: true)
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

        startTime = calendar.date(bySettingHour: startTimeHourInt, minute: startTimeMinInt, second: 0, of: now)!
        endTime = calendar.date(bySettingHour: endTimeHourInt, minute: endTimeMinInt, second: 0, of: now)!
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
        moneyHelperLabel.text = """
        (💤 Outside working hours 💤)

        Your Daily Makeable:
        """

        let secsBetweenStartAndEndTime = endTime
            .timeIntervalSince1970 - startTime.timeIntervalSince1970
        updateMoneyMakeableLabel(seconds: secsBetweenStartAndEndTime)

        var secsTillWorkdayBegins = 0.0

        if Date() < startTime { // if before work (as opposed to after)
            secsTillWorkdayBegins = startTime
                .timeIntervalSince1970 - Date().timeIntervalSince1970
        } else {
            secsTillWorkdayBegins = startTime
                .timeIntervalSince1970.advanced(by: secondsInADay) - Date().timeIntervalSince1970
        }


        timeWorkableLabel.text = secondsToHoursMinutesSeconds(Int(secsTillWorkdayBegins))
    }


    func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
        let hours = String(format: "%02d", seconds / 3600)
        let mins = String(format: "%02d", (seconds % 3600) / 60)
        let secs = String(format: "%02d", (seconds % 3600) % 60)
        return "\(hours):\(mins):\(secs)"
    }


    @IBAction func settingsTapped(_ sender: Any) {
        let toPresent = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SettingsViewController")
        as! SettingsViewController
        present(toPresent, animated: true)
    }

}
