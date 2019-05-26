//
//  ChannelCell.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import Kingfisher

struct ChannelCellViewModel {
    
    let channelID: String
    let imageURL: URL?
    let title: String
    let description: String
    
    init(_ channel: ChannelSearch) {
        self.channelID = channel.id
        self.imageURL = channel.thumbnail.properURL(with: ["default", "medium", "high"])
        self.title = channel.title
        self.description = channel.description
    }
}


class ChannelCell: UITableViewCell, ConfigurableCell {
    
    typealias ViewModel = ChannelCellViewModel
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        self.selectionStyle = .none
    }
    
    
    func setUpSubViews(_ viewModel: ChannelCellViewModel) {
        if let url = viewModel.imageURL {
            self.thumbnailImageView.kf.setImage(with: url)
        }else{
            self.thumbnailImageView.image = nil
        }
        
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
        
        self.accessoryType = .disclosureIndicator
    }
    
}
