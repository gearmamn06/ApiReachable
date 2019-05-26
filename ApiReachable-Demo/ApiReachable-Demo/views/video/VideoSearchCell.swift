//
//  VideoSearchCell.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit


struct VideoSearchCellViewModel {
    
    let imageUrl: URL
    let title: String
    let description: String
}

class VideoSearchCell: UITableViewCell, ConfigurableCell {
    
    typealias ViewModel = VideoSearchCellViewModel
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setUpSubViews(_ viewModel: VideoSearchCellViewModel) {
        if let data = try? Data(contentsOf: viewModel.imageUrl) {
            self.thumbnailImageView.image = UIImage(data: data)
        }else{
            self.thumbnailImageView.image = nil
        }
        
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
    }
}
