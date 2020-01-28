//
//  SceneDelegate.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 19/12/2019.
//  Copyright © 2019 ULR ECI A1-2. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		// Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
		// This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

		if let windowScene = scene as? UIWindowScene {
		    let window = UIWindow(windowScene: windowScene)
			let tabBarVC = RootTabBarVC()
		    window.rootViewController = tabBarVC
		    self.window = window
		    window.makeKeyAndVisible()
		}
	}

}
