//
//  LearnFinishViewController.swift
//  shuaci
//
//  Created by Honglei on 5/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class LearnFinishViewController: UIViewController {
    
    @IBOutlet var emojiImageView: UIImageView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var goReviewBtn: UIButton!
    @IBOutlet var learnMoreBtn: UIButton!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 238, green: 241, blue: 245, alpha: 1.0)
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView(){
        DispatchQueue.main.async {
            self.greetingLabel.text = "真棒，你又学习了\(vocabRecordsOfCurrentLearning.count)个单词!"
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }

}
