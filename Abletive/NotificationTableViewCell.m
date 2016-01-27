//
//  NotificationTableViewCell.m
//  Abletive
//
//  Created by Cali on 10/15/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "AppColor.h"
#import "CCDateToString.h"

@implementation NotificationTableViewCell

- (void)setNotifcation:(Notification *)notifcation {
    _notifcation = notifcation;
//    if (_notifcation.notificationType == NotificationTypeUnreadMessage || _notifcation.notificationType == NotificationTypeUnreadReply) {
//        self.readLabel.textColor = [AppColor loginButtonColor];
//    } else {
//        self.readLabel.textColor = [AppColor lightSeparator];
//    }
    if (_notifcation.notificationType == NotificationTypeUnreadMessage || _notifcation.notificationType == NotificationTypeReadMessage) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_notifcation.avatar] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapped)];
        [self.avatarImageView addGestureRecognizer:tapper];
        self.avatarImageView.userInteractionEnabled = YES;
    } else {
        int random = (arc4random() % 5) + 1;
        int gender = (arc4random() % 2) + 1;
        if (gender == 1) {
            self.avatarImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"male-official%d",random]];
        } else {
            self.avatarImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"female-official%d",random]];
        }
        
    }
    self.contentLabel.textColor = [AppColor lightTranslucent];
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.layer.borderWidth = 1.5f;
    self.avatarImageView.layer.borderColor = [AppColor lightSeparator].CGColor;
    
    self.contentLabel.text = _notifcation.content;
    self.nameLabel.text = _notifcation.user.name;
    self.nameLabel.textColor = [AppColor mainWhite];
    
    self.dateLabel.text = [CCDateToString getStringFromDate:_notifcation.date];
    self.dateLabel.textColor = [AppColor lightSeparator];
}

- (void)avatarTapped {
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
