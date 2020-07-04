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
        getStatOfToday()
        view.isOpaque = false
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    func getStatOfToday(){
        let today = Date()
        let todayLearnRec = getLearningRecordsOf(date: today)
        let todayReviewRec = getLearningRecordsOf(date: today)
        var number_of_vocab_today:Int = 0
        var number_of_learning_mins_today: Int = 0
        for lrec in todayLearnRec{
            number_of_vocab_today += lrec.VocabRecIds.count
            let difference = Calendar.current.dateComponents([.minute], from: lrec.StartDate, to: lrec.EndDate)
            if let minT = difference.minute {
                number_of_learning_mins_today += minT
            }
        }
        for rrec in todayReviewRec{
            number_of_vocab_today += rrec.VocabRecIds.count
            let difference = Calendar.current.dateComponents([.minute], from: rrec.StartDate, to: rrec.EndDate)
            if let minT = difference.minute {
                number_of_learning_mins_today += minT
            }
        }
        
        var number_of_vocab_cummulated:Int = 0
        var number_of_learning_mins_cummulated: Int = 0
        for lrec in GlobalLearningRecords{
            number_of_vocab_cummulated += lrec.VocabRecIds.count
            let difference = Calendar.current.dateComponents([.minute], from: lrec.StartDate, to: lrec.EndDate)
            if let minT = difference.minute {
                number_of_learning_mins_cummulated += minT
            }
        }
        for rrec in GlobalReviewRecords{
            number_of_vocab_cummulated += rrec.VocabRecIds.count
            let difference = Calendar.current.dateComponents([.minute], from: rrec.StartDate, to: rrec.EndDate)
            if let minT = difference.minute {
                number_of_learning_mins_cummulated += minT
            }
        }
        
        DispatchQueue.main.async {
            self.numWordTodayLabel.text = "\(number_of_vocab_today)"
            self.numMinutesTodayLabel.text = "\(number_of_learning_mins_today)"
            self.numWordCumulatedLabel.text = "\(number_of_vocab_cummulated)"
            self.numMinutesCumulatedLabel.text = "\(number_of_learning_mins_cummulated)"
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }

}
