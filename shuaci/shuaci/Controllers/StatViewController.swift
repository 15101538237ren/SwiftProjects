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
    
    @IBOutlet weak var dayMonSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var wordTimeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var perTimeCumSegmentedControl: UISegmentedControl!
    
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
    
    @IBAction func dayMonSelectedChanged(_ sender: UISegmentedControl) {
        setUpLearnStatusSelected()
    }
    
    
    @IBAction func wordTimeSelectedChanged(_ sender: UISegmentedControl) {
        setUpLearnStatusSelected()
    }
    
    @IBAction func perTimeCumSelectedChanged(_ sender: UISegmentedControl) {
        setUpLearnStatusSelected()
    }
    
    func setUpLearnStatusSelected(initial: Bool = false){
        if !initial{
            masteredChartView.aa_refreshChartWholeContentWithChartOptions(getLearnStatusOptions())
        }
    }
    
    func getLearnStatusOptions() -> AAOptions{
        let byDay: Bool = dayMonSegmentedControl.selectedSegmentIndex == 0 ? true : false
        let byWordCnt: Bool = wordTimeSegmentedControl.selectedSegmentIndex == 0 ? true : false
        
        let cumulated: Bool = perTimeCumSegmentedControl.selectedSegmentIndex == 0 ? false : true
        let cumLabel = cumulated ? "累计" : byDay ? "当天" : "当月"
        let suffixLabel = byWordCnt ? "词" : "分钟"
        let seriesNames = byWordCnt ? ["\(cumLabel)学习", "\(cumLabel)掌握"] : ["\(cumLabel)学习", "\(cumLabel)复习"]
        
        let minMaxDates:[Date] = getMinMaxDateOfVocabRecords()
        let intervalDates:[Date] = generateDatesForMinMaxDates(minMaxDates: minMaxDates, byDay: byDay)
        let categories:[String] = formatDateAsCategory(dates: intervalDates, byDay: byDay)
        if byWordCnt{
            let cumMasteredCount:[Int] = getCumulatedMasteredByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated)
            let cumLearnedCount:[Int] = getCumulatedLearnedByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated)
            
            let masteredStatusChartModel = AAChartModel()
                .chartType(.spline)//cumulated ? .spline : .column)//Can be any of the chart types listed under `AAChartType`.
                .animationType(.elastic)
            .tooltipValueSuffix(suffixLabel)//the value suffix of the chart tooltip
            .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
    //        .yAxisVisible(false)
            .categories(categories)
            .colorsTheme(["#4fa83d","#3f8ada"])
            .series([
                AASeriesElement()
                .name(seriesNames[0])
                .data(cumLearnedCount),
                AASeriesElement()
                    .name(seriesNames[1])
                    .data(cumMasteredCount)])
            let aa_options: AAOptions = AAOptionsConstructor.configureChartOptions(masteredStatusChartModel)
            return aa_options
        } else{
            let cumReviewedHours:[Float] = getCumHoursByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated, Learn: false)
            let cumLearnedHours:[Float] = getCumHoursByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated, Learn: true)
            
            let masteredStatusChartModel = AAChartModel()
                .chartType(.spline)//cumulated ? .spline : .column)//Can be any of the chart types listed under `AAChartType`.
                .animationType(.elastic)
            .tooltipValueSuffix(suffixLabel)//the value suffix of the chart tooltip
            .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
    //        .yAxisVisible(false)
            .categories(categories)
            .yAxisAllowDecimals(false)
            .colorsTheme(["#4fa83d","#3f8ada"])
            .series([
                AASeriesElement()
                .name(seriesNames[0])
                .data(cumLearnedHours),
                AASeriesElement()
                    .name(seriesNames[1])
                    .data(cumReviewedHours)])
            let aa_options: AAOptions = AAOptionsConstructor.configureChartOptions(masteredStatusChartModel)
            aa_options.tooltip?.valueDecimals(1)
            return aa_options
        }
        
    }
    
    func setFontofSegmentedControl(font: UIFont, selectedForeGroundColor: UIColor){
        dayMonSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        wordTimeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        perTimeCumSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        dayMonSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        wordTimeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        perTimeCumSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
    }
    
    override func viewDidLoad() {
        setFontofSegmentedControl(font: UIFont.systemFont(ofSize: 10), selectedForeGroundColor: .white)
        getStatOfToday()
        setUpLearnStatusSelected(initial: true)
        
        masteredChartView.frame = CGRect(x: 0, y: 0, width: masteredAndLearnedCurveView.bounds.width, height: masteredAndLearnedCurveView.bounds.height)
        masteredAndLearnedCurveView.addSubview(masteredChartView)
        masteredChartView.aa_drawChartWithChartOptions(getLearnStatusOptions())
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
