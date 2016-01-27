//
//  CommunityCreditTableViewCell.swift
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class CommunityCreditTableViewCell: UITableViewCell {

    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var creditRank : CreditRank? {
        didSet {
            nameLabel.text = creditRank?.name
            creditLabel.text = "积分：\((creditRank?.credit)! as String)"
            creditLabel.textColor = AppColor.mainYellow()
            avatarImageView.sd_setImageWithURL(NSURL(string: (creditRank?.avatarURL)!), placeholderImage: UIImage(named: "watch-avatar"))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.size.width/2
        avatarImageView.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
