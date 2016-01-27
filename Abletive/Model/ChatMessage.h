//
//  ChatMessage.h
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbletiveAPIClient.h"

#define kCellReuseIDWithSenderAndType(isSender,chatCellType)    ([NSString stringWithFormat:@"%d-%ld",isSender,chatCellType])

//根据模型得到可重用Cell的 重用ID
#define kCellReuseID(model)      ((model.messageType == ChatMessageTypeTime)?kTimeCellReusedID:(kCellReuseIDWithSenderAndType(model.isSender,(long)model.messageType)))

typedef NS_OPTIONS(NSUInteger,ChatMessageType) {
    ChatMessageTypePlainText = 1,
    ChatMessageTypeTime = 0
};

typedef NS_ENUM(NSUInteger, MessageSendStatus) {
    MessageSendStatusSuccess,
    MessageSendStatusSending,
    MessageSendStatusFailed
};

@interface ChatMessage : NSObject

@property (nonatomic,assign) ChatMessageType messageType;

@property (nonatomic,strong) id content;

@property (nonatomic,strong) NSString *avatarURL;

@property (nonatomic,strong) NSDate *date;

@property (nonatomic,assign) BOOL isSender;

@property (nonatomic,assign) MessageSendStatus status;

@property (nonatomic,assign) NSUInteger height;

@property (nonatomic,assign) NSUInteger userID;

+ (instancetype)chatMessageWithContent:(id)content andType:(ChatMessageType)messageType andIsSender:(BOOL)isSender withUserID:(NSUInteger)userID;

+ (void)getChatMessagesFromUserID:(NSUInteger)fromUserID andBlock:(void (^)(NSArray *chatMessages))block;

+ (void)sendChatMessageWithContent:(NSString *)text andToWhom:(NSUInteger)userID andBlock:(void (^)(BOOL success,ChatMessage *message))block;


@end
