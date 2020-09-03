//
//  LearnFinishUIView.swift
//  shuaci
//
//  Created by Honglei on 5/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class LearnOrReviewFinishUIView: UIView {
    @IBOutlet var dragonBallImageView: UIImageView!
    @IBOutlet var qouteImageView: UIImageView!
    @IBOutlet var sentenceLabel: UILabel!
    @IBOutlet var transLabel: UILabel!
    @IBOutlet var cnSourceLabel: UILabel!
    @IBOutlet var numOfWordTodayValue: UILabel!
    @IBOutlet var numOfWordTodayLabel: UILabel!
    @IBOutlet var numMinuteTodayValue: UILabel!
    @IBOutlet var numMinuteTodayLabel: UILabel!
    @IBOutlet var insistDaysValue: UILabel!
    @IBOutlet var insistDaysLabel: UILabel!
    @IBOutlet var backBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var numbOfPeopleOnline: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet weak var dimUIView: UIView!{
        didSet{
            dimUIView.theme_backgroundColor = "Global.viewBackgroundColor"
        }
    }
}
