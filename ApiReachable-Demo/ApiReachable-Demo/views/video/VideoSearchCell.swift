//
//  VideoSearchCell.swift
//  ApiReachable-Demo
//
//  Created by ParkHyunsoo on 22/05/2019.
//  Copyright © 2019 ParkHyunsoo. All rights reserved.
//

import UIKit
import Kingfisher


struct VideoSearchCellViewModel {
    
    let videoID: String
    let imageUrl: URL?
    let title: String
    let description: String
    
    init(_ video: VideoSearch) {
        self.videoID = video.videoId
        self.imageUrl = video.thumbnail.properURL(with: ["high", "medium", "default"])
        self.title = video.title
        self.description = video.description
    }
}

class VideoSearchCell: UITableViewCell, ConfigurableCell {
    
    typealias ViewModel = VideoSearchCellViewModel
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    override func awakeFromNib() {
        self.selectionStyle = .none
    }
    
    func setUpSubViews(_ viewModel: VideoSearchCellViewModel) {
        
        if let url = viewModel.imageUrl {
            thumbnailImageView.kf.setImage(with: url)
            thumbnailImageView.contentMode = .scaleAspectFill
        }else{
            thumbnailImageView.image = nil
        }
        
        self.titleLabel.text = viewModel.title
        self.descriptionLabel.text = viewModel.description
    }
}
