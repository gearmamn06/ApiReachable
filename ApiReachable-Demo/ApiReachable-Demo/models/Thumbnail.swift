//
//  Thumbnail.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 18/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import ObjectMapper
import ApiReachable

struct Thumbnail: ImmutableMappable {
    
    let url: URL
    let width: Int
    let height: Int
    
    init(map: Map) throws {
        let urlString: String = try map.value("url")
        guard let url = URL(string: urlString) else {
            throw ApiBaseError.mappingFail(map)
        }
        
        self.url = url
        self.width = try map.value("width")
        self.height = try map.value("height")
    }
}
