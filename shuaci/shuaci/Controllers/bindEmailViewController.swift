//
//  bindEmailViewController.swift
//  shuaci
//
//  Created by Honglei on 7/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class bindEmailViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var emailBindBtn: UIButton!{
        didSet {
            emailBindBtn.layer.cornerRadius = 9.0
            emailBindBtn.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }

}
