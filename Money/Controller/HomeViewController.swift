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
    let calendar = Calendar.current
    let workdayStartHour = 9
    let workdayStartMinute = 0 // use
    let workdayEndsHour = 18
    let workdayEndsMinute = 0 // use
    let numberFormatterCurrency = NumberFormatter()


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        for label: UILabel in [moneyHelperLabel, timeWorkableHelperLabel,
                               moneyMakeableLabel, timeWorkableLabel] {
            label.text = " "
        }

        numberFormatterCurrency.numberStyle = .currency
        numberFormatterCurrency.roundingMode = .down

        timer = Timer.scheduledTimer(
            timeInterval: 1.0, target: self,
            selector: #selector(self.tick), userInfo: nil, repeats: true)
    }


    // MARK: Helpers

    func isNowWorkHours() -> Bool {
        let now = Date()

        let componentsNow = calendar.dateComponents([.hour], from: now).hour!
        return (componentsNow >= workdayStartHour) && (componentsNow < workdayEndsHour)
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
        moneyHelperLabel.text = "Daily Makeable Remaining:"
        let todayAt6PM = calendar.date(bySettingHour: workdayEndsHour, minute: 0, second: 0, of: Date())!
        let now = Date()

        let componentsNowTo6PM = calendar.dateComponents([.hour, .minute, .second],
                                                         from: now, to: todayAt6PM)

        let hoursLeft: Double = Double(componentsNowTo6PM.hour!)
        let minutesLeft: Double = Double(componentsNowTo6PM.minute!)
        let secondsLeft: Double = Double(componentsNowTo6PM.second!)
        let minutesAsPercent: Double = minutesLeft / 60
        let secondsAsPercent: Double = secondsLeft / 60 / 60
        let totalHoursLeftAsPercent = hoursLeft+minutesAsPercent+secondsAsPercent
        let hourlyRate: Double = UserDefaults.standard.double(forKey: Const.UDef.hourlyRate)
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
        var upcoming9AM: Date!
        let now = Date()
        if isNowBetweenEndOfWorkdayAnd12AM() {
            upcoming9AM = calendar.date(bySettingHour: workdayStartHour,
                                        minute: workdayStartMinute, second: 0, of: Date())!
            upcoming9AM = calendar.date(byAdding: .day, value: 1, to: upcoming9AM)!
        } else {
            upcoming9AM = calendar.date(bySettingHour: workdayStartHour,
                                        minute: workdayStartMinute, second: 0, of: Date())!
        }

        let componentsNowTo9AM = calendar.dateComponents([.hour, .minute, .second],
                                                         from: now, to: upcoming9AM)

        let hourlyRate: Double = UserDefaults.standard.double(forKey: Const.UDef.hourlyRate)
        let moneyLeft = hourlyRate * Double(workdayEndsHour-workdayStartHour)
        let moneyLeftFormatted = numberFormatterCurrency.string(from: moneyLeft as NSNumber)
        moneyMakeableLabel.text = "\(moneyLeftFormatted!)"

        let formattedMins = String(format: "%02d", componentsNowTo9AM.minute!)
        let formattedSecs = String(format: "%02d", componentsNowTo9AM.second!)
        timeWorkableLabel.text =  """
        \(componentsNowTo9AM.hour!):\(formattedMins):\(formattedSecs)
        """
    }


    func isNowBetweenEndOfWorkdayAnd12AM() -> Bool {
        let now = Date()

        let componentsNowHour = calendar.dateComponents([.hour], from: now).hour!
        return (componentsNowHour >= 18) && (componentsNowHour <= 23)
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
