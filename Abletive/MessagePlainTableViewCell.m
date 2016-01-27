//
//  MessagePlainTableViewCell.m
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "MessagePlainTableViewCell.h"
#import "PureLayout.h"

//文本
#define kH_OffsetTextWithHead        (20)//水平方向文本和头像的距离
#define kMaxOffsetText               (45)//文本最长时，为了不让文本分行显示，需要和屏幕对面保持一定距离
#define kTop_OffsetTextWithHead      (15) //文本和头像顶部对其间距
#define kBottom_OffsetTextWithSupView   (40)//文本与父视图底部间距

@interface MessagePlainTableViewCell(){
    UILabel *mTextLable;
}

@end

@implementation MessagePlainTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        mTextLable = [UILabel newAutoLayoutView];
        mTextLable.numberOfLines = 0;
        mTextLable.lineBreakMode = NSLineBreakByClipping;
        mTextLable.backgroundColor = [UIColor clearColor];
        mTextLable.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:mTextLable];
        
        if (isSender)//是我自己发送的
        {
            [mBubbleImageView autoPinEdge:ALEdgeLeading toEdge:ALEdgeLeading ofView:mTextLable withOffset:-20];
        }else//别人发送的消息
        {
            [mBubbleImageView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeTrailing ofView:mTextLable withOffset:20];
        }
        
        [mBubbleImageView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:mTextLable withOffset:20];
        
        CGFloat top     = kTop_OffsetTextWithHead + kTopHead;
        CGFloat bottom  = kBottom_OffsetTextWithSupView;
        
        CGFloat leading = kH_OffsetTextWithHead + kWidthHead + kLeadingHead;
        CGFloat trailing  = kMaxOffsetText;
        
        UIEdgeInsets inset;
        if (isSender)//是自己发送的消息
        {
            inset = UIEdgeInsetsMake(top, trailing, bottom, leading);
            [mTextLable autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeLeading];
            
            [mTextLable autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:trailing relation:NSLayoutRelationGreaterThanOrEqual];
            
        }else//是对方发送的消息
        {
            inset = UIEdgeInsetsMake(top, leading, bottom, trailing);
            
            [mTextLable autoPinEdgesToSuperviewEdgesWithInsets:inset excludingEdge:ALEdgeTrailing];
            
            [mTextLable autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:trailing relation:NSLayoutRelationGreaterThanOrEqual];
        }
        
    }
    return self;
}

- (void)setMessageModel:(ChatMessage *)messageModel {
    
    if ([messageModel.content containsString:@"http://"] || [messageModel.content containsString:@"https://"]) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:messageModel.content
                                                                                 attributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
                                                                                              NSBackgroundColorAttributeName: [UIColor clearColor],
                                                                                              NSForegroundColorAttributeName: messageModel.isSender ? [AppColor mainWhite] : [AppColor registerButtonColor]}]];
        mTextLable.attributedText = attributedString;
        mTextLable.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(linkTapped:)];
        [mTextLable addGestureRecognizer:tapper];
    } else {
        mTextLable.text = messageModel.content;
    }
    
    [super setMessageModel:messageModel];
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        
        mBubbleImageView.highlighted = YES;
        
        UIMenuItem *copy = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(menuCopy)];
        UIMenuItem *remove = [[UIMenuItem alloc]initWithTitle:@"删除" action:@selector(menuRemove)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:@[copy,remove]];
        [menu setTargetRect:mBubbleImageView.frame inView:self];
        [menu setMenuVisible:YES animated:YES];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillHide) name:UIMenuControllerWillHideMenuNotification object:nil];

    }
}

- (void)linkTapped:(UITapGestureRecognizer *)tapper {
    [self.delegate linkDidTapAtURL:self.messageModel.content];
}

- (void)menuCopy {
    [UIPasteboard generalPasteboard].string = mTextLable.text;
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
