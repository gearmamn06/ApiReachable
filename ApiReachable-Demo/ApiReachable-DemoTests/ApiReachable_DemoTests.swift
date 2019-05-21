//
//  ApiReachable_DemoTests.swift
//  ApiReachable-DemoTests
//
//  Created by ParkHyunsoo on 18/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest

@testable import ApiReachable
@testable import ApiReachable_Demo

class ApiReachable_DemoTests: XCTestCase {
    
    var categoryJsonString: String!
    var channelJsonString: String!
    var videoJsonString: String!
    
    var categoryListJsonString: String!
    var channelListJsonString: String!
    var videoListJsonString: String!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        categoryJsonString = loadJson("category")
        channelJsonString = loadJson("channel")
        videoJsonString = loadJson("video")
        
        categoryListJsonString = loadJson("categories")
        channelListJsonString = loadJson("channels")
        videoListJsonString = loadJson("videos")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        categoryJsonString = ""
        channelJsonString = ""
        videoJsonString = ""
        
        categoryListJsonString = ""
        channelListJsonString = ""
        videoListJsonString = ""
    }
}


extension ApiReachable_DemoTests {
    
    var loadJson: (String) -> String {
        return { fileName in
            let bundle = Bundle(for: type(of: self))
            let path = bundle.path(forResource: fileName, ofType: "json")!
            let url = URL(fileURLWithPath: path)
            
            return try! String(contentsOf: url)
        }
    }
    
    func testMappingModels() {
        
        let category = try? GuideCategory(JSONString: categoryJsonString)
        let channel = try? Channel(JSONString: channelJsonString)
        let video = try? VideoSearch(JSONString: videoJsonString)
        
        XCTAssertNotNil(category)
        XCTAssertNotNil(channel)
        XCTAssertNotNil(video)
    }
    
    
    func testMappingModelList() {
        
        let catergoies = try? PageResult<GuideCategory>(JSONString: categoryListJsonString)
        let channels = try? PageResult<Channel>(JSONString: channelListJsonString)
        let videos = try? PageResult<VideoSearch>(JSONString: videoListJsonString)
        
        XCTAssertNotNil(catergoies?.items)
        XCTAssertNotNil(channels?.items)
        XCTAssertNotNil(videos?.items)
        
        XCTAssertEqual(catergoies?.resultPerPage, catergoies?.items.count)
        XCTAssertEqual(channels?.resultPerPage, channels?.items.count)
        XCTAssertEqual(videos?.resultPerPage, videos?.items.count)
    }
    
    
}



extension ApiReachable_DemoTests {
    
    func testReachGuideCategory() {
        
        var responseModel: PageResult<GuideCategory>!
        var responseError: Error!
        
        let promise = expectation(description: "reach end handle invoke")
        
        PageResult<GuideCategory>.reach(method: .get) { result in
            switch result {
            case .success(let model):
                responseModel = model
                
            case .fail(let error):
                responseError = error
            }
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(responseModel)
        XCTAssertNil(responseError)
    }
    
    func testReachChannel() {
        var responseModel: PageResult<Channel>!
        var responseError: Error!
        
        let promise = expectation(description: "reach end handle invoke")
        
        let qry: [String: Any] = [
            "id": "UCBR8-60-B28hp2BmDPdntcQ"
        ]
        PageResult<Channel>.reach(method: .get, queries: qry) { result in
            switch result {
            case .success(let model):
                responseModel = model
                
            case .fail(let error):
                responseError = error
            }
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(responseModel)
        XCTAssertNil(responseError)
    }
    
    func testReachVideoSearch() {
        var responseModel: PageResult<VideoSearch>!
        var responseError: Error!
        
        let promise = expectation(description: "reach end handle invoke")
        
        let qry: [String: Any] = [
            "channelId": "UCBR8-60-B28hp2BmDPdntcQ"
        ]
        PageResult<VideoSearch>.reach(method: .get, queries: qry) { result in
            switch result {
            case .success(let model):
                responseModel = model
                
            case .fail(let error):
                responseError = error
            }
            
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(responseModel)
        XCTAssertNil(responseError)
    }
}
