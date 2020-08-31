//
//  CardBackView.swift
//  shuaci
//
//  Created by Honglei on 8/31/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit
import WebKit

class CardBackView: UIView {
    @IBOutlet var wordLabel: UILabel?{
        didSet {
            wordLabel?.numberOfLines = 0
        }
    }
    var indicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    @IBOutlet var webView: WKWebView!
    
    @IBOutlet var interpLabel: UILabel!{
        didSet {
            interpLabel.textColor = .darkGray
        }
    }
    @IBOutlet var interpIndicator: UIButton!{
        didSet {
            interpIndicator.alpha = 1
        }
    }
    @IBOutlet var wordRootLabel: UILabel!{
        didSet {
            wordRootLabel.textColor = .lightGray
        }
    }
    
    @IBOutlet var wordRootIndicator: UIButton!{
        didSet {
            wordRootIndicator.alpha = 0
        }
    }
    
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
        effectView.frame = CGRect(x: self.frame.midX - strLabel.frame.width/2, y: self.frame.midY - strLabel.frame.height/2 , width: 160, height: height)
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
        self.addSubview(effectView)
    }
    
    func stopIndicator(){
        self.indicator.stopAnimating()
        self.indicator.hidesWhenStopped = true
        self.effectView.alpha = 0
        self.strLabel.alpha = 0
    }
}
