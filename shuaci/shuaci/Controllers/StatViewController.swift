//
//  StatViewController.swift
//  shuaci
//
//  Created by Honglei on 7/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import AAInfographics

class StatViewController: UIViewController {
    @IBOutlet var numWordTodayLabel: UILabel!
    @IBOutlet var numMinutesTodayLabel: UILabel!
    @IBOutlet var numWordCumulatedLabel: UILabel!
    @IBOutlet var numMinutesCumulatedLabel: UILabel!
    
    var viewByDates:[Bool] = [true, true, true]
    
    @IBOutlet var masteredStatusView: UIView!{
        didSet {
            masteredStatusView?.layer.cornerRadius = 15.0
            masteredStatusView?.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var overView: UIView!{
        didSet {
            overView?.layer.cornerRadius = 15.0
            overView?.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var masteredAndLearnedCurveView: UIView!{
        didSet {
            masteredAndLearnedCurveView?.layer.cornerRadius = 15.0
            masteredAndLearnedCurveView?.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        let minMaxDates:[Date] = getMinMaxDateOfVocabRecords()
        print(minMaxDates)
        getStatOfToday()
        view.isOpaque = false
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    func getStatOfToday(){
        let today = Date()
        let todayLearnRec = getLearningRecordsOf(date: today)
        let todayReviewRec = getReviewRecordsOf(date: today)
        var number_of_vocab_today:Int = 0
        var number_of_learning_secs_today: Int = 0
        for lrec in todayLearnRec{
            number_of_vocab_today += lrec.VocabRecIds.count
            let difference = Calendar.current.dateComponents([.second], from: lrec.StartDate, to: lrec.EndDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        for rrec in todayReviewRec{
            number_of_vocab_today += rrec.VocabRecIds.count
            let difference = Calendar.current.dateComponents([.second], from: rrec.StartDate, to: rrec.EndDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        
        var number_of_vocab_cummulated:Int = 0
        var number_of_learning_secs_cummulated: Int = 0
        for lrec in GlobalLearningRecords{
            number_of_vocab_cummulated += lrec.VocabRecIds.count
            let difference = Calendar.current.dateComponents([.second], from: lrec.StartDate, to: lrec.EndDate)
            if let secondT = difference.second {
                number_of_learning_secs_cummulated += secondT
            }
        }
        for rrec in GlobalReviewRecords{
            let difference = Calendar.current.dateComponents([.second], from: rrec.StartDate, to: rrec.EndDate)
            if let secondT = difference.second {
                number_of_learning_secs_cummulated += secondT
            }
        }
        
        DispatchQueue.main.async {
            self.numWordTodayLabel.text = "\(number_of_vocab_today)"
            self.numWordCumulatedLabel.text = "\(number_of_vocab_cummulated)"
            let learning_mins_today = Double(number_of_learning_secs_today)/60.0
            if learning_mins_today > 1.0{
                self.numMinutesTodayLabel.text = String(format: "%d", Int(round(learning_mins_today)))
            }
            else{
                self.numMinutesTodayLabel.text = String(format: "%.1f", learning_mins_today)
            }
            let learning_mins_cummulated =  Double(number_of_learning_secs_cummulated)/60.0
            
            if learning_mins_cummulated > 1.0{
                self.numMinutesCumulatedLabel.text = String(format: "%d", Int(round(learning_mins_cummulated)))
            }
            else{
                self.numMinutesCumulatedLabel.text = String(format: "%.1f", learning_mins_cummulated)
            }
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }

}
