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
import AAInfographics

class StatViewController: UIViewController{
    
    var masteredChartView = AAChartView()
    var currentUser: LCUser!
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    var categories:[String] = []
    var cumReviewedOrMastered:[Double] = []
    var cumLearned:[Double] = []
    
    @IBOutlet weak var barTitleLabel: UILabel!
    @IBOutlet weak var asbtractLabel: UILabel!
    @IBOutlet weak var curveLabel: UILabel!
    
    @IBOutlet weak var todayLearnWLabel: UILabel!
    @IBOutlet weak var todayLearnMinLabel: UILabel!
    
    @IBOutlet weak var cumLearnMinLabel: UILabel!
    @IBOutlet weak var cumLearnWLabel: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var learningStackView: UIStackView!
    
    var learnStatusByDaySelected: Bool = true
    
    @IBOutlet weak var dataTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var dayMonSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var wordTimeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var perTimeCumSegmentedControl: UISegmentedControl!
    
    @IBOutlet var masteredAndLearnedCurveView: UIView!{
        didSet {
            masteredAndLearnedCurveView.theme_backgroundColor = "StatView.panelBgColor"
            masteredAndLearnedCurveView?.layer.cornerRadius = 15.0
            masteredAndLearnedCurveView?.layer.masksToBounds = true
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
    
    @IBAction func dataTypeChanged(_ sender: UISegmentedControl) {
        
        masteredAndLearnedCurveView.removeSubviews()
        
        if sender.selectedSegmentIndex == 1{
            initMasterChartView(dataType: .learnStatus)
        }else if sender.selectedSegmentIndex == 0{
            initMasterChartView(dataType: .ebbinhaus)
        }else{
            initMasterChartView(dataType: .lasting)
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
            let cumMasteredCount:[Double] = getCumulatedMasteredByDate( dates: intervalDates, byDay: byDay, cumulated: cumulated)
            let cumLearnedCount:[Double] = getCumulatedLearnedByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated)
            
            let masteredStatusChartModel = AAChartModel()
            .backgroundColor(getBackgroundViewColor())
                .chartType(.spline)//cumulated ? .spline : .column)//Can be any of the chart types listed under `AAChartType`.
                .animationType(.elastic)
            .tooltipValueSuffix(suffixLabel)//the value suffix of the chart tooltip
            .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
            .yAxisLabelsEnabled(true)
            .yAxisTitle("单词量")
            .categories(categories)
            .colorsTheme(["#4fa83d","#3f8ada"])
            .zoomType(.x)
            .xAxisLabelsStyle(AAStyle(color: getDisplayTextColor()))
            .yAxisLabelsStyle(AAStyle(color: getDisplayTextColor()))
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
            let cumReviewedHours:[Double] = getCumHoursByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated, Learn: false)
            let cumLearnedHours:[Double] = getCumHoursByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated, Learn: true)
            
            let masteredStatusChartModel = AAChartModel()
            .backgroundColor(getBackgroundViewColor())
                .chartType(.spline)//cumulated ? .spline : .column)//Can be any of the chart types listed under `AAChartType`.
                .animationType(.elastic)
            .tooltipValueSuffix(suffixLabel)//the value suffix of the chart tooltip
            .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
            .yAxisLabelsEnabled(true)
            .yAxisTitle("分钟")
            .categories(categories)
            .yAxisAllowDecimals(false)
            .zoomType(.x)
            .colorsTheme(["#4fa83d","#3f8ada"])
            .xAxisLabelsStyle(AAStyle(color: getDisplayTextColor()))
            .yAxisLabelsStyle(AAStyle(color: getDisplayTextColor()))
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
    
    func getEbbinhausOptions() -> AAOptions{
        let retentions = getRetentionsFromVocabRecords()
        var series:[AASeriesElement] = []
        if retentions.count > 0{
            series = [
                AASeriesElement()
                .name("艾宾浩斯曲线")
                .data(retentionOfEbbinhaus),
                AASeriesElement()
                .name("你的记忆规律")
                .data(retentions)]
        }
        else{
            series = [
                AASeriesElement()
                .name("艾宾浩斯曲线")
                .data(retentionOfEbbinhaus)]
        }
        let ebbinhausStatusChartModel = AAChartModel()
        .backgroundColor(getBackgroundViewColor())
            .chartType(.line)
            .animationType(.elastic)
        .tooltipValueSuffix("%")//the value suffix of the chart tooltip
        .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
        .yAxisLabelsEnabled(true)
        .yAxisTitle("记得的百分比(%)")
        .yAxisMax(100.0)
        .categories(hoursLabels)
        .xAxisLabelsStyle(AAStyle(color: getDisplayTextColor()))
        .yAxisLabelsStyle(AAStyle(color: getDisplayTextColor()))
        .colorsTheme(["#bfc0c0","#ef8354"])
            .zoomType(.none)
        .series(series)
        let aa_options: AAOptions = AAOptionsConstructor.configureChartOptions(ebbinhausStatusChartModel)
        aa_options.tooltip?.valueDecimals(1)
        return aa_options
    }
    
    func getLongTermOptions() -> AAOptions{
        let vocabNums = getLongTermMemNumbers()
        let series:[AASeriesElement] = [
            AASeriesElement()
            .name("当前的单词长期掌握度")
            .data(vocabNums)]
        let longTermVocabRememberedChartModel = AAChartModel()
        .backgroundColor(getBackgroundViewColor())
            .chartType(.line)
            .animationType(.elastic)
        .tooltipValueSuffix("个")//the value suffix of the chart tooltip
        .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
        .yAxisLabelsEnabled(true)
        .yAxisTitle("记得的单词数")
        .categories(daysLabels)
        .xAxisLabelsStyle(AAStyle(color: getDisplayTextColor()))
        .yAxisLabelsStyle(AAStyle(color: getDisplayTextColor()))
        .colorsTheme(["#ef8354"])
            .zoomType(.none)
        .series(series)
        let aa_options: AAOptions = AAOptionsConstructor.configureChartOptions(longTermVocabRememberedChartModel)
        aa_options.tooltip?.valueDecimals(0)
        return aa_options
    }
    
    func getBackgroundViewColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "StatView.panelBgColor") as! String
        return viewBackgroundColor
    }
    
    func getDisplayTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "StatView.displayTextColor") as! String
        if let color = UIColor.init(hex: viewBackgroundColor){
            let rgba = color.rgba
            return AAColor.rgbaColor(Int(rgba.red * CGFloat(255.0)), Int(rgba.green * CGFloat(255.0)), Int(rgba.blue * CGFloat(255.0)))
        }
        return AAColor.white
    }
    
    func getSegmentedCtrlUnselectedTextColor() -> String{
        let viewBackgroundColor = ThemeManager.currentTheme?.value(forKeyPath: "StatView.segmentedCtrlUnselectedColor") as! String
        return viewBackgroundColor
    }
    
    func setFontofSegmentedControl(selectedForeGroundColor: UIColor){
        dataTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        dayMonSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        wordTimeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        perTimeCumSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
    }
    
    enum DataType {
        case learnStatus
        case ebbinhaus
        case lasting
    }
    
    func initMasterChartView(dataType: DataType){
        if dataTypeSegmentedControl.selectedSegmentIndex == 1{
            learningStackView.alpha = 1
        }else{
            learningStackView.alpha = 0
        }
        masteredChartView.frame = CGRect(x: 0, y: 0, width: masteredAndLearnedCurveView.bounds.width, height: masteredAndLearnedCurveView.bounds.height)
        masteredChartView.contentWidth = masteredAndLearnedCurveView.bounds.width
        masteredChartView.theme_backgroundColor = "StatView.panelBgColor"
        masteredAndLearnedCurveView.addSubview(masteredChartView)
        switch dataType {
        case .learnStatus:
            masteredChartView.aa_drawChartWithChartOptions(getLearnStatusOptions())
        case .ebbinhaus:
            masteredChartView.aa_drawChartWithChartOptions(getEbbinhausOptions())
        case .lasting:
            masteredChartView.aa_drawChartWithChartOptions(getLongTermOptions())
        }
    }
    
    func setupTheme(){
        view.isOpaque = false
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        masteredAndLearnedCurveView.theme_backgroundColor = "StatView.panelBgColor"
        
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        
        asbtractLabel.theme_textColor = "Global.barTitleColor"
        curveLabel.theme_textColor = "Global.barTitleColor"
        
        todayLearnWLabel.theme_textColor = "Global.barTitleColor"
        todayLearnMinLabel.theme_textColor = "Global.barTitleColor"
        cumLearnWLabel.theme_textColor = "Global.barTitleColor"
        cumLearnMinLabel.theme_textColor = "Global.barTitleColor"
        
        numWordTodayLabel.theme_textColor = "Global.barTitleColor"
        numMinutesTodayLabel.theme_textColor = "Global.barTitleColor"
        numWordCumulatedLabel.theme_textColor = "Global.barTitleColor"
        numMinutesCumulatedLabel.theme_textColor = "Global.barTitleColor"
        
        masteredChartView.theme_backgroundColor = "Global.viewBackgroundColor"
        setFontofSegmentedControl(selectedForeGroundColor: .white)
        dataTypeSegmentedControl.theme_selectedSegmentTintColor = "StatView.segmentedCtrlSelectedTintColor"
        dayMonSegmentedControl.theme_selectedSegmentTintColor = "StatView.segmentedCtrlSelectedTintColor"
        wordTimeSegmentedControl.theme_selectedSegmentTintColor = "StatView.segmentedCtrlSelectedTintColor"
        perTimeCumSegmentedControl.theme_selectedSegmentTintColor = "StatView.segmentedCtrlSelectedTintColor"
        
        
        let font = UIFont.systemFont(ofSize: 10)
        dataTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray, NSAttributedString.Key.font: font], for: .normal)
        dayMonSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray, NSAttributedString.Key.font: font], for: .normal)
        wordTimeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray, NSAttributedString.Key.font: font], for: .normal)
        perTimeCumSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(hex: getSegmentedCtrlUnselectedTextColor()) ?? .darkGray, NSAttributedString.Key.font: font], for: .normal)
    }
    
    override func viewDidLoad() {
        setupTheme()
        
        view.isOpaque = false
        setUpLearnStatusSelected(initial: true)
        initMasterChartView(dataType: .ebbinhaus)
        getStatOfToday()
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        
        let number_of_vocab_cummulated:Int = global_vocabs_records.count
        var number_of_learning_secs_cummulated: Int = 0
        
        for rrec in global_records{
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if traitCollection.userInterfaceStyle == .light {
            ThemeManager.setTheme(plistName: "Light_White", path: .mainBundle)
        } else {
            ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
        }
    }
}

