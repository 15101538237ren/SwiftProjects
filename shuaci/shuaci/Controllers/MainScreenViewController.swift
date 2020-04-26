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
    @IBOutlet var card: CardUIView!
    
    @IBAction func close(segue:UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

