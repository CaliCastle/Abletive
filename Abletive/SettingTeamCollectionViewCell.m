//
//  SettingTeamCollectionViewCell.m
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import "SettingTeamCollectionViewCell.h"
#import "SOZOChromoplast.h"

@implementation SettingTeamCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIImage *image = [[UIImage imageNamed:@"background"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0)];
    
    self.backgroundImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 8;
    self.avatarImageView.layer.borderWidth = 1.5f;
}

- (void)setTeam:(Team *)team {
    _team = team;
    
    [self setupViews];
}

- (void)setupViews {
    dispatch_async(dispatch_get_main_queue(), ^{
        SOZOChromoplast *chromoplast = [[SOZOChromoplast alloc]initWithImage:[UIImage imageNamed:_team.avatarPath]];
        self.backgroundImageView.tintColor = chromoplast.dominantColor;
        
        self.avatarImageView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
        self.nameLabel.text = self.team.name;
        self.nameLabel.textColor = _team.backgroundColor ? _team.backgroundColor : chromoplast.firstHighlight;
        
        self.avatarImageView.image = [UIImage imageNamed:_team.avatarPath];
        if (_team.backgroundColor) {
            self.avatarImageView.backgroundColor = _team.backgroundColor;
        }
        
        self.positionLabel.text = [NSString stringWithFormat:@"社区职位：%@",_team.position];
        self.positionLabel.textColor = _team.backgroundColor ? _team.backgroundColor : chromoplast.firstHighlight;
        
        self.aboutMeLabel.text = _team.aboutMe;
        self.aboutMeLabel.textColor = _team.backgroundColor ? _team.backgroundColor : chromoplast.secondHighlight;
    });
}

@end
