//
//  SettingsViewController.swift
//  Money
//
//  Created by dani on 11/16/22.
//

import UIKit

class SettingsViewController: UIViewController, UITextViewDelegate {

    // MARK: Outlets

    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!
    @IBOutlet weak var hourlyRateTextField: UITextField!


    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
