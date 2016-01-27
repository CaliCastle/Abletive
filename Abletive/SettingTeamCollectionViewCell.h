//
//  SettingTeamCollectionViewCell.h
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface SettingTeamCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) Team *team;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *positionLabel;

@property (weak, nonatomic) IBOutlet UILabel *aboutMeLabel;

@end
