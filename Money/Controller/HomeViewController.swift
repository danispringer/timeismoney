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


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatterHM.dateFormat = "HH:mm"
        dateFormatterHMS.dateFormat = "HH:mm:ss"
        numberFormatterCurrency.numberStyle = .currency
        numberFormatterCurrency.roundingMode = .down

        for label: UILabel in [moneyHelperLabel, timeWorkableHelperLabel,
                               moneyMakeableLabel, timeWorkableLabel] {
            label.text = " "
        }

        fetchWorkHours()

        NC.addObserver(self, selector: #selector(fetchWorkHours),
                       name: .hoursDidChange, object: nil)

        timer = Timer.scheduledTimer(
            timeInterval: 1.0, target: self,
            selector: #selector(self.tick), userInfo: nil, repeats: true)
    }


    // MARK: Helpers

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

        print("startTime: \(startTime!)")
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

        let componentsNowTo6PM = calendar.dateComponents([.hour, .minute, .second],
                                                         from: now, to: startTime)

        let hoursLeft: Double = Double(componentsNowTo6PM.hour!)
        let minutesLeft: Double = Double(componentsNowTo6PM.minute!)
        let secondsLeft: Double = Double(componentsNowTo6PM.second!)
        let minutesAsPercent: Double = minutesLeft / 60
        let secondsAsPercent: Double = secondsLeft / 60 / 60
        let totalHoursLeftAsPercent = hoursLeft+minutesAsPercent+secondsAsPercent
        let hourlyRate: Double = UD.double(forKey: Const.UDef.hourlyRate)
        let moneyLeft = hourlyRate * totalHoursLeftAsPercent
        let moneyLeftFormatted = numberFormatterCurrency.string(from: moneyLeft as NSNumber)
        moneyMakeableLabel.text = "\(moneyLeftFormatted!)"

        let formattedMins = String(format: "%02d", componentsNowTo6PM.minute!)
        let formattedSecs = String(format: "%02d", componentsNowTo6PM.second!)
        timeWorkableLabel.text =  """
        \(componentsNowTo6PM.hour!):\(formattedMins):\(formattedSecs)
        """
    }


    func updateLabelsAfterHours() {
        timeWorkableHelperLabel.text = Const.UIMsg.timeTillWorkdayBegins
        moneyHelperLabel.text = """
        (💤 Outside working hours 💤)

        Your Daily Makeable:
        """

        let hourlyRate: Double = UD.double(forKey: Const.UDef.hourlyRate)
        let secsDiff = endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
        let moneyLeft = hourlyRate * secsDiff / 3600.0
        let moneyLeftFormatted = numberFormatterCurrency.string(from: moneyLeft as NSNumber)
        moneyMakeableLabel.text = "\(moneyLeftFormatted!)"

        timeWorkableLabel.text = secondsToHoursMinutesSeconds(Int(secsDiff))
    }


    func secondsToHoursMinutesSeconds(_ seconds: Int) -> String {
        return """
        \(seconds / 3600):\
        \((seconds % 3600) / 60):\
        \((seconds % 3600) % 60)
        """
    }


    @IBAction func settingsTapped(_ sender: Any) {
        let toPresent = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SettingsViewController")
        as! SettingsViewController
        toPresent.modalPresentationStyle = .pageSheet
        toPresent.sheetPresentationController?.detents = [.medium()]
        present(toPresent, animated: true)
    }

}
