//
//  Notification.h
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef NS_ENUM(NSUInteger,NotificationType) {
    NotificationTypeUnreadMessage,
    NotificationTypeReadMessage,
    NotificationTypeUnreadReply,
    NotificationTypeReadReply
};

@interface Notification : NSObject

@property (nonatomic,strong) NSString * _Nonnull content;

@property (nonatomic,strong) NSString * _Nonnull date;

@property (nonatomic,strong) NSString * _Nullable avatar;

@property (nonatomic,assign) NSUInteger fromUserID;

@property (nonatomic,assign) NotificationType notificationType;

@property (nonatomic,strong) User * _Nonnull user;

+ (void)getNotificationsWithPage:(NSUInteger)page andCount:(NSUInteger)count andBlock:(void (^ _Nonnull)(NSArray * _Nullable notifs, NSError * _Nullable error))block;

@end
