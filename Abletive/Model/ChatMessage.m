//
//  ChatMessage.m
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ChatMessage.h"

@implementation ChatMessage

- (instancetype)initWithContent:(id)content andType:(ChatMessageType)messageType andIsSender:(BOOL)isSender withUserID:(NSUInteger)userID {
    if (self = [super init]) {
        self.content = content;
        self.messageType = messageType;
        self.isSender = isSender;
        self.userID = userID;
    }
    return self;
}

+ (instancetype)chatMessageWithContent:(id)content andType:(ChatMessageType)messageType andIsSender:(BOOL)isSender withUserID:(NSUInteger)userID {
    return [[ChatMessage alloc]initWithContent:content andType:messageType andIsSender:isSender withUserID:userID];
}

+ (void)getChatMessagesFromUserID:(NSUInteger)fromUserID andBlock:(void (^)(NSArray *chatMessages))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/chat_messages" parameters:@{@"passphrase":AbletivePassphrase,@"user_id":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"],@"fromUserID":[NSNumber numberWithUnsignedInteger:fromUserID]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *rawMessages = JSON[@"messages"];
            NSMutableArray *messages = [NSMutableArray arrayWithCapacity:rawMessages.count];
            for (NSDictionary *rawMessage in rawMessages) {
                ChatMessage *message = [ChatMessage chatMessageWithContent:rawMessage[@"content"] andType:ChatMessageTypePlainText andIsSender:[rawMessage[@"is_sender"] boolValue] withUserID:fromUserID];
                message.date = rawMessage[@"date"];
                [messages addObject:message];
            }
            
            if (block) {
                block([NSArray arrayWithArray:messages]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(nil);
    }];
}

+ (void)sendChatMessageWithContent:(NSString *)text andToWhom:(NSUInteger)userID andBlock:(void (^)(BOOL,ChatMessage *))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/send_private_message" parameters:@{@"passphrase":AbletivePassphrase,@"content":text,@"user_id":[NSNumber numberWithInteger:userID],@"from_id":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if ([JSON[@"sent"] intValue] == 1) {
                ChatMessage *message = [ChatMessage chatMessageWithContent:text andType:ChatMessageTypePlainText andIsSender:YES withUserID:userID];
                message.status = MessageSendStatusSuccess;
                block(YES,message);
            } else {
                ChatMessage *message = [ChatMessage chatMessageWithContent:text andType:ChatMessageTypePlainText andIsSender:YES withUserID:userID];
                message.status = MessageSendStatusFailed;
                block(NO,message);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ChatMessage *message = [ChatMessage chatMessageWithContent:text andType:ChatMessageTypePlainText andIsSender:YES withUserID:userID];
        message.status = MessageSendStatusFailed;

        block(NO,message);
    }];
}


@end
