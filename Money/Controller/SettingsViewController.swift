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
    let dateFormatter = DateFormatter()


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        numberFormatterCurrency.numberStyle = .currency
        numberFormatterReset.numberStyle = .none

        hourlyRateTextField.delegate = self
        hourlyRateTextField.inputAccessoryView = addAccessoryView()
        let hourlyRate = UserDefaults.standard.double(forKey: Const.UDef.hourlyRate)
        hourlyRateTextField.text = numberFormatterCurrency.string(from: hourlyRate as NSNumber)

        startTimeDatePicker.addTarget(
            self,
            action: #selector(workScheduleChanged(sender:)),
            for: .valueChanged)
        endTimeDatePicker.addTarget(
            self,
            action: #selector(workScheduleChanged(sender:)),
            for: .valueChanged)

    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !UIAccessibility.isReduceTransparencyEnabled {
            view.backgroundColor = .clear
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
        } else {

        }
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

        let droppedCurrencySymbol: String = userInput.replacing(
            numberFormatterCurrency.currencySymbol, with: "")

        guard let rateAsDouble = Double(droppedCurrencySymbol) else {
            restoreOldRateCuzNewFailed()
            return
        }

        guard let rateAsCurrency: String = numberFormatterCurrency.string(from: rateAsDouble as NSNumber) else {
            restoreOldRateCuzNewFailed()
            return
        }

        UserDefaults.standard.set(rateAsDouble, forKey: Const.UDef.hourlyRate)

        hourlyRateTextField.text = rateAsCurrency

    }


    func restoreOldRateCuzNewFailed() {
        // alert user?
        let oldHourlyRate = UserDefaults.standard.double(forKey: Const.UDef.hourlyRate)
        hourlyRateTextField.text = numberFormatterCurrency.string(from: oldHourlyRate as NSNumber)
    }


    @objc func workScheduleChanged(sender: UIDatePicker) {
        // Start time tag: 0
        // End time tag: 1
        let time = sender.date
        dateFormatter.dateFormat = "HH:mm"
        let formatted = dateFormatter.string(from: time)
        print("formatted: \(formatted)")

    }

}
