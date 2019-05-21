//
//  CategoryCell.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


struct CategoryCellViewModel {
    let title: String
}


class CategoryCell: UITableViewCell, ConfigurableCell {
    
    typealias ViewModel = CategoryCellViewModel
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    func setUpSubViews(_ viewModel: CategoryCellViewModel) {
        nameLabel.text = viewModel.title
    }
    
}
