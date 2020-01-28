//
//  RootTabBarVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 25/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class RootTabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

		let alertListVC = AlertListVC(style: .insetGrouped)
		alertListVC.title = "Alertes"
		let alertListNC = UINavigationController(rootViewController: alertListVC)
		alertListNC.navigationBar.prefersLargeTitles = true
		alertListNC.tabBarItem.image = UIImage(systemName: "exclamationmark.triangle.fill") // bell.fill, exclamationmark.triangle.fill, list.bullet

		let mapVC = MapVC()
		mapVC.title = "Carte"
		mapVC.tabBarItem.image = UIImage(systemName: "map.fill") // globe, map.fill
		
		setViewControllers([alertListNC, mapVC], animated: false)
    }

}
