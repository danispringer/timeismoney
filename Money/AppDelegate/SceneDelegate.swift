//
//  SceneDelegate.swift
//  Money
//
//  Created by Daniel Springer on 11/13/22.
//  Copyright © 2024 Daniel Springer. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the
        // provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized
        // and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see
        // `application:configurationForConnectingSceneSession` instead).
        guard scene as? UIWindowScene != nil else { return }
    }

}
