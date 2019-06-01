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


public protocol ApiReachable {
    static var baseURL: URL { get }
    static var endPoint: String { get }
    static var requiredParams: [String: Any] { get }
    static var header: [String: String]? { get }
    static var encoding: ParameterEncoding { get }
    
    static func reach(method: HTTPMethod,
                      queries: [String: Any],
                      _ completeHandler: @escaping (Result<Self>) -> Void)
}


public extension ApiReachable {
    
    static var header: [String: String]? {
        return nil
    }
    
    static var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    static var finalURL: URL {
        return baseURL.appendingPathComponent(endPoint)
    }
}


public extension ApiReachable where Self: BaseMappable {
    
    static func reach(method: HTTPMethod,
                      queries: [String: Any] = [:],
                      _ completeHandler: @escaping (Result<Self>) -> Void) {

        if !isConnectedNet() {
            completeHandler(.failure(ApiBaseError.noInternetConnection))
            return
        }

        var finalParams = requiredParams
        queries.forEach{
            finalParams[$0.key] = $0.value
        }

        Alamofire.request(finalURL, method: method, parameters: finalParams,
                          encoding: encoding, headers: header)
            .responseJSON { response in
                
                switch response.result {
                case .success(let json):
                    if let sender = Mapper<Self>().map(JSONObject: json) {
                        completeHandler(.success(sender))
                        
                    }else{
                        completeHandler(.failure(ApiBaseError.mappingFail(json)))
                    }
                    
                case .failure(let error):
                    completeHandler(.failure(error))
                }
        }
    }
}


public extension ApiReachable where Self: Decodable {
    
    static func reach(method: HTTPMethod,
                      queries: [String: Any] = [:],
                      _ completeHandler: @escaping ((Result<Self>) -> Void)) {
        
        if !isConnectedNet() {
            completeHandler(.failure(ApiBaseError.noInternetConnection))
            return
        }
        
        var finalParams = requiredParams
        queries.forEach {
            finalParams[$0.key] = $0.value
        }
        
        Alamofire.request(finalURL, method: method, parameters: finalParams,
                          encoding: encoding, headers: header)
            .responseData { response in
                
                switch response.result {
                case .success(let value):
                    if let sender = try? JSONDecoder().decode(self, from: value) {
                        completeHandler(.success(sender))
                    }else{
                        completeHandler(.failure(ApiBaseError.mappingFail(value)))
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completeHandler(.failure(error))
                    }
                }
        }
    }
}


public extension ApiReachable {
    
    static func reach(method: HTTPMethod, queries: [String: Any] = [:]) -> Observable<Self> {
        return Observable.create { observer in
            self.reach(method: method, queries: queries) { result in
                
                switch result {
                case let .success(model):
                    observer.onNext(model)
                    observer.onCompleted()
                    
                case let .failure(error):
                    observer.onError(error)
                    
                }
            }
            return Disposables.create()
        }
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
