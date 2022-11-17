//
//  SettingsViewController.swift
//  Money
//
//  Created by dani on 11/16/22.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets

    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!
    @IBOutlet weak var hourlyRateTextField: UITextField!


    // MARK: Properties

    let numberFormatterCurrency = NumberFormatter()
    let numberFormatterReset = NumberFormatter()
    let dateFormatterHM = DateFormatter()


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if CommandLine.arguments.contains("--moneyScreenshots") {
            // We are in testing mode, make arrangements if needed
            UIView.setAnimationsEnabled(false)
        }


        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
        } else {

        }

        numberFormatterCurrency.numberStyle = .currency
        numberFormatterReset.numberStyle = .none

        dateFormatterHM.dateFormat = "HH:mm"

        hourlyRateTextField.delegate = self
        hourlyRateTextField.inputAccessoryView = addAccessoryView()
        let hourlyRate = UD.double(forKey: Const.UDef.hourlyRate)
        hourlyRateTextField.text = numberFormatterCurrency.string(from: hourlyRate as NSNumber)

        fetchWorkHours()

        startTimeDatePicker.addTarget(
            self,
            action: #selector(workScheduleChanged(sender:)),
            for: .valueChanged)
        endTimeDatePicker.addTarget(
            self,
            action: #selector(workScheduleChanged(sender:)),
            for: .valueChanged)

    }


    // MARK: Helpers

    // how to not have this func here AND in homevc?
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

        startTimeDatePicker.date = calendar.date(
            bySettingHour: startTimeHourInt,
            minute: startTimeMinInt, second: 0, of: now)!
        endTimeDatePicker.date = calendar.date(
            bySettingHour: endTimeHourInt,
            minute: endTimeMinInt, second: 0, of: now)!
    }


    func addAccessoryView() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done, target: self,
            action: #selector(self.doneButtonTapped))
        let spacer = UIBarButtonItem.flexibleSpace()
        toolBar.items = [spacer, doneButton]
        return toolBar
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }


    @objc func doneButtonTapped() {
        hourlyRateTextField.resignFirstResponder()

        guard let userInput: String = hourlyRateTextField.text else {
            restoreOldRateCuzNewFailed()
            return
        }

        let droppedCurrencySymbol: String = userInput.replacingOccurrences(
            of: numberFormatterCurrency.currencySymbol, with: "")
        guard let rateAsDouble = Double(droppedCurrencySymbol) else {
            restoreOldRateCuzNewFailed()
            return
        }

        guard let rateAsCurrency: String = numberFormatterCurrency.string(from: rateAsDouble as NSNumber) else {
            restoreOldRateCuzNewFailed()
            return
        }

        UD.set(rateAsDouble, forKey: Const.UDef.hourlyRate)
        NC.post(name: .hourlyRateDidChange, object: nil)

        hourlyRateTextField.text = rateAsCurrency

    }


    func restoreOldRateCuzNewFailed() {
        // alert user?
        let oldHourlyRate = UD.double(forKey: Const.UDef.hourlyRate)
        hourlyRateTextField.text = numberFormatterCurrency.string(from: oldHourlyRate as NSNumber)
    }


    @objc func workScheduleChanged(sender: UIDatePicker) {
        // Start time tag: 0
        // End time tag: 1
        let time = sender.date
        let formatted = dateFormatterHM.string(from: time)

        switch sender.tag {
            case 0:
                UD.set(formatted, forKey: Const.UDef.startTime)
            case 1:
                UD.set(formatted, forKey: Const.UDef.endTime)
            default:
                fatalError()
        }
        NC.post(name: .hoursDidChange, object: nil)

    }


    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true)
    }


}
