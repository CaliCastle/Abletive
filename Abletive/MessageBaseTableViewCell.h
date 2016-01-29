//
//  MessageBaseTableViewCell.h
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"
#import "PureLayout.h"

#define kWidthHead                    (40)  //头像宽度
#define kHeightHead                   (kWidthHead) //头像高度
#define kTopHead                      (10)  //头像离父视图顶部距离
#define kLeadingHead                  (10) //对方发送的消息时，头像距离父视图的leading(头像在左边)
#define kTraingHead                   (kLeadingHead) //自己发送的消息时，头像距离父视图的traing(头像在右边)

#define kOffsetHHeadToBubble          (0) //头像和气泡水平距离

#define kOffsetTopHeadToBubble        (5)  //头像和气泡顶部对其间距

#define kReuseIDSeparate               (@"-") //可重用ID字符串区分符号

#define kImageNameChat_send_nor        (@"bubble_self_normal")
#define kImageNameChat_send_press      (@"bubble_self_pressed")


#define kImageNameChat_Recieve_nor     (@"bubble_other_normal")
#define kImageNameChat_Recieve_press   (@"bubble_other_pressed")

@protocol MessageTableViewDelegate <NSObject>

- (void)avatarDidTap:(BOOL)isMyself;
- (void)linkDidTapAtURL:(NSString *)url;

@end

@interface MessageBaseTableViewCell : UITableViewCell
{
@protected
    
    UIImageView *mAvatarImageView;
    
    UIImageView *mBubbleImageView;
    
    UIActivityIndicatorView *mActivityIndicator;
    
    UIImageView *errorView;
    
    BOOL isSender;
}

@property (nonatomic,weak) id <MessageTableViewDelegate> delegate;

@property (nonatomic,strong) ChatMessage *messageModel;

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer;

@end
