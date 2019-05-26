//
//  Channel.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 18/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import ObjectMapper

struct ChannelSearch: ImmutableMappable {
    
    let id: String
    let title: String
    let description: String
    let thumbnail: [String: Thumbnail]
    
    
    init(map: Map) throws {
        
        id = try map.value("id.channelId")
        title = try map.value("title".snippet)
        description = try map.value("description".snippet)
        thumbnail = try map.value("thumbnails".snippet)
    }
}


extension ChannelSearch: YoutubeApiReachable {
    static var endPoint: YoutubeDataEndpoints {
        return .search
    }
    static var defaultParameters: [String : Any] {
        return [
            "part": "id, snippet",
            "type": "channel",
            "order": "rating",
            "maxResults": 30
        ]
    }
}
