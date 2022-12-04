//
//  TutorialViewController.swift
//  Money
//
//  Created by dani on 12/3/22.
//

import UIKit

class TutorialViewController: UIViewController {

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if CommandLine.arguments.contains("--moneyScreenshots") {
            // We are in testing mode, make arrangements if needed
            UIView.setAnimationsEnabled(false)
        }

    }


    // MARK: Helpers

    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true)
    }

}
