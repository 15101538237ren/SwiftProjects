//
//  MainPanelViewController.swift
//  shuaci
//
//  Created by 任红雷 on 4/25/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import LeanCloud
import AVFoundation

class MainPanelViewController: UIViewController {
    @IBOutlet var mainPanelUIView: MainPanelUIView!
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var meaningLabel: UILabel!
    @IBOutlet var todayImageView: UIImageView!
    
    var words = [["wordHead":"flower", "trans": "花"], ["wordHead":"Lilac", "trans": "紫丁香"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
        // Do any additional setup after loading the view.
        
        if let user = LCApplication.default.currentUser {
            // 跳到首页
            let word = words[1]
            wordLabel.text = word["wordHead"]
            meaningLabel.text = word["trans"]
            todayImageView?.image = UIImage(named: word["wordHead"]!)
        } else {
            // 显示注册或登录页面
            showLoginScreen()
        }
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        LCUser.logOut()
        showLoginScreen()
    }
    func showLoginScreen() {
        let LoginRegStoryBoard : UIStoryboard = UIStoryboard(name: "LoginReg", bundle:nil)
        let mainScreenViewController = LoginRegStoryBoard.instantiateViewController(withIdentifier: "StartScreen") as! MainScreenViewController
        mainScreenViewController.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(mainScreenViewController, animated: false, completion: nil)
        }
    }

}
