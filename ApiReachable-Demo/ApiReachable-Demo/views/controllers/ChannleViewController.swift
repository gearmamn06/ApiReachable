//
//  ChannleViewController.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit

class ChannleViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var category: GuideCategory!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
    }
    
}


extension ChannleViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func setUpTableView() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
