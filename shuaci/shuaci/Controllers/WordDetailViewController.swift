//
//  WordDetailViewController.swift
//  shuaci
//
//  Created by Honglei on 8/27/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import WebKit
import LeanCloud
import SwiftTheme

class WordDetailViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    @IBOutlet var dimUIView: UIView!
    var indicator = UIActivityIndicatorView()
    var mainPanelViewController: MainPanelViewController!
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    var wordIndex: Int!
    
    func initActivityIndicator(text: String) {
        strLabel.removeFromSuperview()
        indicator.removeFromSuperview()
        effectView.removeFromSuperview()
        let height:CGFloat = 46.0
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: height))
        strLabel.text = text
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = .darkGray
        strLabel.alpha = 1.0
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: height)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 244, green: 244, blue: 245, alpha: 1.0)
        
        effectView.alpha = 1.0
        indicator = .init(style: .medium)
        indicator.frame = CGRect(x: 0, y: 0, width: height, height: height)
        indicator.alpha = 1.0
        indicator.startAnimating()

        effectView.contentView.addSubview(indicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dimUIView.theme_alpha = "MainPanel.dimAlpha"
        loadHTML()
//        self.webView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    func loadHTML(){
        initActivityIndicator(text: getWordText)
        
        if Reachability.isConnectedToNetwork(){
            DispatchQueue.global(qos: .background).async {
            do {
                let query = LCQuery(className: "OALECD8")
                query.whereKey("word_id" , .equalTo(self.wordIndex))
                _ = query.getFirst { result in
                    switch result {
                    case .success(object: let word):
                        if let html_content = word.get("html_content")?.stringValue
                        {
                            let html_final = build_html_with_given_content(html_content: html_content)
                            self.webView.loadHTMLString(html_final, baseURL: nil)
                            self.stopIndicator()
                        }else{
                            self.stopIndicator()
                            self.dismiss(animated: true, completion: nil)
                        }
                        break
                    case .failure(error: let error):
                        print(error)
                    }
                }
                }}
        }else{
            self.view.makeToast(NoNetworkStr, duration: 1.0, position: .center)
        }
    }
    
    @IBAction func unwind(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?){
        if let currentUser = LCApplication.default.currentUser {
            var pref = loadPreference(userId: currentUser.objectId!.stringValue!)
            if traitCollection.userInterfaceStyle == .dark{
                pref.dark_mode = true
            }else{
                pref.dark_mode = false
            }
            savePreference(userId: currentUser.objectId!.stringValue!, preference: pref)
            mainPanelViewController.update_preference()
            mainPanelViewController.loadWallpaper(force: true)
            if pref.dark_mode{
                ThemeManager.setTheme(plistName: "Night", path: .mainBundle)
            } else {
                ThemeManager.setTheme(plistName: theme_category_to_name[pref.current_theme]!.rawValue, path: .mainBundle)
            }
        }
    }
}
