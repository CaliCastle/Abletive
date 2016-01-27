//
//  PaymentOrderPriceTableViewCell.swift
//  Abletive
//
//  Created by Cali Castle on 12/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

import UIKit

class PaymentOrderPriceTableViewCell: UITableViewCell {

    var price : String!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        priceLabel.text = price == nil ? "￥0.00" : "￥\(price)"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
