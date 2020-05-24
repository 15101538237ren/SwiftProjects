//
//  LearnFinishViewController.swift
//  shuaci
//
//  Created by Honglei on 5/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class LearnFinishViewController: UIViewController {
    @IBOutlet var greetingLabel: UILabel?{
        didSet {
            greetingLabel?.numberOfLines = 0
        }
    }
    @IBOutlet var learnTimeLabel: UILabel?{
        didSet {
            learnTimeLabel?.numberOfLines = 0
        }
    }
    @IBOutlet var learnSummaryLabel: UILabel?{
        didSet {
            learnSummaryLabel?.numberOfLines = 0
        }
    }
    @IBOutlet var goToReviewBtn: UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func setLabels(greeting: String, time: String, summary: String){
        DispatchQueue.main.async {
            self.greetingLabel?.text = greeting
            self.learnTimeLabel?.text = time
            self.learnSummaryLabel?.text = summary
        }
    }
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }

}
