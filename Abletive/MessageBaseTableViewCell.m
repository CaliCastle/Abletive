//
//  MessageBaseTableViewCell.m
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "MessageBaseTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation MessageBaseTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        mAvatarImageView = [UIImageView newAutoLayoutView];
        mAvatarImageView.backgroundColor = [UIColor clearColor];
        mAvatarImageView.userInteractionEnabled = YES;
        
        if (!isSender) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarTapped:)];
            [mAvatarImageView addGestureRecognizer:tap];
        }
        
        mAvatarImageView.image = [UIImage imageNamed:@"default-avatar"];
        [self.contentView addSubview:mAvatarImageView];
        
        [mAvatarImageView autoSetDimensionsToSize:CGSizeMake(kWidthHead, kHeightHead)];
        mAvatarImageView.layer.masksToBounds = YES;
        mAvatarImageView.layer.cornerRadius = kWidthHead/2;
        
        [mAvatarImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kTopHead];
        NSArray *IDs = [reuseIdentifier componentsSeparatedByString:kReuseIDSeparate];
        
        NSAssert(IDs.count>=2, @"reuseIdentifier should be separated by -");
        
        isSender = [IDs[0] boolValue];
        
        if (isSender) {
            [mAvatarImageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:kTraingHead];
        } else {
            [mAvatarImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:kLeadingHead];
        }
        
        mBubbleImageView = [UIImageView newAutoLayoutView];
        mBubbleImageView.backgroundColor = [UIColor clearColor];
        mBubbleImageView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *bubblelongPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
        [mBubbleImageView addGestureRecognizer:bubblelongPress];
        [self.contentView addSubview:mBubbleImageView];
        
        [mBubbleImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:mAvatarImageView withOffset:-kOffsetTopHeadToBubble];
        
        
        if (isSender) {
            mBubbleImageView.image = [[UIImage imageNamed:kImageNameChat_send_nor] stretchableImageWithLeftCapWidth:30 topCapHeight:30];
            
            mBubbleImageView.highlightedImage = [[UIImage imageNamed:kImageNameChat_send_press] stretchableImageWithLeftCapWidth:30 topCapHeight:30];
            
            [mBubbleImageView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:mAvatarImageView withOffset:-kOffsetHHeadToBubble];
        } else {
            mBubbleImageView.image = [[UIImage imageNamed:kImageNameChat_Recieve_nor]stretchableImageWithLeftCapWidth:30 topCapHeight:30];
            mBubbleImageView.highlightedImage = [[UIImage imageNamed:kImageNameChat_Recieve_press] stretchableImageWithLeftCapWidth:30 topCapHeight:30];
            
            [mBubbleImageView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:mAvatarImageView withOffset:kOffsetHHeadToBubble];
        }

    }
    
    return self;
}

- (void)setMessageModel:(ChatMessage *)messageModel {
    _messageModel = messageModel;
    if (messageModel.isSender) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_avatar_path"]) {
            [mAvatarImageView sd_setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults]stringForKey:@"user_avatar_path"]] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
        } else {
            mAvatarImageView.image = [UIImage imageNamed:@"default-avatar"];
        }
    } else {
        if (messageModel.avatarURL) {
            [mAvatarImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.avatarURL] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
        } else {
            mAvatarImageView.image = [UIImage imageNamed:@"default-avatar"];
        }
    }
    
    switch (messageModel.status) {
        case MessageSendStatusSending:
        {
            if (errorView) {
                [errorView removeFromSuperview];
                errorView = nil;
            }
            if (mActivityIndicator) {
                [mActivityIndicator stopAnimating];
                [mActivityIndicator removeFromSuperview];
                mActivityIndicator = nil;
            }
            mActivityIndicator = [UIActivityIndicatorView newAutoLayoutView];
            mActivityIndicator.backgroundColor = [AppColor transparent];
            mActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            
            [self.contentView addSubview:mActivityIndicator];
            
            [mActivityIndicator autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:mBubbleImageView withOffset:-15];
            if (isSender) {
                [mActivityIndicator autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:mBubbleImageView withOffset:0];
            } else {
                [mActivityIndicator autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:mBubbleImageView withOffset:0];
            }
            [mActivityIndicator startAnimating];
            break;
        }
        case MessageSendStatusFailed:
        {
            if (mActivityIndicator) {
                [mActivityIndicator stopAnimating];
                [mActivityIndicator removeFromSuperview];
                mActivityIndicator = nil;
            }
            errorView = [UIImageView newAutoLayoutView];
            [errorView autoSetDimensionsToSize:CGSizeMake(25, 25)];
            
            [self.contentView addSubview:errorView];
            
            [errorView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:mBubbleImageView withOffset:-15];
            
            errorView.backgroundColor = [AppColor transparent];
            errorView.image = [UIImage imageNamed:@"send_error"];
            errorView.userInteractionEnabled = YES;
            
            if (isSender) {
                [errorView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:mBubbleImageView withOffset:0];
            } else {
                [errorView autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:mBubbleImageView withOffset:0];
            }
            
            UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(errorDidTap)];
            [errorView addGestureRecognizer:tapper];
            
            break;
        }
        default:
        {
            if (errorView) {
                [errorView removeFromSuperview];
                errorView = nil;
            }
            if (mActivityIndicator) {
                [mActivityIndicator stopAnimating];
                [mActivityIndicator removeFromSuperview];
                mActivityIndicator = nil;
            }
            break;
        }
    }
}

- (void)avatarTapped:(UITapGestureRecognizer *)tapper {
    [self.delegate avatarDidTap];
}

- (void)errorDidTap {
    self.messageModel = _messageModel;
    [ChatMessage sendChatMessageWithContent:self.messageModel.content andToWhom:self.messageModel.userID andBlock:^(BOOL success, ChatMessage *message) {
        self.messageModel = message;
    }];
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer {
    
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

@end
