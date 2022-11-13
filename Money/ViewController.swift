//
//  ViewController.swift
//  Money
//
//  Created by dani on 11/13/22.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var moneyMakeableLabel: UILabel!
    @IBOutlet weak var timeWorkableLabel: UILabel!
    @IBOutlet weak var timeWorkableHelperLabel: UILabel!
    @IBOutlet weak var moneyHelperLabel: UILabel!


    // MARK: Properties

    var timer = Timer()
    let hourlyRate = 26.7
    let calendar = Calendar.current
    let hourWorkdayStarts = 9
    let hourWorkdayEnds = 18
    let numberFormatterCurrency = NumberFormatter()


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        for label: UILabel in [moneyHelperLabel, timeWorkableHelperLabel,
                               moneyMakeableLabel, timeWorkableLabel] {
            label.text = ""
        }

        numberFormatterCurrency.numberStyle = .currency
        numberFormatterCurrency.roundingMode = .down

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
    }


    // MARK: Helpers

    func isNowWorkHours() -> Bool {
        let now = Date()

        let componentsNow: Int = calendar.dateComponents([.hour], from: now).hour!
        return (componentsNow >= hourWorkdayStarts) && (componentsNow < hourWorkdayEnds)
    }


    @objc func tick() {
        if isNowWorkHours() {
            updateLabelsDuringWorkDay()
        } else {
            updateLabelsAfterHours()
        }
    }


    func updateLabelsDuringWorkDay() {
        timeWorkableHelperLabel.text = "Time left to work today:"
        moneyHelperLabel.text = "Money you can IY\"H still make today"
        let todayAt6PM = calendar.date(bySettingHour: hourWorkdayEnds, minute: 0, second: 0, of: Date())!
        let now = Date()

        let componentsNowTo6PM = calendar.dateComponents([.hour, .minute, .second],
                                                         from: now, to: todayAt6PM)

        let hoursLeft: Double = Double(componentsNowTo6PM.hour!)
        let minutesLeft: Double = Double(componentsNowTo6PM.minute!)
        let secondsLeft: Double = Double(componentsNowTo6PM.second!)
        let minutesAsPercent: Double = minutesLeft / 60
        let secondsAsPercent: Double = secondsLeft / 60 / 60
        let totalHoursLeftAsPercent = hoursLeft+minutesAsPercent+secondsAsPercent
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
        timeWorkableHelperLabel.text = "Time left till work starts:"
        moneyHelperLabel.text = "Outside working hours"
        var todayAt9AM: Date!
        let now = Date()
        if isNowBetweenEndOfWorkdayAnd12AM() {
            todayAt9AM = calendar.date(bySettingHour: hourWorkdayStarts, minute: 0, second: 0, of: Date())!
            todayAt9AM = calendar.date(byAdding: .day, value: 1, to: todayAt9AM)!
        } else {
            todayAt9AM = calendar.date(bySettingHour: hourWorkdayStarts, minute: 0, second: 0, of: Date())!
        }

        let componentsNowTo9AM = calendar.dateComponents([.hour, .minute, .second],
                                                         from: now, to: todayAt9AM)
        moneyMakeableLabel.text = "💤"

        let formattedMins = String(format: "%02d", componentsNowTo9AM.minute!)
        let formattedSecs = String(format: "%02d", componentsNowTo9AM.second!)
        timeWorkableLabel.text =  """
        \(componentsNowTo9AM.hour!):\(formattedMins):\(formattedSecs)
        """
    }


    func isNowBetweenEndOfWorkdayAnd12AM() -> Bool {
        let now = Date()

        let componentsNowHour: Int = calendar.dateComponents([.hour], from: now).hour!
        return (componentsNowHour >= 18) && (componentsNowHour <= 23)
    }

}

