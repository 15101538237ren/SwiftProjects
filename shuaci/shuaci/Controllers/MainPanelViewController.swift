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
    @IBOutlet var userPhotoBtn: UIButton!{
        didSet {
            userPhotoBtn.layer.cornerRadius = userPhotoBtn.layer.frame.width/2.0
            userPhotoBtn.layer.masksToBounds = true
        }
    }
    
    var words = [["wordHead":"flower", "trans": "花"], ["wordHead":"Lilac", "trans": "紫丁香"]]
    func updateUserPhoto() {
        if let userImage = loadUserPhoto() {
            self.userPhotoBtn.setImage(userImage, for: [])
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = .white
        
        if let user = LCApplication.default.currentUser {
            // 跳到首页
            let word = words[1]
            wordLabel.text = word["wordHead"]
            meaningLabel.text = word["trans"]
            todayImageView?.image = UIImage(named: word["wordHead"]!)
            if let userImage = loadUserPhoto() {
                self.userPhotoBtn.setImage(userImage, for: [])
            }
            else {
                do {
                    if let photoData = user.get("avatar") as? LCFile {
                        //let imgData = photoData.value as! LCData
                        let url = URL(string: photoData.url?.value as! String)!
                        let data = try? Data(contentsOf: url)
                        print(url)
                        if let imageData = data {
                            let image = UIImage(data: imageData)
                            let imageFileURL = getDocumentsDirectory().appendingPathComponent("user_avatar.jpg")
                            try? image!.jpegData(compressionQuality: 0.8)?.write(to: imageFileURL)
                            self.userPhotoBtn.setImage(image, for: [])
                        }
                    }
                } catch {
                    print(error)
                }
            }
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
//    
//    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userProfileSegue"{
            let destinationController = segue.destination as! UserProfileViewController
            destinationController.mainPanelViewController = self
        }
    }

}
