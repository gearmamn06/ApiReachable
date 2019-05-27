//
//  File.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 18/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import ObjectMapper


struct VideoSearch: ImmutableMappable {
    
    let videoId: String
    let title: String
    let description: String
    let thumbnail: [String: Thumbnail]
    
    init(map: Map) throws {
        videoId = try map.value("id.videoId")
        title = try map.value("title".snippet)
        description = try map.value("description".snippet)
        thumbnail = try map.value("thumbnails".snippet)
    }
}


extension VideoSearch: YoutubeApiReachable {
    
    static var endPoint: YoutubeDataEndpoints = .search
    static var defaultParameters: [String : Any] = [
        "part": "id, snippet",
        "type": "video",
        "order": "date",
        "maxResults": 20
    ]
}

