//
//  ChannelCell.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


struct ChannelCellViewModel {
    
    let imageUrl: URL
    let title: String
    let description: String
    
}


class ChannelCell: UITableViewCell, ConfigurableCell {
    
    typealias ViewModel = ChannelCellViewModel
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    func setUpSubViews(_ viewModel: ChannelCellViewModel) {
        if  let data = try? Data(contentsOf: viewModel.imageUrl) {
            self.thumbnailImageView.image = UIImage(data: data)
        }else{
            self.thumbnailImageView.image = nil
        }
        
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
    }
    
}
