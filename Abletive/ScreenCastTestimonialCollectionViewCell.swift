//
//  ScreenCastTestimonialCollectionViewCell.swift
//  Abletive
//
//  Created by Cali Castle on 3/3/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class ScreenCastTestimonialCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var testimonial : Testimonial? {
        didSet {
            // Data binding
            avatarImageView.sd_setImage(with: URL(string: testimonial!.avatar), placeholderImage: UIImage(named: "default_avatar"))
            nameLabel.text = testimonial!.name
            captionLabel.text = testimonial!.caption
            messageLabel.text = testimonial!.message
            
            // Customize
            avatarImageView.layer.masksToBounds = true
            avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width / 2
            avatarImageView.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
            avatarImageView.layer.borderWidth = 3
            
            captionLabel.textColor = AppColor.lightTranslucent()
            
            content.layer.masksToBounds = true
            content.layer.cornerRadius = 8
            content.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
            content.layer.borderWidth = 5
        }
    }
}
