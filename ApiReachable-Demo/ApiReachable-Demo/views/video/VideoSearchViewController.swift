//
//  ViedeoSearchViewController.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class VideoSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.blue
        return indicator
    }()
    
    var channelID: String!
    var channelTitle: String!
    
    private var viewModel: VideoSearchViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let channelID = self.channelID else { return }

        viewModel = VideoSearchViewModel(channelID)
        
        setUpNavigationBar()
        setUpTableView()
        
        subscribeFetching()
        subscribeOpenVideoPage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.viewModel.refresh.accept(())
        })
    }
}


// MARK: bind fetcing(refresh + infinite scrolling)

extension VideoSearchViewController {
    
    private func subscribeFetching() {
        setUpActivityIndicator()
        
        viewModel.shouldShowActivityIndicator.drive(onNext: { [weak self] show in
            if show {
                self?.activityIndicator.startAnimating()
            }else{
                self?.activityIndicator.stopAnimating()
            }
            let clearUIBlock = !show
            self?.view.isUserInteractionEnabled = clearUIBlock
            self?.tableView.isScrollEnabled = clearUIBlock
            self?.navigationItem.rightBarButtonItem?.isEnabled = clearUIBlock
        })
        .disposed(by: bag)
        
        viewModel.update.emit(onNext: { [weak self] update in
            switch update {
            case .reloadAll:
                self?.tableView.reloadData()
                self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                            at: .top, animated: true)
                
            case .insert(let indexPaths):
                self?.tableView.insertRows(at: indexPaths, with: .automatic)
                
            default: break
            }
        }).disposed(by: bag)
    }
    
    private func setUpActivityIndicator() {
        self.view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 48),
            activityIndicator.heightAnchor.constraint(equalToConstant: 48)
            ])
    }
}

// MARK: bind next View Controller

extension VideoSearchViewController {
    
    private func subscribeOpenVideoPage() {
        viewModel.openVideWebPage
            .emit(onNext: { videoURL in
                if let url = URL(string: videoURL) {
                    UIApplication.shared.openURL(url)
                }
            })
            .disposed(by: bag)
    }
}

// MARK: setUp navigationBar

extension VideoSearchViewController {
    
    private func setUpNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                                 target: self,
                                                                 action: #selector(refreshButtonDidTap))
        self.title = channelTitle ?? "Unknown"
    }
    
    @objc private func refreshButtonDidTap() {
        viewModel.refresh.accept(())
    }
}


// MARK: setUp tableView

extension VideoSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func setUpTableView() {
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        
        bindTableViewSelection()
        bindTableViewScrolling()
    }
    
    private func bindTableViewSelection() {
        let _ = tableView.rx.itemSelected
            .takeUntil(self.rx.deallocated)
            .bind(to: viewModel.itemDidTap)
    }
    
    private func bindTableViewScrolling() {
        
        let trigger: Signal<Void> = tableView.rx.didEndDecelerating.asDriver()
            .flatMapLatest { [weak self] _ in
                var isNearBottom = false
                if let frame = self?.tableView.frame,
                    let size = self?.tableView.contentSize,
                    let offset = self?.tableView.contentOffset {
                    isNearBottom = offset.y + frame.size.height >= size.height
                }
                return isNearBottom ? Signal.just(()) : Signal.empty()
        }
        trigger.emit(to: viewModel.loadMore).disposed(by: bag)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VideoSearchCell.name) as! VideoSearchCell
        let video = viewModel.cellViewModels[indexPath.row]
        cell.setUpSubViews(video)
        return cell
    }
}
