//
//  TermsView.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/20/20.
//

import UIKit
import SwiftMessages

class TermsView: MessageView, UITextViewDelegate {
    @IBOutlet var textView: UITextView!{
        didSet{
            let attributedString = NSMutableAttributedString(string: welcomeText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
            
            
            var privacy_range:NSRange = NSRange(location: 16, length: 4)
            var terms_range:NSRange = NSRange(location: 21, length: 4)
            
//            if let langStr = Locale.current.languageCode
//            {
//                if !langStr.contains("zh"){
//                    privacy_range = NSRange(location: 34, length: 18)
//                    terms_range = NSRange(location: 56, length: 17)
//                }
//            }
            
            attributedString.addAttribute(.link, value: "\(githubLink)/privacy.html", range: privacy_range)
            
            attributedString.addAttribute(.link, value: "\(githubLink)/terms.html", range: terms_range)
            
            textView.attributedText = attributedString
            textView.textColor = .darkGray
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
    
    
    @IBOutlet var title:UILabel!{
        didSet{
            title.text = privacyAndTermsTitleText
        }
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
