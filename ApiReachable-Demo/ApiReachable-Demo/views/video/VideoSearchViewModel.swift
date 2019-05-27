//
//  VideoSearchViewModel.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 26/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class VideoSearchViewModel {
    
    // init
    private let channelID: String!
    private let bag = DisposeBag()
    private var nextPageToken: String?
    
    init(_ channelID: String) {
        self.channelID = channelID
        
        // TODO: bind or subscribe
        subscribeRefresh()
        subscribeInfiniteLoading()
        bindItemTap()
    }
    
    // dataSource
    var cellViewModels = [VideoSearchCellViewModel]()
    
    // input
    var refresh = PublishRelay<Void>()
    var loadMore = PublishRelay<Void>()
    var itemDidTap = PublishRelay<IndexPath>()
    
    // private properies
    private let _update = PublishSubject<TableViewUpdate>()
    private let _errorMessage = PublishSubject<String>()
    private let _isLoading = BehaviorSubject<Bool>(value: false)
    private let _selectedVideoURL = PublishSubject<String>()
    
    // output
    var update: Signal<TableViewUpdate> {
        return _update.asSignal(onErrorJustReturn: .none)
            .filter{ !$0.isNone }
    }
    
    var errorMessage: Signal<String> {
        return _errorMessage.asSignal(onErrorJustReturn: "")
            .filter{ !$0.isEmpty }
    }
    
    var shouldShowActivityIndicator: Driver<Bool> {
        return _isLoading.asDriver(onErrorJustReturn: false)
    }
    
    var openVideWebPage: Signal<String> {
        return _selectedVideoURL.asSignal(onErrorJustReturn: "")
            .filter{ !$0.isEmpty }
    }
}


extension VideoSearchViewModel {
    
    private func subscribeRefresh() {
        
        let channelID: String = self.channelID
        
        let refreshTrigger = refresh.throttle(0.5, scheduler: MainScheduler.instance)
        
        Observable.zip(_isLoading, refreshTrigger)
            .compactMap { (flag: Bool, void: Void) -> (String, String?)? in
                if !flag {
                    return (channelID, nil)
                }
                return nil
            }
            .do(onNext: { [weak self] _ in
                self?._isLoading.onNext(true)
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest(VideoSearchUsecase.load)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.nextPageToken = result.nextPageToken
                self?.cellViewModels = result.items.map(VideoSearchCellViewModel.init)

                self?._isLoading.onNext(false)
                self?._update.onNext(.reloadAll)
            }, onError: { [weak self] error in
                self?._isLoading.onNext(false)
                self?._errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    private func subscribeInfiniteLoading() {
        let channelID: String = self.channelID
        let trigger = loadMore.skip(0.5, scheduler: MainScheduler.instance)
            .throttle(0.5, scheduler: MainScheduler.instance)
        
        Observable.zip(_isLoading, trigger)
            .compactMap { [weak self] flag, void -> (String, String?)? in
                if let self = self, !flag {
                    return (channelID, self.nextPageToken)
                }
                return nil
            }
            .do(onNext: { [weak self] _ in
                self?._isLoading.onNext(true)
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest(VideoSearchUsecase.load)
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.nextPageToken = result.nextPageToken
                
                let lastIndex = self.cellViewModels.count
                self.cellViewModels += result.items.map(VideoSearchCellViewModel.init)
                
                guard lastIndex >= 0 && self.cellViewModels.count-1 > lastIndex else { return }
                let newIndexPaths = (lastIndex..<self.cellViewModels.count)
                    .map{ IndexPath(row: $0, section: 0) }
                self._update.onNext(.insert(at: newIndexPaths))
                
                self._isLoading.onNext(false)
                
            }, onError: { [weak self] error in
                self?._isLoading.onNext(false)
                self?._errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    
    private func bindItemTap() {
        itemDidTap
        .compactMap { [weak self] (index: IndexPath) -> String? in
            guard let self = self else { return nil }
            let videoID = self.cellViewModels[index.row].videoID
            return "https://www.youtube.com/watch?v=\(videoID)"
        }.bind(to: _selectedVideoURL)
        .disposed(by: bag)
    }
}
