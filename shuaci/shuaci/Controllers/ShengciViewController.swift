//
//  ShengciViewController.swift
//  shuaci
//
//  Created by 任红雷 on 5/1/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class ShengciViewController: UIViewController {

    override func viewDidLoad() {
        view.backgroundColor = UIColor(red: 238, green: 241, blue: 245, alpha: 1.0)
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // remove left buttons (in case you added some)
         self.navigationItem.leftBarButtonItems = []
        // hide the default back buttons
         self.navigationItem.hidesBackButton = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
