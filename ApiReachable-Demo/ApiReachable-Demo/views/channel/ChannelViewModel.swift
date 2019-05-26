//
//  ChannelViewModel.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 26/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


enum TableViewUpdate {
    case reloadAll
    case inser(at: [IndexPath])
    case delete(at: [IndexPath])
    case move(from: IndexPath, to: IndexPath)
    case none
    
    var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
}


class ChannelViewModel {
    
    // init
    private let category: GuideCategory!
    private let bag = DisposeBag()
    private var nextPageToken: String?
    
    init(_ category: GuideCategory!) {
        self.category = category
        
        subscribeRefresh()
        subscribeInfiniteLoading()
        bindItemTap()
    }
    
    // dataSource
    var cellViewModels = [ChannelCellViewModel]()
    
    // input
    var refresh = PublishRelay<Void>()
    var loadMore = PublishRelay<Void>()
    var itemDidTap = PublishRelay<IndexPath>()
    
    // private properties
    private let _update = PublishSubject<TableViewUpdate>()
    private let _errorMessage = PublishSubject<String>()
    private let _isFetching = BehaviorSubject<Bool>(value: false)
    private let _nextChannelID = PublishSubject<String>()
    
    
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
        return _isFetching.map{ $0 }
            .asDriver(onErrorJustReturn: false)
    }
    var nextChannelID: Signal<String> {
        return _nextChannelID.asSignal(onErrorJustReturn: "")
            .filter{ !$0.isEmpty }
    }
}

extension ChannelViewModel {
    
    private func subscribeRefresh() {
        
        let channelType = self.category.title
        let refreshTrigger = refresh
            .throttle(0.5, scheduler: MainScheduler.instance)
        Observable.zip(_isFetching, refreshTrigger)
            .compactMap { (flag: Bool, void: Void) -> String? in
                if !flag {
                    return channelType
                }
                return nil
            }
            .do(onNext: { [weak self] _ in
                self?._isFetching.onNext(true)
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { (type: String) -> Observable<PageResult<ChannelSearch>> in
                return PageResult<ChannelSearch>.reach(method: .get,
                                                       queries: ["q": type])
            }
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                self?.nextPageToken = result.nextPageToken
                self?.cellViewModels = result.items.map(ChannelCellViewModel.init)
                
                self?._isFetching.onNext(false)
                self?._update.onNext(.reloadAll)
                }, onError: { [weak self] error in
                    self?._isFetching.onNext(false)
                    self?._errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    private func subscribeInfiniteLoading() {
        let channelType = self.category.title
        let loadMoreTrigger = loadMore.skip(0.5, scheduler: MainScheduler.instance)
            .throttle(0.5, scheduler: MainScheduler.instance)
        
        Observable.zip(_isFetching, loadMoreTrigger)
            .compactMap { [weak self] flag, void -> (String, String?)? in
                if self != nil && !flag {
                    return (channelType, self!.nextPageToken)
                }
                return nil
            }
            .do(onNext: { [weak self] _ in
                self?._isFetching.onNext(true)
                print("load more..")
            })
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { (type: String, token: String?) -> Observable<PageResult<ChannelSearch>> in
                var qry: [String: Any] = [
                    "q": type
                ]
                if let next = token {
                    qry["pageToken"] = next
                }
                return PageResult<ChannelSearch>.reach(method: .get, queries: qry)
            }
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                self.nextPageToken = result.nextPageToken
                
                let lastIndex = self.cellViewModels.count
                self.cellViewModels += result.items.map(ChannelCellViewModel.init)
                
                guard lastIndex >= 0 && self.cellViewModels.count-1 > lastIndex else { return }
                let newIndexPaths = (lastIndex..<self.cellViewModels.count)
                    .map{ IndexPath(row: $0, section: 0) }
                self._update.onNext(.inser(at: newIndexPaths))
                
                self._isFetching.onNext(false)
                
                }, onError: { [weak self] error in
                    self?._isFetching.onNext(false)
                    self?._errorMessage.onNext(error.localizedDescription)
            })
            .disposed(by: bag)
    }
    
    
    private func bindItemTap() {
        itemDidTap
            .compactMap { [weak self] (index: IndexPath) -> String? in
                guard let self = self else { return nil }
                return self.cellViewModels[index.row].title
            }.bind(to: _nextChannelID)
            .disposed(by: bag)
    }
}
