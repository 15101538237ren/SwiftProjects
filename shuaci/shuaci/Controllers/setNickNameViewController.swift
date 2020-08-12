//
//  setNickNameViewController.swift
//  shuaci
//
//  Created by Honglei on 7/9/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

class setNickNameViewController: UIViewController {
    var nickname: String!
    @IBOutlet var textfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        textfield.placeholder = nickname == "" ? "请输入您喜爱的昵称" : nickname
        // Do any additional setup after loading the view.
    }
    
    func setNickName(){
        
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
        self.dismiss(animated: true, completion: nil)
    }

}
