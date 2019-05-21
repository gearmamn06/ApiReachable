//
//  YoutubeData.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 16/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation

protocol YoutubeApiReachable {
    static var defaultParameters: [String: Any] { get }
    static var endPoint: YoutubeDataEndpoints { get }
}
