//
//  AuthorTableViewCell.m
//  Abletive
//
//  Created by Cali on 7/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "AuthorTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Circle.h"
#import "AppColor.h"
#import "User.h"

@implementation AuthorTableViewCell

- (void)setAuthor:(User *)author {
    
    if (!author) {
        self.authorPostButton.enabled = NO;
        return;
    } else {
        self.authorPostButton.enabled = YES;
    }
    _author = author;
    self.authorTagButton.tintColor = [AppColor mainYellow];
    self.authorTagButton.titleLabel.text = @"作者";
    self.authorNameLabel.text = author.name;
    self.authorDescriptionLabel.text = author.aboutMe;
    self.authorDescriptionLabel.tintColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.authorAvatarView.layer.masksToBounds = YES;
    self.authorAvatarView.layer.cornerRadius = 32.5f;
    self.authorAvatarView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapped)];
    [self.authorAvatarView addGestureRecognizer:tapper];
    
    [self.authorAvatarView sd_setImageWithURL:[NSURL URLWithString:author.avatarPath] placeholderImage:[UIImage imageNamed:@"default-avatar"] options:SDWebImageContinueInBackground | SDWebImageHighPriority];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)viewAuthorPostDidClick:(id)sender {
    [self.delegate viewMorePostWithAuthorID:self.author.userID];
}

- (void)avatarTapped {
    [self.delegate avatarDidTap];
}

@end
