//
//  CommentTableViewCell.m
//  Abletive
//
//  Created by Cali on 7/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "NSString+FilterHTML.h"
#import "AppColor.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "SinglePostTableViewController.h"
#import "CCDateToString.h"

@interface CommentTableViewCell() <UITextViewDelegate>

@end

@implementation CommentTableViewCell

- (instancetype)initWithComment:(Comment *)currentComment {
    if (self = [super init]) {
        self.currentComment = currentComment;
        
        [self setupData];
        
        [self refreshColor];
    }
    return self;
}

- (void)setCurrentComment:(Comment *)currentComment {
    if (!currentComment) {
        return;
    }
    _currentComment = currentComment;
    
    [self setupData];
    
    switch (self.membershipType) {
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
        default:
            self.membershipImageView.image = [UIImage new];
            break;
    }
    [self refreshColor];
}

- (void)setupData {
    // Frame setup
    self.bounds = CGRectMake(0, 0, CGRectGetWidth(self.frame), ([_currentComment.content length] + 25) / 25 * CGRectGetHeight(self.frame));
    
    self.contentTextView.text = [NSString filterHTML:_currentComment.content];
    self.contentTextView.bounds = CGRectMake(0, 0, CGRectGetWidth(self.contentTextView.frame), ([[NSString filterHTML:_currentComment.content] length] + 25) / 25 * CGRectGetHeight(self.contentTextView.frame));
    
    self.dateLabel.text = [CCDateToString getStringFromDate:_currentComment.date];
    
    // Process row string
    NSString *rowLabelText = nil;
    switch (self.rowID) {
        case 0:
            rowLabelText = NSLocalizedString(@"沙发", nil);
            self.rowLabel.textColor = [UIColor colorWithRed:0.8f green:0.35f blue:0.35f alpha:0.95f];
            break;
        case 1:
            rowLabelText = NSLocalizedString(@"板凳", nil);
            self.rowLabel.textColor = [UIColor colorWithRed:0.2f green:0.9f blue:0.3f alpha:0.95f];
            break;
        case 2:
            rowLabelText = NSLocalizedString(@"地板", nil);
            self.rowLabel.textColor = [UIColor colorWithRed:0.5f green:0.4f blue:0.8f alpha:0.95f];
            break;
        default:
            rowLabelText = [NSString stringWithFormat:@"%lu楼",(unsigned long)self.rowID+1];
            self.rowLabel.textColor = [UIColor colorWithWhite:1 alpha:0.65];
            break;
    }
    self.rowLabel.text = rowLabelText;
    
    // User agent
    self.userAgentLabel.font = [UIFont fontAwesomeFontOfSize:11];
    self.userAgentLabel.text = [_currentComment.agent isEqualToString:@"iOS APP"] ? [NSString stringWithFormat:@"%@ %@",[NSString fontAwesomeIconStringForEnum:FAApple],@"iOS客户端"] : [NSString stringWithFormat:@"%@ %@",[NSString fontAwesomeIconStringForEnum:FAGlobe],@"网页版"] ;
    
    // Avatar circle
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.layer.cornerRadius = 20;
    
    // Enable interaction
    self.avatarView.userInteractionEnabled = YES;
    self.nameLabel.userInteractionEnabled = YES;
    
    // Add gesture recognizers
    UITapGestureRecognizer *avatarTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarDidTap)];
    UITapGestureRecognizer *nameTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nameDidTap)];
    [self.avatarView addGestureRecognizer:avatarTapGesture];
    [self.nameLabel addGestureRecognizer:nameTapGesture];
    
    // Setup avatar image
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:_currentComment.author.avatarPath] placeholderImage:[UIImage imageNamed:@"default-avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!self.avatarView.image){
            self.avatarView.image = image;
        }
    }];
}

- (void)refreshColor {
    // Default
    self.userAgentLabel.textColor = [AppColor lightTranslucent];
    self.nameLabel.textColor = [AppColor loginButtonColor];
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.4];
}

- (IBAction)replyButtonDidClick:(id)sender {
    if (!self.currentComment.author) {
        return;
    }
    [self.delegate replyDidTapAtCommentID:self.currentComment.commentID withName:self.currentComment.author.name inRowID:self.rowID];
}

- (void)avatarDidTap {
    if (!self.currentComment.author.userID) {
        return;
    }
    [self.delegate avatarDidTapAtUser:self.currentComment.author];
}

- (void)nameDidTap {
    if (!self.currentComment.author.userID) {
        return;
    }
    [self.delegate nameDidTapAtUser:self.currentComment.author];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL.absoluteString containsString:@"http://"] || [URL.absoluteString containsString:@"https://"]) {
        [self.delegate linkDidTapAtURL:[URL absoluteString]];
        return NO;
    }
    
    return YES;
}
@end
