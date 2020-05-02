//
//  CardUIView.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class CardUIView: UIView {
    @IBOutlet var cardImageView: UIImageView?{
        didSet {
            cardImageView?.layer.cornerRadius = 20.0
            cardImageView?.layer.masksToBounds = true
        }
    }
    @IBOutlet var wordLabel: UILabel?
    
    @IBOutlet var meaningLabel: UILabel?{
        didSet {
            meaningLabel?.numberOfLines = 0
        }
    }
    @IBOutlet var accentLabel: UILabel?
    @IBOutlet var phoneticLabel: UILabel?
    @IBOutlet var rememberImageView: UIImageView?
    @IBOutlet var rememberLabel: UILabel?
    
    var speech:String?
    init(cardImage: String, word: String, meaning: String, accent:String, phone: String, speech: String){
        super.init(frame: CGRect(x: 0, y: 0, width: 296, height: 420))
        self.cardImageView?.image = UIImage(named: cardImage)
        self.wordLabel?.text = word
        self.meaningLabel?.text = meaning
        self.accentLabel?.text = accent
        self.phoneticLabel?.text = phone
        self.rememberImageView?.backgroundColor = .white
        self.rememberImageView?.alpha = 0.0
        self.rememberLabel?.text = ""
        self.rememberLabel?.alpha = 0.0
        self.speech? = speech
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
