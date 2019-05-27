//
//  VideoSearchModelTest.swift
//  ApiReachable-DemoTests
//
//  Created by ParkHyunsoo on 26/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import XCTest
import RxSwift
@testable import ApiReachable_Demo

class VideoSearchViewModelTest: XCTestCase {
    
    private var viewModel: VideoSearchViewModel!
    var disposeBag = DisposeBag()
    
    override func setUp() {
        viewModel = VideoSearchViewModel("UCBR8-60-B28hp2BmDPdntcQ")
    }
    
    override func tearDown() {
        viewModel = nil
        disposeBag = DisposeBag()
    }
    
    func testRefrech() {
        var testUpdate: TableViewUpdate!
        
        let promise = expectation(description: "subscription..")
        viewModel.update
            .emit(onNext: { update in
                testUpdate = update
                promise.fulfill()
            }, onCompleted: {
                promise.fulfill()
            })
            .disposed(by: disposeBag)
        
        viewModel.refresh.accept(())
//        viewModel.iso
        
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertNotNil(testUpdate)
    }
}
