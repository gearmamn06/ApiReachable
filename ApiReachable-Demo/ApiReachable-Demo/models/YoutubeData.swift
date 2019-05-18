//
//  YoutubeData.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 16/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import ApiReachable


protocol YoutubeData: ApiReachable {}

extension YoutubeData {
    
    static var requiredParams: [String: Any] {
        return [
            "key": "AIzaSyANg2fb98zKQbdaQH9a56XVXPAAMEGiwS0"
        ]
    }
}
