//
//  StatViewController.swift
//  shuaci
//
//  Created by Honglei on 7/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import SwiftTheme
import LeanCloud
import ScrollableGraphView

class StatViewController: UIViewController, ScrollableGraphViewDataSource {
    
    var graphView:ScrollableGraphView? = nil
    var currentUser: LCUser!
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    var categories:[String] = []
    var cumReviewedOrMastered:[Double] = []
    var cumLearned:[Double] = []
    
    @IBOutlet weak var barTitleLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    var learnStatusByDaySelected: Bool = true
    
    @IBOutlet weak var dayMonSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var wordTimeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var perTimeCumSegmentedControl: UISegmentedControl!
    
    @IBOutlet var masteredStatusView: UIView!{
        didSet {
            masteredStatusView.theme_backgroundColor = "StatView.panelBgColor"
            masteredStatusView?.layer.cornerRadius = 15.0
            masteredStatusView?.layer.masksToBounds = true
        }
    }
    
    
    @IBOutlet var numWordTodayLabel: UILabel!
    @IBOutlet var numMinutesTodayLabel: UILabel!
    @IBOutlet var numWordCumulatedLabel: UILabel!
    @IBOutlet var numMinutesCumulatedLabel: UILabel!
    
    @IBOutlet var overView: UIView!{
        didSet {
            overView.theme_backgroundColor = "StatView.panelBgColor"
            overView?.layer.cornerRadius = 15.0
            overView?.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var statView: UIView!{
        didSet {
            statView.theme_backgroundColor = "StatView.panelBgColor"
            statView.layer.cornerRadius = 15.0
            statView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var curveView: UIView!{
        didSet {
            curveView.theme_backgroundColor = "StatView.panelBgColor"
            curveView.layer.cornerRadius = 15.0
            curveView.layer.masksToBounds = true
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
    
    func setUpLearnStatusSelected(){
        let byDay: Bool = dayMonSegmentedControl.selectedSegmentIndex == 0 ? true : false
        let byWordCnt: Bool = wordTimeSegmentedControl.selectedSegmentIndex == 0 ? true : false
        let cumulated: Bool = perTimeCumSegmentedControl.selectedSegmentIndex == 0 ? false : true
        
        let minMaxDates:[Date] = getMinMaxDateOfVocabRecords()
        let intervalDates:[Date] = generateDatesForMinMaxDates(minMaxDates: minMaxDates, byDay: byDay)
        categories = formatDateAsCategory(dates: intervalDates, byDay: byDay)
        
        if byWordCnt{
            cumReviewedOrMastered = getCumulatedMasteredByDate( dates: intervalDates, byDay: byDay, cumulated: cumulated)
            cumLearned = getCumulatedLearnedByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated)
        } else{
            cumReviewedOrMastered = getCumHoursByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated, Learn: false)
            cumLearned = getCumHoursByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated, Learn: true)
        }
        curveView.removeSubviews()
        setupPlots()
    }
    
    func getBackgroundViewColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "StatView.panelBgColor") as! String
        return viewBackgroundColor
    }
    
    func getDisplayTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "StatView.displayTextColor") as! String
        return viewBackgroundColor
    }
    
    func getSegmentedCtrlUnselectedTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "StatView.segmentedCtrlUnselectedColor") as! String
        return viewBackgroundColor
    }
    
    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
        
        if pointIndex < categories.count{
            switch(plot.identifier) {
            case "revmas":
                return cumReviewedOrMastered[pointIndex]
            case "revmasDot":
                return cumReviewedOrMastered[pointIndex]
            case "learn":
                return cumLearned[pointIndex]
            case "learnDot":
                return cumLearned[pointIndex]
            default:
                return 0.0
            }
        } else {
            return 0.0
        }
    }

    func label(atIndex pointIndex: Int) -> String {
        return categories[pointIndex]
    }

    func numberOfPoints() -> Int {
        return categories.count
    }
    
    func setFontofSegmentedControl(selectedForeGroundColor: UIColor){
        dayMonSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        wordTimeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        perTimeCumSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
    }
    
    func setupPlots(){
        
        graphView = ScrollableGraphView(frame: CGRect(x: 0, y: 0, width: curveView.bounds.width, height: curveView.bounds.height), dataSource: self)
        graphView!.theme_backgroundColor = "Global.viewBackgroundColor"
        

        let revmasLinePlot = LinePlot(identifier: "revmas")
        revmasLinePlot.lineWidth = 2
        revmasLinePlot.lineColor = UIColor(hex: "#3f8ada")!
        revmasLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        revmasLinePlot.shouldFill = false
        revmasLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        
        let revmasDot = DotPlot(identifier: "revmasDot") // Add dots as well.
        revmasDot.dataPointSize = 3
        revmasDot.dataPointFillColor = UIColor(hex: "#3f8ada")!
        revmasDot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic

        
        let learnLinePlot = LinePlot(identifier: "learn")
        learnLinePlot.lineWidth = 2
        learnLinePlot.lineColor = UIColor(hex: "#4fa83d")!
        learnLinePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
        learnLinePlot.shouldFill = false
        learnLinePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic

        let learnDot = DotPlot(identifier: "learnDot") // Add dots as well.
        learnDot.dataPointSize = 3
        learnDot.dataPointFillColor = UIColor(hex: "#4fa83d")!
        learnDot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        
        let referenceLines = ReferenceLines()
        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 12)
        referenceLines.referenceLineColor = UIColor.lightGray.withAlphaComponent(0.2)
        referenceLines.referenceLineLabelColor = UIColor.lightGray
        referenceLines.includeMinMax = true
        referenceLines.dataPointLabelColor = UIColor.lightGray.withAlphaComponent(1)
        referenceLines.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 12)
        referenceLines.shouldShowLabels = true
        
        graphView!.backgroundFillColor = UIColor.white
        graphView!.dataPointSpacing = 50
        graphView!.shouldAnimateOnStartup = false
        graphView!.shouldAdaptRange = true
        graphView!.shouldRangeAlwaysStartAtZero = false
        graphView!.topMargin = 20
        
        graphView!.addPlot(plot: revmasLinePlot)
        graphView!.addPlot(plot: revmasDot)
        graphView!.addPlot(plot: learnLinePlot)
        graphView!.addPlot(plot: learnDot)
        graphView!.addReferenceLines(referenceLines: referenceLines)
        
        curveView.addSubview(graphView!)
        
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        setFontofSegmentedControl(selectedForeGroundColor: .white)
        setupPlots()
        setUpLearnStatusSelected()
        view.isOpaque = false
        
        getStatOfToday()
        super.viewDidLoad()
        
        let font = UIFont.systemFont(ofSize: 10)
        dayMonSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray, NSAttributedString.Key.font: font], for: .normal)
        wordTimeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray, NSAttributedString.Key.font: font], for: .normal)
        perTimeCumSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray, NSAttributedString.Key.font: font], for: .normal)
        // Do any additional setup after loading the view.
        
        dayMonSegmentedControl.theme_selectedSegmentTintColor = "StatView.segmentedCtrlSelectedTintColor"
        wordTimeSegmentedControl.theme_selectedSegmentTintColor = "StatView.segmentedCtrlSelectedTintColor"
        perTimeCumSegmentedControl.theme_selectedSegmentTintColor = "StatView.segmentedCtrlSelectedTintColor"
    }
    
    func getStatOfToday(){
        let today = Date()
        
        let today_records = getRecordsOfDate(date: today)
        let todayLearnRec = today_records.filter { $0.recordType == 1}
        let todayReviewRec = today_records.filter { $0.recordType == 2}
        var number_of_vocab_today:Int = 0
        var number_of_learning_secs_today: Int = 0
        for lrec in todayLearnRec{
            number_of_vocab_today += lrec.vocabHeads.count
            let difference = Calendar.current.dateComponents([.second], from: lrec.startDate, to: lrec.endDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        for rrec in todayReviewRec{
            number_of_vocab_today += rrec.vocabHeads.count
            let difference = Calendar.current.dateComponents([.second], from: rrec.startDate, to: rrec.endDate)
            if let secondT = difference.second {
                number_of_learning_secs_today += secondT
            }
        }
        
        var number_of_vocab_cummulated:Int = 0
        var number_of_learning_secs_cummulated: Int = 0
        
        let global_learning_records = global_records.filter { $0.recordType == 1}
        let global_review_records = global_records.filter { $0.recordType == 2}
        
        for lrec in global_learning_records{
            number_of_vocab_cummulated += lrec.vocabHeads.count
            let difference = Calendar.current.dateComponents([.second], from: lrec.startDate, to: lrec.endDate)
            if let secondT = difference.second {
                number_of_learning_secs_cummulated += secondT
            }
        }
        for rrec in global_review_records{
            let difference = Calendar.current.dateComponents([.second], from: rrec.startDate, to: rrec.endDate)
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

