//
//  PersonalPageFollowTableViewCell.m
//  Abletive
//
//  Created by Cali on 10/12/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PersonalPageFollowTableViewCell.h"
#import "AppColor.h"
#import "UIImageView+WebCache.h"

@implementation PersonalPageFollowTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 25.f;
    self.avatarImageView.layer.borderWidth = 1.2f;
    self.avatarImageView.layer.allowsEdgeAntialiasing = YES;
}

- (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;

    self.avatarImageView.layer.borderColor = self.isLightTheme ? [AppColor lightSeparator].CGColor : [AppColor darkSeparator].CGColor;
    self.nameLabel.textColor = self.firstHighlight;

    self.nameLabel.text = currentUser.name;
    self.descriptionLabel.textColor = self.fadedTextColor;
    self.descriptionLabel.text = currentUser.aboutMe;
    
    switch (self.membership) {
        case UserMembershipTypeMonthly:
            self.membershipImageView.image = [[UIImage imageNamed:@"monthly-membership"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.membershipImageView.tintColor = [AppColor mainWhite];
            break;
        case UserMembershipTypeSeasonly:
            self.membershipImageView.image = [[UIImage imageNamed:@"seasonly-membership"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.membershipImageView.tintColor = [AppColor registerButtonColor];
            break;
        case UserMembershipTypeYearly:
            self.membershipImageView.image = [[UIImage imageNamed:@"yearly-membership"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.membershipImageView.tintColor = [AppColor loginButtonColor];
            break;
        case UserMembershipTypeEternal:
            self.membershipImageView.image = [[UIImage imageNamed:@"eternal-membership"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.membershipImageView.tintColor = [AppColor mainYellow];
            break;
        case UserMembershipTypeExpired:
        case UserMembershipTypeNone:
        default:
            self.membershipImageView.image = [UIImage new];
            break;
    }
    
    if (currentUser.gender == UserGenderFemale) {
        self.genderImageView.image = [[UIImage imageNamed:@"female"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else if (currentUser.gender == UserGenderMale){
        self.genderImageView.image = [[UIImage imageNamed:@"male"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        self.genderImageView.image = [UIImage new];
    }
    self.genderImageView.tintColor = self.firstHighlight;
    self.backgroundColor = [AppColor transparent];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_currentUser.avatarPath] placeholderImage:[UIImage imageNamed:@"default-avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!self.avatarImageView.image) {
            self.avatarImageView.image = image;
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
