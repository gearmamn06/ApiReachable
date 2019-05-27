//
//  VideoSearchUsecase.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 26/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift


struct VideoSearchUsecase {
    
    static func load(on channelID: String,
                     pageToken: String?) -> Observable<PageResult<VideoSearch>> {
        var qry: [String: Any] = [
            "channelId": channelID
        ]
        if let token = pageToken {
            qry["pageToken"] = token
        }
        return PageResult<VideoSearch>.reach(method: .get, queries: qry)
    }
}
