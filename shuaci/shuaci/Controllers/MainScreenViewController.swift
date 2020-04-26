//
//  ViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/23/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud

class MainScreenViewController: UIViewController {
    
    @IBAction func close(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
//        if let user = LCApplication.default.currentUser {
//            // 跳到首页
//            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let mainPanelViewController = storyBoard.instantiateViewController(withIdentifier: "mainPanelViewController") as! MainPanelViewController
//
//            DispatchQueue.main.async {
//                self.present(mainPanelViewController, animated: true, completion: nil)
//            }
//        }
    }
}

