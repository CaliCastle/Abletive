//
//  MessageTimeTableViewCell.h
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTimeCellReusedID    (@"MessageTime")

@class ChatMessage;

@interface MessageTimeTableViewCell : UITableViewCell

@property (nonatomic,strong) ChatMessage *messageModel;

@property (nonatomic,weak) id delegate;

@end
