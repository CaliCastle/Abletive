//
//  FriendshipRequestTableViewCell.swift
//  Abletive
//
//  Created by Cali on 11/28/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

class FriendshipRequestTableViewCell: UITableViewCell {

    var currentUser : User!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    @IBAction func actionButtonDidClick(sender: AnyObject) {
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
