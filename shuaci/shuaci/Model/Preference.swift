//
//  Preference.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/1/2.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import Foundation


struct Preference: Codable {
    var auto_pronunciation: Bool
    var us_pronunciation: Bool
    var number_of_words_per_group: Int
    var current_theme: Int
    var memory_order: Int
    var current_book_id: String?
    var current_book_name: String?
    var reminder_time: DateComponents?
    
    init(auto_pronunciation: Bool = true, us_pronunciation:Bool = true, number_of_words_per_group: Int = 20, current_theme: Int = 1, memory_order:Int = 1, current_book_id: String? = nil, current_book_name: String? = nil, reminder_time:DateComponents? = nil, display_name:String = "") {
        self.auto_pronunciation = auto_pronunciation
        self.us_pronunciation = us_pronunciation
        self.number_of_words_per_group = number_of_words_per_group
        self.current_theme = current_theme
        self.memory_order = memory_order
        self.current_book_id = current_book_id
        self.current_book_name = current_book_name
        self.reminder_time = reminder_time
    }
}
