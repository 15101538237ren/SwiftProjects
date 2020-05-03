//
//  Util.swift
//  shuaci
//
//  Created by 任红雷 on 5/2/20.
//  Copyright © 2020 Honglei Ren. All rights reserved.
//

import Foundation
import UIKit

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func loadUserPhoto() -> UIImage?{
    let imageFileURL = getDocumentsDirectory().appendingPathComponent("user_avatar.jpg")
    do {
        let imageData = try Data(contentsOf: imageFileURL)
        return UIImage(data: imageData)
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
}
