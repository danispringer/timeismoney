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


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        numberFormatterCurrency.numberStyle = .currency
        numberFormatterReset.numberStyle = .none

        hourlyRateTextField.delegate = self
        hourlyRateTextField.inputAccessoryView = addAccessoryView()
        let hourlyRate = UserDefaults.standard.double(forKey: "hourlyRate")
        hourlyRateTextField.text = numberFormatterCurrency.string(from: hourlyRate as NSNumber)
    }


    func addAccessoryView() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done, target: self,
            action: #selector(self.doneButtonTapped))
        toolBar.items = [doneButton]
        toolBar.tintColor = UIColor.red
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

        UserDefaults.standard.set(rateAsDouble, forKey: "hourlyRate")

        hourlyRateTextField.text = rateAsCurrency

    }


    func restoreOldRateCuzNewFailed() {
        // alert user?
        let oldHourlyRate = UserDefaults.standard.double(forKey: "hourlyRate")
        hourlyRateTextField.text = numberFormatterCurrency.string(from: oldHourlyRate as NSNumber)
    }

}
