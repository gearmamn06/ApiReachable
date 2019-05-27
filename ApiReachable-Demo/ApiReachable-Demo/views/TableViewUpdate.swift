//
//  TableViewUpdate.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 26/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


enum TableViewUpdate {
    case reloadAll
    case insert(at: [IndexPath])
    case delete(at: [IndexPath])
    case move(from: IndexPath, to: IndexPath)
    case none
    
    var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
}
