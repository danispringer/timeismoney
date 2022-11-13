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


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()


        guard isNowWorkHours() else {
            // TODO: "come back tomorrow..."
            timer.invalidate()
            timeWorkableHelperLabel.text = "Time until work begins:"
            timeWorkableLabel.text = "TODO: fixme"
            moneyMakeableLabel.text = "$0.00"
            moneyHelperLabel.text = "You're done. Take a break."
            return
        }

        timeWorkableHelperLabel.text = "Time left to work today:"
        moneyHelperLabel.text = "Money you can IY\"H still make today"

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick) , userInfo: nil, repeats: true)
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard isNowWorkHours() else {
            return
        }

        updateLabels()
    }


    // MARK: Helpers

    func isNowWorkHours() -> Bool {
        let now = Date()

        let componentsNow: Int = calendar.dateComponents([.hour], from: now).hour!
        return (componentsNow >= 9) && (componentsNow < hourWorkdayEnds)
    }


    @objc func tick() {
        updateLabels()
    }


    func updateLabels() {
        let todayAt6PM = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
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

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        let moneyLeftFormatted = numberFormatter.string(from: moneyLeft as NSNumber)
        moneyMakeableLabel.text = "\(moneyLeftFormatted!)"


        let formattedMins = String(format: "%02d", componentsNowTo6PM.minute!)
        let formattedSecs = String(format: "%02d", componentsNowTo6PM.second!)
        timeWorkableLabel.text =  """
        \(componentsNowTo6PM.hour!):\(formattedMins):\(formattedSecs)
        """
    }

}

