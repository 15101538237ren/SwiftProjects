//
//  TextInputAlertView.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 12/9/20.
//

import UIKit

class TextInputAlertView: UIView {

    @IBOutlet weak var nameTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyLayout()
    }
    
    private func applyLayout() {
        nameTextField.placeholder = "输入显示名称"
    }
    
    class func instantiateFromNib() -> TextInputAlertView {
        return Bundle.main.loadNibNamed("TextInputAlertView", owner: self, options: nil)!.first as! TextInputAlertView
    }
}
