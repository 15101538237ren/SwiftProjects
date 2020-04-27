//
//  Word.swift
//  shuaci
//
//  Created by 任红雷 on 4/26/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation

class Word
{
    var wordHead: String
    var trans: [[String:String]]
    var usphone: String
    var ukphone: String
    var usspeech: String
    var ukspeech: String
    var remMethod: String
    var relWords: [[String: String]]
    var phrases: [[String: String]]
    var synoWords: [[String: [String]]]
    var sentences: [[String: String]]
    
    init(wordHead: String, trans: [[String:String]] = [[:]], usphone: String, ukphone: String, usspeech: String = "", ukspeech: String = "", remMethod: String = "", relWords:  [[String:String]] = [[:]], phrases:  [[String:String]] = [[:]], synoWords: [[String: [String]]] = [[:]], sentences: [[String:String]] = [[:]]) {
        self.wordHead = wordHead
        self.trans = trans
        self.usphone = usphone
        self.ukphone = ukphone
        self.usspeech = usspeech
        self.remMethod = remMethod
        self.ukspeech = ukspeech
        self.relWords = relWords
        self.phrases = phrases
        self.synoWords = synoWords
        self.sentences = sentences
    }
    
    convenience init() {
        self.init(wordHead:"", trans:[[:]], usphone:"", ukphone:"", usspeech:"", ukspeech:"", remMethod:"", relWords:[[:]], phrases:[[:]], synoWords:[[:]], sentences:[[:]])
    }
    
}
