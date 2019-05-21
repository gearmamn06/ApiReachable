//
//  CategoryListViewController.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct CategoryViewModel {
    
    let reload = PublishSubject<Void>()
    var cellViewModels: [CategoryCellViewModel] = [] {
        didSet {
            reload.onNext(())
        }
    }
    
    private let currentErrorMessage = PublishSubject<String>()
    let errorAlertShowing = BehaviorSubject<Bool>(value: false)
    func refresh() {
        PageResult<GuideCategory>.reach(method: .get) { result in
            switch result {
            case .success(let page):
                self.cellViewModels = page.items
                
            case .fail(let error):
                self.currentErrorMessage.onNext(error.localizedDescription)
            }
        }
    }
    
    
    var errorMessage: Observable<String> {
        return Observable.combineLatest(errorAlertShowing, currentErrorMessage) { showing, errMess in
            if showing {
                return ""
            }
            return errMess
        }
    }
}


class CategoryListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel = CategoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpSubViews()
    }
}

extension CategoryListViewController {
    
    private func setUpSubViews() {
        self.setUpNavigationBar()
        self.setUpTableView()
    }
    
    private func setUpNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                                 target: self,
                                                                 action: #selector(refreshButtonDidTap))
    }
    
    @objc private func refreshButtonDidTap() {
        viewModel.refresh()
    }
}


extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func setUpTableView() {
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        self.tableView.dataSource = self
        self.tableView.delegate = self
     
        let _ = viewModel.reload
            .observeOn(MainScheduler.instance)
            .takeUntil(self.rx.deallocated)
            .subscribe { [weak self] event in
                self?.tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.name) as! CategoryCell
        cell.setUpSubViews(viewModel.cellViewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        
        // TODO: to channel view controller
    }
}
