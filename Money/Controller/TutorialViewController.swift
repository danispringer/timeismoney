//
//  TutorialViewController.swift
//  Money
//
//  Created by Daniel Springer on 12/3/22.
//  Copyright © 2024 Daniel Springer. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var tutorialTextView: UITextView!


    // MARK: Properties

    var delegate: SettingsPresenter?

    // MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if CommandLine.arguments.contains("--moneyScreenshots") {
            // We are in testing mode, make arrangements if needed
            UIView.setAnimationsEnabled(false)
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tutorialTextView.flashScrollIndicators()

    }


    // MARK: Helpers

    @IBAction func doneTapped(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.presentSettings()
        }
    }

}
