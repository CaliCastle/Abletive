//
//  InboxTableViewCell.swift
//  Abletive
//
//  Created by Cali Castle on 3/18/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var inbox : Inbox? {
        didSet {
            contentLabel.text = inbox!.content
            statusLabel.text = inbox!.status == "read" ? "已读" : "未读"
            dateLabel.text = inbox!.date
            
            statusLabel.textColor = inbox!.status == "read" ? AppColor.lightTranslucent() : AppColor.loginButtonColor()
            dateLabel.textColor = AppColor.lightSeparator()
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
