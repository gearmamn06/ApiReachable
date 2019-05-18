//
//  ApiReachableTests.swift
//  ApiReachableTests
//
//  Created by ParkHyunsoo on 16/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
import ObjectMapper
@testable import ApiReachable


class ApiReachableTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}



// MARK: Common struct and protocol


struct Genre: ImmutableMappable, Equatable {
    let id: Int
    let name: String
    
    init(map: Map) throws {
        id = try map.value("primaryGenreId")
        name = try map.value("primaryGenreName")
    }
    
    static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
    }
}

struct ItuenseSearchResultItem: ImmutableMappable, Equatable {
    let type: String
    let name: String
    let linkUrl: URL
    let id: Int
    let primaryGenre: Genre
    
    init(map: Map) throws {
        type = try map.value("artistType")
        name = try map.value("artistName")
        let urlString: String = try map.value("artistLinkUrl")
        guard let url = URL(string: urlString) else {
            throw ApiBaseError.mappingFail(map)
        }
        linkUrl = url
        id = try map.value("artistId")
        primaryGenre = try Genre(map: map)
    }
    
    static func == (lhs: ItuenseSearchResultItem,
                    rhs: ItuenseSearchResultItem) -> Bool {
        return lhs.id == rhs.id
            && lhs.type == rhs.type
            && lhs.name == rhs.name
            && lhs.linkUrl == rhs.linkUrl
            && lhs.primaryGenre == rhs.primaryGenre
    }
}


extension Genre {
    
    private init() {
        id = 21
        name = "Rock"
    }
    
    fileprivate static var rock: Genre {
        return Genre()
    }
}


extension ItuenseSearchResultItem {
    
    private init() {
        type = "Artist"
        name = "Jack Johnson"
        linkUrl = URL(string: "https://itunes.apple.com/us/artist/jack-johnson/909253?uo=4")!
        id = 909253
        primaryGenre = Genre.rock
    }
    
    
    fileprivate static var jackJohnson: ItuenseSearchResultItem {
        return ItuenseSearchResultItem()
    }
}



protocol ItunesSearchReachable: ApiReachable {}

extension ItunesSearchReachable {
    
    static var baseURL: URL {
        return URL(string: "https://itunes.apple.com")!
    }
    
    static var endPoint: String {
        return "lookup"
    }
    
    static var requiredParams: [String: Any] {
        return [:]
    }
    
}



// MARK: test mappable


struct MappableItuenseSearchResult: ImmutableMappable, ItunesSearchReachable {
    
    let resultCount: Int
    let results: [ItuenseSearchResultItem]
    
    init(map: Map) throws {
        resultCount = try map.value("resultCount")
        results = try map.value("results")
    }
}


extension ApiReachableTests {
    
    func testMapping() {
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "Jack_Johnson_search_result", ofType: "json")
        let fileUrl = URL(fileURLWithPath: path!)
        let jsonString = try! String(contentsOf: fileUrl)
        
        let mappingResult = try? MappableItuenseSearchResult(JSONString: jsonString)
        
        XCTAssertNotNil(mappingResult)
        XCTAssertEqual(mappingResult?.results.count, mappingResult?.resultCount)
        XCTAssertEqual(mappingResult?.resultCount, 1)
        
        let first = mappingResult?.results.first
        let jackJson = ItuenseSearchResultItem.jackJohnson
        XCTAssertNotNil(first)
        XCTAssertEqual(first, jackJson)
    }
    
    
    func testReach() {
        
        let promise = expectation(description: "reach end handle invoke")
        
        let queries: [String: Any] = ["id": 909253]
        var responseModel: MappableItuenseSearchResult?
        var responseError: Error?
        
        // when
        MappableItuenseSearchResult.reach(method: .get, queries: queries, completeHandler: { result in
            switch result {
            case .success(let model):
                responseModel = model
                
            case .fail(let error):
                responseError = error
            }
            promise.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertNotNil(responseModel)
    }

    
}


// MARK: test Decodable

extension Genre: Decodable {
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: ItuenseSearchResultItem.ItemCodingKey.self)
        
        id = try container.decode(Int.self, forKey: .genreId)
        name = try container.decode(String.self, forKey: .genreName)
    }
}


extension ItuenseSearchResultItem: Decodable {
    
    enum ItemCodingKey: String, CodingKey {
        case type = "artistType"
        case name = "artistName"
        case linkUrl = "artistLinkUrl"
        case id = "artistId"
        case genreName = "primaryGenreName"
        case genreId = "primaryGenreId"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: ItemCodingKey.self)
        
        type = try container.decode(String.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        linkUrl = try container.decode(URL.self, forKey: .linkUrl)
        id = try container.decode(Int.self, forKey: .id)
        
        primaryGenre = try Genre(from: decoder)
    }
}


struct DecodableItuenseSearResult: Decodable, ItunesSearchReachable {
    
    let resultCount: Int
    let results: [ItuenseSearchResultItem]
}

extension ApiReachableTests {
    
    func testDecodableMapping() {
        
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "Jack_Johnson_search_result", ofType: "json")
        let fileUrl = URL(fileURLWithPath: path!)
        
        let data = try! Data(contentsOf: fileUrl, options: .alwaysMapped)
        let mappingResult = try? JSONDecoder().decode(DecodableItuenseSearResult.self, from: data)
        
        XCTAssertNotNil(mappingResult)
        XCTAssertEqual(mappingResult?.results.count, mappingResult?.resultCount)
        XCTAssertEqual(mappingResult?.resultCount, 1)
        
        let first = mappingResult?.results.first
        let jackJson = ItuenseSearchResultItem.jackJohnson
        XCTAssertNotNil(first)
        XCTAssertEqual(first, jackJson)
    }
    
    
    func testDecodableReach() {
        let promise = expectation(description: "reach end handle invoke")
        
        let queries: [String: Any] = ["id": 909253]
        var responseModel: DecodableItuenseSearResult?
        var responseError: Error?
        
        // when
        DecodableItuenseSearResult.reach(method: .get, queries: queries, completeHandler: { result in
            switch result {
            case .success(let model):
                responseModel = model
                
            case .fail(let error):
                responseError = error
            }
            promise.fulfill()
        })
        
        waitForExpectations(timeout: 5, handler: nil)
        
        // then
        XCTAssertNil(responseError)
        XCTAssertNotNil(responseModel)
    }
}
