//
//  SelfNamable.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 21/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation


protocol SelfNamable {}

extension SelfNamable {
    
    static var name: String {
        return String(describing: self)
    }
    
    var name: String {
        return String(describing: type(of: self))
    }
    
}
