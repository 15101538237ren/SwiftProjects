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

class WordDetailViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    var indicator = UIActivityIndicatorView()
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
        loadHTML()
//        self.webView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
    }
    func loadHTML(){
        initActivityIndicator(text: "获取单词中..")
        
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
}
