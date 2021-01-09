//
//  StatViewController.swift
//  shuaci
//
//  Created by Honglei on 7/3/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import AAInfographics
import SwiftTheme
import LeanCloud

class StatViewController: UIViewController {
    
    var currentUser: LCUser!
    var mainPanelViewController: MainPanelViewController!
    var preference:Preference!
    
    
    @IBOutlet var displayLabels: [UILabel]!
    
    @IBOutlet weak var barTitleLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    var learnStatusByDaySelected: Bool = true
    
    @IBOutlet weak var dayMonSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var wordTimeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var perTimeCumSegmentedControl: UISegmentedControl!
    
    var masteredChartView = AAChartView()
    
    @IBOutlet var masteredStatusView: UIView!{
        didSet {
            masteredStatusView.theme_backgroundColor = "StatView.panelBgColor"
            masteredStatusView?.layer.cornerRadius = 15.0
            masteredStatusView?.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var masteredAndLearnedCurveView: UIView!{
        didSet {
            masteredAndLearnedCurveView.theme_backgroundColor = "StatView.panelBgColor"
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
            let cumMasteredCount:[Int] = getCumulatedMasteredByDate( dates: intervalDates, byDay: byDay, cumulated: cumulated)
            let cumLearnedCount:[Int] = getCumulatedLearnedByDate(dates: intervalDates, byDay: byDay, cumulated: cumulated)
            
            let masteredStatusChartModel = AAChartModel()
            .backgroundColor(getBackgroundViewColor())
                .chartType(.spline)//cumulated ? .spline : .column)//Can be any of the chart types listed under `AAChartType`.
                .animationType(.elastic)
            .tooltipValueSuffix(suffixLabel)//the value suffix of the chart tooltip
            .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
    //        .yAxisVisible(false)
            .categories(categories)
            .axesTextColor(getDisplayTextColor())
            .colorsTheme(["#4fa83d","#3f8ada"])
            .zoomType(.x)
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
            .backgroundColor(getBackgroundViewColor())
                .chartType(.spline)//cumulated ? .spline : .column)//Can be any of the chart types listed under `AAChartType`.
                .animationType(.elastic)
            .tooltipValueSuffix(suffixLabel)//the value suffix of the chart tooltip
            .dataLabelsEnabled(false) //Enable or disable the data labels. Defaults to false
    //        .yAxisVisible(false)
            .categories(categories)
            .axesTextColor(getDisplayTextColor())
            .yAxisAllowDecimals(false)
            .zoomType(.x)
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
    
    func setFontofSegmentedControl(selectedForeGroundColor: UIColor){
        dayMonSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        wordTimeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
        perTimeCumSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: selectedForeGroundColor], for: .selected)
    }
    
    override func viewDidLoad() {
        view.theme_backgroundColor = "Global.viewBackgroundColor"
        for label in displayLabels{
            label.theme_textColor = "StatView.displayTextColor"
        }
        backBtn.theme_tintColor = "Global.backBtnTintColor"
        barTitleLabel.theme_textColor = "Global.barTitleColor"
        setFontofSegmentedControl(selectedForeGroundColor: .white)
        setUpLearnStatusSelected(initial: true)
        
        masteredChartView.theme_backgroundColor = "Global.viewBackgroundColor"
        masteredChartView.frame = CGRect(x: 0, y: 0, width: masteredAndLearnedCurveView.bounds.width, height: masteredAndLearnedCurveView.bounds.height)
        masteredChartView.contentWidth = masteredAndLearnedCurveView.bounds.width
        masteredAndLearnedCurveView.addSubview(masteredChartView)
        masteredChartView.aa_drawChartWithChartOptions(getLearnStatusOptions())
        view.isOpaque = false
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
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }

}
