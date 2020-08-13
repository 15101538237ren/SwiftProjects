//
//  SetMemOptionViewController.swift
//  shuaci
//
//  Created by 任红雷 on 8/12/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class SetMemOptionViewController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memMethodLabel: UILabel!
    @IBOutlet weak var memOrderLabel: UILabel!
    @IBOutlet weak var everyDayPlanLabel: UILabel!
    @IBOutlet weak var ESTLabel: UILabel!
    @IBOutlet weak var ESTTime: UILabel!
    @IBOutlet weak var setBtn: UIButton!
    @IBOutlet weak var memMethodSegCtrl: UISegmentedControl!
    @IBOutlet weak var memOrderSegCtrl: UISegmentedControl!
    
    @IBOutlet weak var dailyNumWordPickerView: UIPickerView!
    
    @IBAction func unwind(sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDismiss(sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func addBlurBackgroundView(){
        let blurEffect = getBlurEffect()
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let btmView: UIView = UIView()
        btmView.frame = view.bounds
        btmView.backgroundColor = .white
        btmView.alpha = 0.8
        btmView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(btmView, at: 0)
        view.insertSubview(blurEffectView, at: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addBlurBackgroundView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        view.isUserInteractionEnabled = true
    }
    
}
