//
//  Channel.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 18/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import ObjectMapper

struct Channel: ImmutableMappable {
    
    let id: String
    let title: String
    let description: String
    let thumbnail: [String: Thumbnail]
    
    
    init(map: Map) throws {
        
        id = try map.value("id")
        title = try map.value("title".snippet)
        description = try map.value("description".snippet)
        thumbnail = try map.value("thumbnails".snippet)
    }
}


extension Channel: YoutubeApiReachable {
    static var endPoint: YoutubeDataEndpoints {
        return .channels
    }
    static var defaultParameters: [String : Any] {
        return [
            "part": "id, snippet",
            "maxResults": 20
        ]
    }
}
