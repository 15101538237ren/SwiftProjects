//
//  ReviewViewController.swift
//  FoodPin
//
//  Created by 任红雷 on 3/28/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var rateButtons: [UIButton]!
    
    var restaurant: RestaurantMO!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let restaurantImage = restaurant.image{
            backgroundImageView.image = UIImage(data: restaurantImage as Data)
        }
        // Applying blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        // Make the buttons invisible
        let moveRightTransform = CGAffineTransform.init(translationX: 600, y: 0)
        let scaleUpTransform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        let moveScaleTransform = scaleUpTransform.concatenating(moveRightTransform)
        for rateButton in rateButtons{
            rateButton.transform = moveScaleTransform
            rateButton.alpha = 0
        }
    }
    //Slide-in annimation
    override func viewWillAppear(_ animated: Bool) {
        for ii in 0...self.rateButtons.count - 1{
            UIView.animate(withDuration: 0.4, delay: Double(ii)*0.1 + 0.1, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.02, options: [], animations: {
                self.rateButtons[ii].alpha = 1.0
                self.rateButtons[ii].transform = .identity
            }, completion: nil)
        }

    }
    
    // Fade-in effect Annimation
//    override func viewWillAppear(_ animated: Bool) {
//        for ii in 0...self.rateButtons.count - 1{
//            UIView.animate(withDuration: 0.4, delay: Double(ii)*0.1 + 0.1, options: [], animations: {
//                self.rateButtons[ii].alpha = 1.0
//            }, completion: nil)
//        }
//
//    }

}
