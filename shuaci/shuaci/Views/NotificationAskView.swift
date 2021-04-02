//
//  NotificationAskView.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/20/20.
//

import UIKit
import SwiftMessages

class NotificationAskView: MessageView, UITextViewDelegate {
    @IBOutlet var textView: UITextView!
    
    var agreeAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    @IBAction func agree() {
        agreeAction?()
    }
    
    @IBAction func cancel() {
        cancelAction?()
    }

}
