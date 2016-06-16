//
//  CCTodayCollectionViewCell.swift
//  Abletive
//
//  Created by Cali Castle on 6/15/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

import UIKit

class CCTodayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var currentPost : Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
