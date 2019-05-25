//
//  ApiReachable.swift
//  ApiReachable
//
//  Created by ParkHyunsoo on 23/03/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RxSwift
import SystemConfiguration
import AVFoundation

public enum ApiBaseError: Error {
    case noInternetConnection
    case invalidParameter
    case mappingFail(_ json: Any)
}


public enum ApiResult<T> {
    case success(model: T)
    case fail(error: Error)
}


public protocol ApiReachable {
    static var baseURL: URL { get }
    static var endPoint: String { get }
    static var requiredParams: [String: Any] { get }
    
    static func reach(method: HTTPMethod,
                      queries: [String: Any],
                      completeHandler: @escaping (ApiResult<Self>) -> Void)
}


public extension ApiReachable {
    
    static var finalURL: URL {
        return baseURL.appendingPathComponent(endPoint)
    }
    
    
    private static var mappingQueue: DispatchQueue {
        return DispatchQueue(label: "mapping\(Int.random(in: 0..<1000000000))",
            qos: .userInitiated, attributes: [.concurrent])
    }

}


public extension ApiReachable where Self: BaseMappable {
    
    static func reach(method: HTTPMethod,
                      queries: [String: Any] = [:],
                      completeHandler: @escaping (ApiResult<Self>) -> Void) {

        if !isConnectedNet() {
            completeHandler(ApiResult.fail(error: ApiBaseError.noInternetConnection))
            return
        }

        var finalParams = requiredParams
        queries.forEach{
            finalParams[$0.key] = $0.value
        }

        Alamofire.request(finalURL, method: method, parameters: finalParams)
            .responseJSON(queue: mappingQueue,
                          options: .allowFragments, completionHandler: { response in

                switch response.result {
                case .success(let json):
                    if let sender = Mapper<Self>().map(JSONObject: json) {
                        DispatchQueue.main.async {
                            completeHandler(ApiResult.success(model: sender))
                        }
                    }else{
                        DispatchQueue.main.async {
                            completeHandler(ApiResult.fail(error: ApiBaseError.mappingFail(json)) )
                        }
                    }

                case .failure(let error):
                    DispatchQueue.main.async {
                        completeHandler(ApiResult.fail(error: error))
                    }

                }
            })
    }
}


public extension ApiReachable where Self: Decodable {
    
    static func reach(method: HTTPMethod,
                      queries: [String: Any] = [:],
                      completeHandler: @escaping ((ApiResult<Self>) -> Void)) {
        
        if !isConnectedNet() {
            completeHandler(ApiResult.fail(error: ApiBaseError.noInternetConnection))
            return
        }
        
        var finalParams = requiredParams
        queries.forEach {
            finalParams[$0.key] = $0.value
        }
        
        Alamofire.request(finalURL, method: method, parameters: finalParams)
            .responseData(completionHandler: { response in
                switch response.result {
                case .success(let value):
                    if let sender = try? JSONDecoder().decode(self, from: value) {
                        DispatchQueue.main.async {
                            completeHandler(ApiResult.success(model: sender))
                        }
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completeHandler(ApiResult.fail(error: error))
                    }
                }
            })
        
    }
}


public extension ApiReachable {
    
    static func reach(method: HTTPMethod, queries: [String: Any] = [:]) -> Single<Self> {
        return Observable.create { observer in
            self.reach(method: method, queries: queries, completeHandler: { result in
                
                switch result {
                case let .success(model):
                    observer.onNext(model)
                    observer.onCompleted()
                    
                case let .fail(error):
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }.asSingle()
    }
}


extension ApiReachable {
    
    private static func isConnectedNet() -> Bool {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return false }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else {
            return false
        }
        
        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
    
}
