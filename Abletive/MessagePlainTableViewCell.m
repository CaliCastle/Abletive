//
//  MessagePlainTableViewCell.m
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "MessagePlainTableViewCell.h"
#import "PureLayout.h"
#import "AppColor.h"

//文本
#define kH_OffsetTextWithHead        (20)//水平方向文本和头像的距离
#define kMaxOffsetText               (45)//文本最长时，为了不让文本分行显示，需要和屏幕对面保持一定距离
#define kTop_OffsetTextWithHead      (15) //文本和头像顶部对其间距
#define kBottom_OffsetTextWithSupView   (40)//文本与父视图底部间距

@interface MessagePlainTableViewCell() <UITextViewDelegate> {
    UITextView *mTextView;
}

@end

@implementation MessagePlainTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        mTextView = [UITextView newAutoLayoutView];
        mTextView.backgroundColor = [UIColor clearColor];
        mTextView.font = [UIFont systemFontOfSize:15];
        mTextView.editable = NO;
        mTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        mTextView.scrollEnabled = NO;
        mTextView.delegate = self;
        
        UITapGestureRecognizer *doubleTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped)];
        doubleTapper.numberOfTapsRequired = 2;
        [mTextView addGestureRecognizer:doubleTapper];
        
        [self.contentView addSubview:mTextView];
        
        if (isSender) {
            [mBubbleImageView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:mTextView withOffset:-16];
        } else {
            [mBubbleImageView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:mTextView withOffset:16];
        }
        
        [mBubbleImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:mTextView withOffset:10];
        
        CGFloat top     = kTop_OffsetTextWithHead + kTopHead - 8;
        CGFloat bottom  = kBottom_OffsetTextWithSupView - 28;
        
        CGFloat leading = kH_OffsetTextWithHead + kWidthHead + kLeadingHead;
        CGFloat trailing  = kMaxOffsetText;
        
        UIEdgeInsets inset;
        if (isSender) {
            inset = UIEdgeInsetsMake(top, trailing, bottom, leading);
            [mTextView autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeLeading];
            [mTextView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:trailing relation:NSLayoutRelationGreaterThanOrEqual];
        }else {
            inset = UIEdgeInsetsMake(top, leading, bottom, trailing);
            
            [mTextView autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeTrailing];
            
            [mTextView autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:trailing relation:NSLayoutRelationGreaterThanOrEqual];
        }
    }
    return self;
}

- (void)setMessageModel:(ChatMessage *)messageModel {
    if (messageModel.isSender) {
        mTextView.textColor = [AppColor mainWhite];
        mTextView.linkTextAttributes = @{NSForegroundColorAttributeName:[AppColor secondaryWhite],NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    } else {
        mTextView.linkTextAttributes = @{NSForegroundColorAttributeName:[AppColor registerButtonColor],NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)};
    }
    mTextView.text = messageModel.content;
    [super setMessageModel:messageModel];
}

- (void)doubleTapped {
    [self becomeFirstResponder];
    
    mBubbleImageView.highlighted = YES;
    
    UIMenuItem *copy = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(menuCopy)];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:@[copy]];
    [menu setTargetRect:mBubbleImageView.frame inView:self];
    [menu setMenuVisible:YES animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillHide) name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        
        mBubbleImageView.highlighted = YES;
        
        UIMenuItem *copy = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(menuCopy)];
//        UIMenuItem *remove = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(menuRemove)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:@[copy]];
        [menu setTargetRect:mBubbleImageView.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillHide) name:UIMenuControllerWillHideMenuNotification object:nil];

    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL.absoluteString containsString:@"http://"] || [URL.absoluteString containsString:@"https://"]) {
        [self.delegate linkDidTapAtURL:[URL absoluteString]];
        return NO;
    }
    
    return YES;
}

- (void)menuCopy {
    [UIPasteboard generalPasteboard].string = mTextView.text;
}

- (void)menuRemove {
    
}

- (void)menuWillHide {
    mBubbleImageView.highlighted = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(menuCopy) || action == @selector(menuRemove));
}

@end
