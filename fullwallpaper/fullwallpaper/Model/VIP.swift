//
//  VIP.swift
//  fullwallpaper
//
//  Created by Honglei Ren on 2021/2/20.
//

import Foundation

struct VIP {
    var duration: String
    var purchase: RegisteredPurchase
    var price: Int
    var pastPrice: Int
    var numOfMonth: Int
    
    init(duration: String, purchase: RegisteredPurchase, price: Int, pastPrice:Int, numOfMonth:Int) {
        self.duration = duration
        self.purchase = purchase
        self.price = price
        self.pastPrice = pastPrice
        self.numOfMonth = numOfMonth
    }
}
