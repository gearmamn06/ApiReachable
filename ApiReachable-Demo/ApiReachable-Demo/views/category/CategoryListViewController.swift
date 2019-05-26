//
//  CategoryListViewController.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


class CategoryListViewController: UIViewController {
    
    private var categoris = [GuideCategory]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavigationBar()
        setUpTableView()
        
        refresh()
    }
}

extension CategoryListViewController {

    
    private func setUpNavigationBar() {
        self.title = "Category"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                                                 target: self,
                                                                 action: #selector(refreshButtonDidTap))
    }
    
    @objc private func refreshButtonDidTap() {
        refresh()
    }
    
    
    private func refresh() {

        self.navigationItem.rightBarButtonItem?.isEnabled = false
        PageResult<GuideCategory>.reach(method: .get, completeHandler: { result in
            switch result {
            case .success(let page):
                self.categoris = page.items
                self.tableView.reloadData()
                
            case .fail(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
            
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        })
    }
}


extension CategoryListViewController: UITableViewDataSource, UITableViewDelegate  {
    
    
    private func setUpTableView() {
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoris.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell
        cell.nameLabel.text = categoris[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categoris[indexPath.row]
        let dest = ChannelViewController.instance
        dest.category = category
        
        self.navigationController?.pushViewController(dest, animated: true)
    }
    
}
