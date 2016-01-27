//
//  CommunityTableViewCell.m
//  Abletive
//
//  Created by Cali on 10/31/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "CommunityTableViewCell.h"
#import "AppColor.h"

@implementation CommunityTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    self.imgView.layer.masksToBounds = YES;
    self.imgView.layer.cornerRadius = self.imgView.frame.size.width/2;
    
    self.descLabel.textColor = [AppColor lightTranslucent];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
