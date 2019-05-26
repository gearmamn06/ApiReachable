//
//  ListViewItemCell.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


extension UITableViewCell: SelfNamable {}

protocol ConfigurableCell {
    associatedtype ViewModel
    func setUpSubViews(_ viewModel: ViewModel)
}
