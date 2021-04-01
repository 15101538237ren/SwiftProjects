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
            
            attributedString.addAttribute(.link, value: "\(githubLink)/shuaci/privacy.html", range: NSRange(location: 15, length: 4))
            
            attributedString.addAttribute(.link, value: "\(githubLink)/shuaci/terms.html", range: NSRange(location: 20, length: 4))
            
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
    
    var agreeAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    @IBAction func agree() {
        agreeAction?()
    }
    
    @IBAction func cancel() {
        cancelAction?()
    }

}
