//
//  SetMemOptionView.swift
//  shuaci
//
//  Created by 任红雷 on 8/12/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class SetMemOptionView: UIView {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var memMethodLabel: UILabel!
    @IBOutlet weak var memOrderLabel: UILabel!
    @IBOutlet weak var everyDayPlanLabel: UILabel!
    @IBOutlet weak var everyDayNumWordLabel: UILabel!
    @IBOutlet weak var estDaysLabel: UILabel!
    @IBOutlet weak var everayDayPlanView: UIView!{
        didSet{
            everayDayPlanView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var ESTLabel: UILabel!
    @IBOutlet weak var ESTTime: UILabel!
    @IBOutlet weak var setBtn: UIButton!
    
    @IBOutlet weak var memMethodSegCtrl: UISegmentedControl!
    @IBOutlet weak var memOrderSegCtrl: UISegmentedControl!
    
    @IBOutlet weak var dailyNumWordPickerView: UIPickerView!
    
}
