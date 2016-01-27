//
//  NotificationTableViewCell.h
//  Abletive
//
//  Created by Cali on 10/15/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic,strong) Notification *notifcation;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
