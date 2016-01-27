//
//  PersonalPageFollowTableViewCell.h
//  Abletive
//
//  Created by Cali on 10/12/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface PersonalPageFollowTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *membershipImageView;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;

@property (nonatomic,strong) User *currentUser;

@property (nonatomic,assign) BOOL isLightTheme;
@property (nonatomic,assign) UserMembershipType membership;
@property (nonatomic,strong) UIColor *firstHighlight;
@property (nonatomic,strong) UIColor *fadedTextColor;

@end
