//
//  ChannleViewController.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ChannelViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = UIColor.blue
        return indicator
    }()
    
    var category: GuideCategory!
    private var viewModel: ChannelViewModel!
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ChannelViewModel(category)

        setUpNavigationBar()
        setUpTableView()
        
        bindFetching()
        bindNextViewControllerMovement()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.viewModel.refresh.accept(())
        })
    }
    
}


// MARK: bind fetcing(refresh + infinite scrolling)


extension ChannelViewController {
    
    private func bindFetching() {
        
        setUpActivityIndicator()
        
        viewModel.shouldShowActivityIndicator.drive(onNext: { [weak self] show in
            if show {
                self?.activityIndicator.startAnimating()
            }else{
                self?.activityIndicator.stopAnimating()
            }
            let clearBlockUI = !show
            self?.view.isUserInteractionEnabled = clearBlockUI
            self?.tableView.isScrollEnabled = clearBlockUI
            self?.navigationItem.rightBarButtonItem?.isEnabled = clearBlockUI
            
        }).disposed(by: bag)
        
        
        viewModel.update.emit(onNext: { [weak self] update in
            switch update {
            case .reloadAll:
                self?.tableView.reloadData()
                self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                            at: .top, animated: true)
                
            case .inser(let indexPaths):
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


// MARK: bind next viewController

extension ChannelViewController {
    
    private func bindNextViewControllerMovement() {
        viewModel.nextChannelID
            .emit(onNext: { [weak self] channelID in
                let dest = VideoSearchViewController.instance
                dest.channelID = channelID
                
                self?.navigationController?.pushViewController(dest, animated: true)
            })
            .disposed(by: bag)
    }
}



// MARK: setUp navigtionBar

extension ChannelViewController {
    
    private func setUpNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonDidTap))
        self.navigationItem.leftBarButtonItem?.title = ""
        self.title = category?.title ?? "Unknown"
        
    }
    
    @objc private func refreshButtonDidTap() {
        viewModel.refresh.accept(())
    }
}


// MARK: setUp tableView and bind interactions


extension ChannelViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelCell.name) as! ChannelCell
        let channel = viewModel.cellViewModels[indexPath.row]
        cell.setUpSubViews(channel)
        return cell
    }
    
    
}

