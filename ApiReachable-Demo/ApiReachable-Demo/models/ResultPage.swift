//
//  ResultPage.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 18/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import ObjectMapper


struct PageInfo: ImmutableMappable {
    let totalResults: Int
    let resultPerPage: Int
    
    init(map: Map) throws {
        totalResults = try map.value("totalResults")
        resultPerPage = try map.value("resultsPerPage")
    }
}

struct PageResult<Item>: ImmutableMappable {
    
    
    let nextPageToken: String?
    let prevpageToken: String?
    let pageInfo: PageInfo
    let items: [Item]
    
    init(map: Map) throws {
        nextPageToken = try map.value("nextPageToken")
        prevpageToken = try map.value("prevPageToken")
        pageInfo = try map.value("pageInfo")
        items = try map.value("items")
    }
}
