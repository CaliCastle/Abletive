//
//  ScreenCastSeriesCollectionViewCell.swift
//  Abletive
//
//  Created by Cali Castle on 3/1/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class ScreenCastSeriesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var series : Series? {
        didSet {
            thumbnailView.sd_setImage(with: URL(string: series!.thumbnail), placeholderImage: UIImage(named: "series_placeholder"))
            titleLabel.text = "\(series!.title)"
            episodeLabel.text = "\(series!.episodes)集"
            difficultyLabel.text = "\(series!.difficulty)"
            
            if series!.recentlyPublished {
                statusLabel.text = "全新"
            } else if series!.recentlyUpdated {
                statusLabel.text = "更新"
            } else {
                statusLabel.isHidden = true
            }
            
            // Setup color
            episodeLabel.textColor = AppColor.lightSeparator()
            statusLabel.backgroundColor = AppColor.darkOverlay()
            statusLabel.textColor = AppColor.loginButtonColor()
            statusLabel.layer.masksToBounds = true
            statusLabel.layer.cornerRadius = 5
            difficultyLabel.backgroundColor = AppColor.darkOverlay()
            difficultyLabel.layer.masksToBounds = true
            difficultyLabel.layer.cornerRadius = 5
            
            self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.09)
            self.clipsToBounds = true
            self.layer.masksToBounds = true
            self.layer.cornerRadius = 8
        }
    }
}
