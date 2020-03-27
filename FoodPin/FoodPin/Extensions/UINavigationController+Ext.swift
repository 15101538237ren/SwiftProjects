//
//  UINavigationController+Ext.swift
//  FoodPin
//
//  Created by 任红雷 on 3/27/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

extension UINavigationController{
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
