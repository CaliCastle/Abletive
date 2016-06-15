//
//  ChatShareTableViewCell.swift
//  Abletive
//
//  Created by Cali Castle on 3/19/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class ChatShareTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var notification : __ObjC.Notification? {
        didSet {
            avatarView.layer.masksToBounds = true
            avatarView.layer.cornerRadius = avatarView.bounds.size.width / 2
            
            avatarView.sd_setImage(with: URL(string: (notification?.avatar)!), placeholderImage: UIImage(named: "default-avatar"))
            
            nameLabel.text = notification?.user.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
