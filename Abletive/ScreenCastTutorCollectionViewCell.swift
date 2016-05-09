//
//  ScreenCastTutorCollectionViewCell.swift
//  Abletive
//
//  Created by Cali Castle on 3/2/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class ScreenCastTutorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var tutor : CCUser? {
        didSet {
            nameLabel.text = tutor?.display_name
            avatarView.sd_setImageWithURL(NSURL(string: (tutor?.avatar)!), placeholderImage: UIImage(named: "default-avatar"))
            
            avatarView.layer.masksToBounds = true
            avatarView.layer.cornerRadius = avatarView.bounds.size.width / 2
        }
    }
}
