//
//  NotificationAskView.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/20/20.
//

import UIKit
import SwiftMessages

class NotificationAskView: MessageView, UITextViewDelegate {
    @IBOutlet var agreeBtn:UIButton!{
        didSet{
            agreeBtn.setTitle(okText, for: .normal)
            agreeBtn.setTitle(okText, for: .selected)
        }
    }
    @IBOutlet var refuseBtn:UIButton!{
        didSet{
            refuseBtn.setTitle(refuseText, for: .normal)
            refuseBtn.setTitle(refuseText, for: .selected)
        }
    }
    @IBOutlet var title:UILabel!{
        didSet{
            title.text = notificationRequiredTitleText
        }
    }
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
