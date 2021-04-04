//
//  VIP.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/2/20.
//

import Foundation


struct VIP {
    var purchase: RegisteredPurchase
    
    init(purchase: RegisteredPurchase) {
        self.purchase = purchase
    }
}
