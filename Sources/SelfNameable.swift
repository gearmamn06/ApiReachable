//
//  SelfNameable.swift
//  ApiReachable
//
//  Created by ParkHyunsoo on 23/03/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation

public protocol SelfNameable { }

public extension SelfNameable {
    
    static var name: String {
        return String(describing: self)
    }
    
    var name: String {
        return String(describing: type(of: self))
    }
}
