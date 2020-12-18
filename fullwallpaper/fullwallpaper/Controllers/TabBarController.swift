//
//  TabBarController.swift
//  fullwallpaper
//
//  Created by Honglei on 10/29/20.
//

import UIKit
import SwiftTheme

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        self.tabBar.isTranslucent = true
        self.tabBar.layer.borderWidth = 0.50
        self.tabBar.layer.borderColor = UIColor.clear.cgColor
        self.tabBar.clipsToBounds = true
        super.viewDidLoad()
    }
    
}
