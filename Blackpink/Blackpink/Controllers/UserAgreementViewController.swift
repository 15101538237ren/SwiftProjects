//
//  UserAgreementViewController.swift
//  Blackpink
//
//  Created by Honglei on 10/7/20.
//

import UIKit

class UserAgreementViewController: UIViewController {
    @IBOutlet var startBtn: UIButton!{
        didSet{
            startBtn.layer.cornerRadius = 10.0
            startBtn.layer.masksToBounds = true
            startBtn.setTitleColor(BlackPinkBlack, for: .normal)
            startBtn.layer.borderWidth = 3
            startBtn.layer.borderColor = BlackPinkBlack.cgColor
        }
    }
    @IBOutlet var txtView: UITextView!{
        didSet{
            txtView.text = AgreementTxt
            txtView.textColor = .white
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureRcgToTextView()
    }
    
    @IBAction func start(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: fisrtTimeKey)
        self.dismiss(animated: true, completion: nil)
    }
    
    func addGestureRcgToTextView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(loadUserAgreement))
        txtView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func loadUserAgreement() -> Void{
        var urlcomps = URLComponents(string: userAgreementURLRoot)!
        urlcomps.path = userAgreementURLPath
        let url = urlcomps.url!
        UIApplication.shared.open(url)
        print(url)
    }
}
