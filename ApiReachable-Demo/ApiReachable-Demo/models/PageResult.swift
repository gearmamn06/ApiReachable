//
//  ResultPage.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 18/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import ObjectMapper
import ApiReachable


struct PageResult<Item: ImmutableMappable>: ImmutableMappable {

    
    let kind: String
    let nextPageToken: String?
    let prevpageToken: String?
    let totalResultCount: Int
    let resultPerPage: Int
    
    let items: [Item]
    
    init(map: Map) throws {
        
        kind = try map.value("kind")
        nextPageToken = try? map.value("nextPageToken")
        prevpageToken = try? map.value("prevPageToken")
        
        items = try map.value("items")
        
        if let totalCount: Int = try? map.value("pageInfo.totalResults") {
            totalResultCount = totalCount
        }else{
            totalResultCount = items.count
        }
        
        if let resultPerPage: Int = try? map.value("pageInfo.resultsPerPage") {
            self.resultPerPage = resultPerPage
        }else{
            self.resultPerPage = items.count
        }
    }
}


extension PageResult: ApiReachable where Item: YoutubeApiReachable {
    
    static var baseURL: URL {
        return URL(string: "https://www.googleapis.com/youtube/v3")!
    }
    
    static var endPoint: String {
        return Item.endPoint.rawValue
    }
    
    static var requiredParams: [String : Any] {
        return Item.defaultParameters + [
            "key": "AIzaSyANg2fb98zKQbdaQH9a56XVXPAAMEGiwS0"
        ]
    }
}


fileprivate func + (lhs: Dictionary<String, Any>,
                    rhs: Dictionary<String, Any>) -> Dictionary<String, Any> {
    var sender = lhs
    rhs.forEach {
        sender[$0.key] = $0.value
    }
    return sender
}

