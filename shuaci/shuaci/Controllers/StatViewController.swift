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
    
    var learnStatusByDaySelected: Bool = true
    @IBOutlet weak var learnStatusByDayLabel: UILabel!
    @IBOutlet weak var learnStatusByMonLabel: UILabel!
    @IBOutlet weak var learnStatusByDayIndicator: UIButton!
    @IBOutlet weak var learnStatusByMonIndicator: UIButton!
    
    var masteredChartView = AAChartView()
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
    
    func setUpLearnStatusSelected(initial: Bool = false){
        if !initial{
            let masteredStatusChartModel = getLearnStatusModel()
            masteredChartView.aa_refreshChartWholeContentWithChartModel(masteredStatusChartModel)
        }
        
        DispatchQueue.main.async {
            self.learnStatusByDayLabel.textColor = self.learnStatusByDaySelected ? .black : .lightGray
            self.learnStatusByMonLabel.textColor = self.learnStatusByDaySelected ? .lightGray : .black
            self.learnStatusByDayIndicator.alpha = self.learnStatusByDaySelected ? 1.0 : 0.0
            self.learnStatusByMonIndicator.alpha = self.learnStatusByDaySelected ? 0.0 : 1.0
        }
    }
    
    @objc func tappedLearnStatusByDay(sender:UITapGestureRecognizer) {
        if learnStatusByDaySelected == false{
            learnStatusByDaySelected = true
            setUpLearnStatusSelected()
        }
    }
    
    @objc func tappedLearnStatusByMon(sender:UITapGestureRecognizer) {
        if learnStatusByDaySelected == true{
            learnStatusByDaySelected = false
            setUpLearnStatusSelected()
        }
    }
    func getLearnStatusModel() -> AAChartModel{
        let minMaxDates:[Date] = getMinMaxDateOfVocabRecords()
        let intervalDates:[Date] = generateDatesForMinMaxDates(minMaxDates: minMaxDates, byDay: learnStatusByDaySelected)
        let categories:[String] = formatDateAsCategory(dates: intervalDates, byDay: learnStatusByDaySelected)
        print(intervalDates)
        let cumMasteredCount:[Int] = getCumulatedMasteredByDate(dates: intervalDates, byDay: learnStatusByDaySelected)
        let cumLearnedCount:[Int] = getCumulatedLearnedByDate(dates: intervalDates, byDay: learnStatusByDaySelected)
        
        let masteredStatusChartModel = AAChartModel()
            .chartType(.line)//Can be any of the chart types listed under `AAChartType`.
            .animationType(.elastic)
        .tooltipValueSuffix("词")//the value suffix of the chart tooltip
        .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
        .yAxisVisible(false)
        .categories(categories)
        .colorsTheme(["#4fa83d","#3f8ada"])
        .series([
            AASeriesElement()
            .name("已学习")
            .data(cumLearnedCount),
            AASeriesElement()
                .name("已掌握")
                .data(cumMasteredCount)])
        return masteredStatusChartModel
    }
    override func viewDidLoad() {
        getStatOfToday()
        setUpLearnStatusSelected(initial: true)
        
        let tapLearnStatusByDay = UITapGestureRecognizer(target: self, action: #selector(tappedLearnStatusByDay))
        
        let tapLearnStatusByMon = UITapGestureRecognizer(target: self, action: #selector(tappedLearnStatusByMon))
        
        learnStatusByDayLabel.addGestureRecognizer(tapLearnStatusByDay)
        learnStatusByMonLabel.addGestureRecognizer(tapLearnStatusByMon)
        
        masteredChartView.frame = CGRect(x: 0, y: 0, width: masteredAndLearnedCurveView.bounds.width, height: masteredAndLearnedCurveView.bounds.height)
        masteredAndLearnedCurveView.addSubview(masteredChartView)
        masteredChartView.aa_drawChartWithChartModel(getLearnStatusModel())
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
            if learning_mins_today > 1.0 || number_of_learning_secs_today == 0{
                self.numMinutesTodayLabel.text = String(format: "%d", Int(round(learning_mins_today)))
            }
            else{
                self.numMinutesTodayLabel.text = String(format: "%.1f", learning_mins_today)
            }
            let learning_mins_cummulated =  Double(number_of_learning_secs_cummulated)/60.0
            
            if learning_mins_cummulated > 1.0 || number_of_learning_secs_cummulated == 0{
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
