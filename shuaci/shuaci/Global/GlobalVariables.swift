//
//  GlobalVariables.swift
//  shuaci
//
//  Created by Honglei Ren on 2021/1/2.
//  Copyright © 2021 Honglei Ren. All rights reserved.
//

import Foundation

var global_records: [Record] = []
var global_vocabs_records: [VocabularyRecord] = []
var invitationMode: Bool = false
var english:Bool = false
var failedReason: FailedVerifyReason? = nil
var Word_indexs_In_Oalecd8:[String:[Int]] = [:]
var AllData_keys:[String] = []
var AllInterp_keys:[String] = []
var defaultMotto: String = "If you are going through hell, keep going. —— Winston S. Churchill"
var expireDate: Date? = nil

