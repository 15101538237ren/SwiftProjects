//
//  CardUIView.swift
//  shuaci
//
//  Created by 任红雷 on 4/24/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import UIKit

class CardUIView: UIView {
    @IBOutlet var cardBackView: CardBackView?
    @IBOutlet var cardImageView: UIImageView?{
        didSet {
            cardImageView?.layer.cornerRadius = 20.0
            cardImageView?.layer.masksToBounds = true
        }
    }
    @IBOutlet var wordLabel: UILabel?{
        didSet {
            wordLabel?.numberOfLines = 0
        }
    }
    
    @IBOutlet var meaningLabel: UILabel?{
        didSet {
            meaningLabel?.numberOfLines = 0
        }
    }
    
    @IBOutlet var memMethodLabel: UILabel?{
        didSet {
            memMethodLabel?.numberOfLines = 0
        }
    }
    
    var dragable: Bool = true
    
    @IBOutlet var X_Constraint: NSLayoutConstraint!
    @IBOutlet var Y_Constraint: NSLayoutConstraint!
    @IBOutlet var wordLabel_Top_Space_Constraint: NSLayoutConstraint!
    @IBOutlet var meaningLabel_Top_Space_Constraint: NSLayoutConstraint!
    @IBOutlet var rememberImageView: UIImageView?
    @IBOutlet var rememberLabel: UILabel?
    @IBOutlet var collectImageView: UIImageView!
    
    var speech:String?
    init(cardImage: String, word: String, meaning: String, accent:String, phone: String, speech: String){
        super.init(frame: CGRect(x: 0, y: 0, width: 296, height: 420))
        self.cardImageView?.image = UIImage(named: cardImage)
        self.wordLabel?.text = word
        self.meaningLabel?.text = meaning
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
