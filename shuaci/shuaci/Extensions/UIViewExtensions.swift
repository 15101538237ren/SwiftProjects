//
//  UIViewExtensions.swift
//  shuaci
//
//  Created by 任红雷 on 5/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

import UIKit
extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
       let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
       rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2.0)
       rotateAnimation.duration = duration
       if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
       }
    self.layer.add(rotateAnimation, forKey: nil)
   }
}
