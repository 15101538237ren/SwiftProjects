//
//  Book.swift
//  shuaci
//
//  Created by 任红雷 on 5/5/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit

class Book
{
    var identifier: String
    var name: String
    var level1_category: Int
    var level2_category: Int
    var description: String
    var word_num: Int
    var recite_user_num: Int
    var cover_image: UIImage
    var data: NSData
    
    init(identifier: String, level1_category: Int, level2_category:Int, name:String, description:String, word_num:Int, recite_user_num:Int, cover_image:UIImage , data: NSData){
      self.identifier = identifier
      self.level1_category = level1_category
      self.level2_category = level2_category
      self.name = name
      self.description = description
      self.word_num = word_num
      self.recite_user_num = recite_user_num
      self.cover_image = cover_image
      self.data = data
    }
}
