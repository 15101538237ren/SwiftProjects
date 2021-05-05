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
    var objectId: String
    var identifier: String
    var name: String
    var level1_category: Int
    var level2_category: Int
    var contributor: String
    var word_num: Int
    var recite_user_num: Int
    var file_sz: Float
    var nchpt: Int
    var avg_nwchpt: Int
    var nwchpt: String
    
    init(objectId:String, identifier: String, level1_category: Int, level2_category:Int, name:String, contributor:String, word_num:Int, recite_user_num:Int, file_sz: Float, nchpt: Int, avg_nwchpt: Int, nwchpt: String){
      
      self.objectId = objectId
      self.identifier = identifier
      self.level1_category = level1_category
      self.level2_category = level2_category
      self.name = name
      self.contributor = contributor
      self.word_num = word_num
      self.recite_user_num = recite_user_num
      self.file_sz =  file_sz
      self.nchpt =  nchpt
      self.avg_nwchpt =  avg_nwchpt
      self.nwchpt =  nwchpt
    }
}
