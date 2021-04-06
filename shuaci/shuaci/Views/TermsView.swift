//
//  TermsView.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/20/20.
//

import UIKit
import SwiftMessages

class TermsView: MessageView, UITextViewDelegate {
    @IBOutlet var agreeBtn:UIButton!{
        didSet{
            agreeBtn.setTitle(agreeText, for: .normal)
            agreeBtn.setTitle(agreeText, for: .selected)
        }
    }
    @IBOutlet var refuseBtn:UIButton!{
        didSet{
            refuseBtn.setTitle(refuseText, for: .normal)
            refuseBtn.setTitle(refuseText, for: .selected)
        }
    }
    
    @IBOutlet var textView: UITextView!{
        didSet{
            
            let attributedString = NSMutableAttributedString(string: welcomeText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
            var privacy_range:NSRange = NSRange(location: 15, length: 4)
            var terms_range:NSRange = NSRange(location: 20, length: 4)
            if let langStr = Locale.current.languageCode
            {
                if !langStr.contains("zh"){
                    privacy_range = NSRange(location: 34, length: 18)
                    terms_range = NSRange(location: 56, length: 17)
                }
            }
            attributedString.addAttribute(.link, value: "\(githubLink)/shuaci/privacy.html", range: privacy_range)
            
            attributedString.addAttribute(.link, value: "\(githubLink)/shuaci/terms.html", range: terms_range)
            
            textView.attributedText = attributedString
            textView.textColor = .darkGray
        }
    }
    
    @IBOutlet var title:UILabel!{
        didSet{
            title.text = privacyAndTermsTitleText
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        return false
    }
    
    var agreeAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    @IBAction func agree() {
        agreeAction?()
    }
    
    @IBAction func cancel() {
        cancelAction?()
    }

}
