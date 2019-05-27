//
//  Category.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 18/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import ObjectMapper

struct GuideCategory: ImmutableMappable {
    
    let id: String
    let channelId: String
    let title: String
    
    init(map: Map) throws {
        id = try map.value("id")
        channelId = try map.value("channelId".snippet)
        title = try map.value("title".snippet)
    }
}


extension GuideCategory: YoutubeApiReachable {
    
    static var endPoint: YoutubeDataEndpoints = .category
    
    static var defaultParameters: [String : Any] {
        return [
            "part": "id, snippet",
            "regionCode": "US"
        ]
    }
}
