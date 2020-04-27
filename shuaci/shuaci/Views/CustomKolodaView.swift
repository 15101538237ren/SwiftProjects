//
//  CustomKolodaView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda

class CustomKolodaView: KolodaView {
    override func frameForCard(at index: Int) -> CGRect {
        let scaleRatio = 105.0 / 74.0
        let firstCardWidth: CGFloat = (self.frame.width > 250.0) ? 296.0: 111.0
        let firstCardHeight: CGFloat = (self.frame.height > 400.0) ? 420.0: 157.0
        
        if index == 0 {
            let topOffset: CGFloat = 20
            let xOffset: CGFloat = 10
            let width = firstCardWidth
            let height = firstCardHeight
            let yOffset: CGFloat = topOffset
            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            
            return frame
        } else if index == 1 {
            let horizontalMargin = -firstCardWidth * 0.25
            let width = firstCardWidth
            let height = width * CGFloat(scaleRatio)
            return CGRect(x: horizontalMargin, y: 0, width: width, height: height)
        }
        return CGRect.zero
    }

}
