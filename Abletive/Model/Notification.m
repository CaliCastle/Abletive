//
//  Notification.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "Notification.h"
#import "AbletiveAPIClient.h"
#import "NSString+FilterHTML.h"

@implementation Notification

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.content = attributes[@"content"];
        self.date = attributes[@"date"];
        self.fromUserID = [attributes[@"from"]intValue];
        self.avatar = [NSString filterImageTag:attributes[@"avatar"]];
        if ([attributes[@"type"] containsString:@"unread"]) {
            self.notificationType = NotificationTypeUnreadReply;
        } else if ([attributes[@"type"] containsString:@"unrepm"]){
            self.notificationType = NotificationTypeUnreadMessage;
        } else if ([attributes[@"type"] containsString:@"repm"]) {
            self.notificationType = NotificationTypeReadMessage;
        } else {
            self.notificationType = NotificationTypeReadReply;
        }
        self.user = [User userWithAttributes:attributes[@"userinfo"]];
    }
    return self;
}

+ (instancetype)notificationWithAttributes:(NSDictionary *)attributes {
    return [[Notification alloc]initWithAttributes:attributes];
}

+ (void)getNotificationsWithPage:(NSUInteger)page andCount:(NSUInteger)count andBlock:(void (^)(NSArray * _Nullable, NSError * _Nullable))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/get_notifications" parameters:@{@"user_id":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"],@"page":[NSNumber numberWithInteger:page],@"count":[NSNumber numberWithInteger:count]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *messages = JSON[@"messages"];
            NSMutableArray *notifications = [NSMutableArray array];
            
            for (NSDictionary *attribute in messages) {
                Notification *notif = [Notification notificationWithAttributes:attribute];
                notif.rawRepresentation = attribute;
                [notifications addObject:notif];
            }
            if (block) {
                block(notifications,nil);
            }
            
        } else {
            block(nil,[NSError new]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self = [self initWithAttributes:[coder decodeObjectForKey:@"raw"]];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.rawRepresentation forKey:@"raw"];
}

@end
