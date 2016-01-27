//
//  PersonalPageOrderTableViewCell.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PersonalPageOrderTableViewCell.h"
#import "AppColor.h"

@implementation PersonalPageOrderTableViewCell

- (void)setUserOrder:(UserOrder *)userOrder {
    _userOrder = userOrder;
    
    self.productNameLabel.text = _userOrder.productName;
    self.statusLabel.text = _userOrder.status;
    self.statusLabel.textColor = [AppColor mainYellow];
    self.singlePriceLabel.text = _userOrder.cash?[NSString stringWithFormat:@"￥%@",_userOrder.singlePrice]:[NSString stringWithFormat:@"积分%@",_userOrder.singlePrice];
    self.quantityLabel.text = [NSString stringWithFormat:@"x%lu",(unsigned long)_userOrder.quantity];
    self.quantityLabel.textColor = [AppColor lightTranslucent];
    self.timeLabel.text = _userOrder.date;
    self.timeLabel.textColor = [AppColor lightSeparator];
    self.totalPriceLabel.text = _userOrder.cash?[NSString stringWithFormat:@"￥%@",_userOrder.totalPrice]:[NSString stringWithFormat:@"积分%@",_userOrder.totalPrice];
    self.totalPriceLabel.textColor = [AppColor loginButtonColor];
    self.cashImageView.image = _userOrder.cash?[UIImage new]:[[UIImage imageNamed:@"my-credits"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cashImageView.tintColor = [AppColor loginButtonColor];
    self.cashImageView.backgroundColor = [UIColor clearColor];
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
