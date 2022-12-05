//
//  SettingsViewController.swift
//  Money
//
//  Created by dani on 11/16/22.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate,
                              UITableViewDelegate, UITableViewDataSource {

    // MARK: Outlets

    @IBOutlet weak var settingsTableView: UITableView!


    // MARK: Properties

    var delegate: DeclaresVisibility?

    let settingsTimeCell = "SettingsTimeCell"
    let settingsHourlyCell = "SettingsHourlyCell"
    let settingsWeekdayCell = "SettingsWeekdayCell"

    let myDataSourceLabels = [
        [
            "Work start time:",
            "Work end time:"
        ],
        [
            "Hourly rate:"
        ]
    ]

    let myDataSourceTitles = [
        "Enter what times you start and end work",
        "Enter how much you get paid per hour",
        "Select what weekdays you work on"
    ]

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

        numberFormatterCurrency.numberStyle = .currency
        numberFormatterReset.numberStyle = .none
        dateFormatterHM.dateFormat = "HH:mm"

        self.title = "Settings"

    }


    // MARK: Helpers

    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.is😎Visible = true
        }
    }


    @objc func fetchWorkHours(aDatePicker: UIDatePicker) {
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

        if aDatePicker.tag == 0 {
            aDatePicker.date = calendar.date(
                bySettingHour: startTimeHourInt,
                minute: startTimeMinInt, second: 0, of: now)!
        } else {
            aDatePicker.date = calendar.date(
                bySettingHour: endTimeHourInt,
                minute: endTimeMinInt, second: 0, of: now)!
        }

    }


    func addAccessoryView() -> UIToolbar {
        let toolBar = UIToolbar(
            frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let textFieldSaveButton = UIBarButtonItem(
            title: "Save",
            style: .done, target: self,
            action: #selector(self.textFieldSaveTapped))
        let spacer = UIBarButtonItem.flexibleSpace()
        toolBar.items = [spacer, textFieldSaveButton]
        return toolBar
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldSaveTapped()
        return true
    }


    @objc func textFieldSaveTapped() {

        let aTextField: UITextField = (settingsTableView.cellForRow(
            at: IndexPath(row: 0, section: 1)) as! SettingsHourlyCell
        ).myTextField

        aTextField.resignFirstResponder()

        guard let userInput: String = aTextField.text else {
            restoreOldRateCuzNewFailed(textField: aTextField)
            return
        }

        let droppedCurrencySymbol: String = userInput.replacingOccurrences(
            of: numberFormatterCurrency.currencySymbol, with: "")
        guard let rateAsDouble = Double(droppedCurrencySymbol) else {
            restoreOldRateCuzNewFailed(textField: aTextField)
            return
        }

        guard let rateAsCurrency: String = numberFormatterCurrency.string(
            from: rateAsDouble as NSNumber) else {
            restoreOldRateCuzNewFailed(textField: aTextField)
            return
        }

        UD.set(rateAsDouble, forKey: Const.UDef.hourlyRate)
        NC.post(name: .hourlyRateDidChange, object: nil)

        aTextField.text = rateAsCurrency

    }


    func restoreOldRateCuzNewFailed(textField: UITextField) {
        let oldHourlyRate = UD.double(forKey: Const.UDef.hourlyRate)
        textField.text = numberFormatterCurrency.string(from: oldHourlyRate as NSNumber)
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


    @objc func weekdaysChanged(sender: UIButton) {
        var oldWeekdays: [Bool] = UD.value(forKey: Const.UDef.weekdaysIWorkOn) as! [Bool]
        oldWeekdays[sender.tag].toggle()
        UD.set(oldWeekdays, forKey: Const.UDef.weekdaysIWorkOn)
        settingsTableView.reloadSections(IndexSet(integer: 2), with: .none)
    }


    // MARK: TableView

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3 // work start/end times, hourly rate, weekdays
    }


    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int) -> String? {
            return myDataSourceTitles[section]
        }


    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 2 // start time, end time
            case 1:
                return 1 // hourly rate
            case 2: // weekdays
                return 1
            default:
                fatalError()
        }
    }


    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
            case 0:
                switch indexPath.row {
                    case 0:
                        let cell = tableView.dequeueReusableCell(
                            withIdentifier: settingsTimeCell) as! SettingsTimesCell
                        cell.myLabel.text =
                        myDataSourceLabels[indexPath.section][indexPath.row]
                        cell.myPicker.tag = indexPath.row
                        fetchWorkHours(aDatePicker: cell.myPicker)
                        cell.myPicker.addTarget(
                            self,
                            action: #selector(workScheduleChanged(sender:)), for: .valueChanged)
                        return cell
                    case 1:
                        let cell = tableView.dequeueReusableCell(
                            withIdentifier: settingsTimeCell) as! SettingsTimesCell
                        cell.myLabel.text =
                        myDataSourceLabels[indexPath.section][indexPath.row]
                        cell.myPicker.tag = indexPath.row
                        fetchWorkHours(aDatePicker: cell.myPicker)
                        cell.myPicker.addTarget(
                            self,
                            action: #selector(workScheduleChanged(sender:)), for: .valueChanged)
                        return cell
                    default:
                        fatalError()
                }
            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: settingsHourlyCell) as! SettingsHourlyCell
                cell.myLabel.text = myDataSourceLabels[indexPath.section][indexPath.row]
                cell.myTextField.inputAccessoryView = addAccessoryView()
                let hourlyRate = UD.double(forKey: Const.UDef.hourlyRate)
                cell.myTextField.text = numberFormatterCurrency.string(
                    from: hourlyRate as NSNumber)
                cell.myTextField.delegate = self
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: settingsWeekdayCell)
                as! SettingsWeekdayCell

                let weekdaysArr: [Bool] = UD.value(forKey: Const.UDef.weekdaysIWorkOn)
                as! [Bool]

                for (myIndex, button) in [cell.sundayButton,
                                          cell.mondayButton,
                                          cell.tuesdayButton,
                                          cell.wednesdayButton,
                                          cell.thursdayButton,
                                          cell.fridayButton,
                                          cell.saturdayButton].enumerated() {
                    button?.tag = myIndex
                    let anAttrTitle = NSAttributedString(
                        string: Const.UIMsg.weekdaysNamesArr[myIndex],
                        attributes: Const.UIMsg.aWeekdayAttr)
                    button?.setAttributedTitle(anAttrTitle, for: .normal)

                    button?.layer.cornerRadius = (button?.frame.width ?? 1)/2
                    button?.backgroundColor = weekdaysArr[myIndex] ? .systemGreen
                    : .clear
                    button?.tintColor = .label
                    button?.addTarget(self, action: #selector(weekdaysChanged), for: .touchUpInside)

                }
                return cell
            default:
                fatalError()
        }
    }

}
