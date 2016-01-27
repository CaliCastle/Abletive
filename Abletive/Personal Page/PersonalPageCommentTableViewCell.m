//
//  PersonalPageCommentTableViewCell.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PersonalPageCommentTableViewCell.h"
#import "AppColor.h"

@implementation PersonalPageCommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.postTitleLabel.textColor = [AppColor loginButtonColor];
    self.fromLabel.textColor = [AppColor mainYellow];
    self.postDateLabel.textColor = [AppColor lightTranslucent];
    self.postContentLabel.textColor = [AppColor mainWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
