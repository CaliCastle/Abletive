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

// Reuse ID
#define kCellReuseID(model)      ((model.messageType == ChatMessageTypeTime)?kTimeCellReusedID:(kCellReuseIDWithSenderAndType(model.isSender,(long)model.messageType)))

/**
 *  Enumeration for message type
 */
typedef NS_OPTIONS(NSUInteger,ChatMessageType) {
    /**
     *  Plain text
     */
    ChatMessageTypePlainText = 1,
    /**
     *  Time label
     */
    ChatMessageTypeTime = 0
};

/**
 *  Enumeration for send status
 */
typedef NS_ENUM(NSUInteger, MessageSendStatus) {
    /**
     *  Success
     */
    MessageSendStatusSuccess,
    /**
     *  Sending
     */
    MessageSendStatusSending,
    /**
     *  Failed
     */
    MessageSendStatusFailed
};

/**
 *  ChatMessage model
 */
@interface ChatMessage : NSObject

#pragma mark Properties

/**
 *  Message type
 */
@property (nonatomic,assign) ChatMessageType messageType;

/**
 *  Content
 */
@property (nonatomic,strong) id content;

/**
 *  Avatar URL
 */
@property (nonatomic,strong) NSString *avatarURL;

/**
 *  Datetime
 */
@property (nonatomic,strong) NSString *date;

/**
 *  Is sender?
 */
@property (nonatomic,assign) BOOL isSender;

/**
 *  Send status
 */
@property (nonatomic,assign) MessageSendStatus status;

/**
 *  Cell height
 */
@property (nonatomic,assign) NSUInteger height;

/**
 *  User's ID
 */
@property (nonatomic,assign) NSUInteger userID;


#pragma mark Methods

/**
 *  Factory method of newing up by the content, type and sender ID
 *
 *  @param content     Content message
 *  @param messageType Message type
 *  @param isSender    Is sender?
 *  @param userID      User's ID
 *
 *  @return Chat Message instance
 */
+ (instancetype)chatMessageWithContent:(id)content andType:(ChatMessageType)messageType andIsSender:(BOOL)isSender withUserID:(NSUInteger)userID;

/**
 *  Get messages from the given user's ID
 *
 *  @param fromUserID User's ID
 *  @param block      Callback block
 */
+ (void)getChatMessagesFromUserID:(NSUInteger)fromUserID andBlock:(void (^)(NSArray *chatMessages))block;

/**
 *  Send message to the given user
 *
 *  @param text   Send text
 *  @param userID User's ID
 *  @param block  Callback block
 */
+ (void)sendChatMessageWithContent:(NSString *)text andToWhom:(NSUInteger)userID andBlock:(void (^)(BOOL success,ChatMessage *message))block;


@end
