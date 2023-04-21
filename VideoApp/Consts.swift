//
//  Consts.swift
//  VideoApp
//
//  Created by 이재훈 on 2023/04/21.
//

import Foundation

open class Consts {
    
    static var consts = Consts()
    
    private init(){}
    
    let IS_DEBUG = true
    
    let AES_KEY   = "26183260540306855921652972530618"
    
    enum PrefKey: String {
        case uuid = "OBJECT_DETECTION_UUID"
    }
}
