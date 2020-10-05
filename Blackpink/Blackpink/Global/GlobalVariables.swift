//
//  GlobalVariables.swift
//  Blackpink
//
//  Created by Honglei on 10/4/20.
//

import Foundation
import CloudKit

var likeChangedRecordId: String = ""
var imageCache = NSCache<CKRecord.ID, NSURL>()
