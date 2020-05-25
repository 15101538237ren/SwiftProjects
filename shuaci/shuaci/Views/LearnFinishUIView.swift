//
//  LearnFinishUIView.swift
//  shuaci
//
//  Created by Honglei on 5/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class LearnFinishUIView: UIView {
    @IBOutlet var emojiImageView: UIImageView!
    @IBOutlet var greetingLabel: UILabel!{
        didSet {
            greetingLabel?.numberOfLines = 0
        }
    }
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var goReviewBtn: UIButton!{
        didSet {
            goReviewBtn.layer.cornerRadius = 9.0
            goReviewBtn.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var learnMoreBtn: UIButton!{
        didSet {
            learnMoreBtn.layer.cornerRadius = 9.0
            learnMoreBtn.layer.masksToBounds = true
        }
    }

}
