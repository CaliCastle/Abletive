//
//  Notification.h
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

/**
 *  Enumeration for notification type
 */
typedef NS_ENUM(NSUInteger,NotificationType) {
    /**
     *  Unread message
     */
    NotificationTypeUnreadMessage,
    /**
     *  Read message
     */
    NotificationTypeReadMessage,
    /**
     *  Unread reply
     */
    NotificationTypeUnreadReply,
    /**
     *  Read reply
     */
    NotificationTypeReadReply
};

/**
 *  Notification model
 */
@interface Notification : NSObject

#pragma mark Properties

/**
 *  Content (HTML)
 */
@property (nonatomic,strong) NSString * _Nonnull content;

/**
 *  Datetime
 */
@property (nonatomic,strong) NSString * _Nonnull date;

/**
 *  Avatar url
 */
@property (nonatomic,strong) NSString * _Nullable avatar;

/**
 *  From whom (user's identifier)
 */
@property (nonatomic,assign) NSUInteger fromUserID;

/**
 *  Notification type
 */
@property (nonatomic,assign) NotificationType notificationType;

/**
 *  User instance
 */
@property (nonatomic,strong) User * _Nonnull user;

/**
 * Raw representation
 */
@property (nonatomic,strong) NSDictionary * _Nonnull rawRepresentation;

#pragma mark Methods

/**
 *  Get notifications
 *
 *  @param page  Page number
 *  @param count Count per page
 *  @param block Callback block
 */
+ (void)getNotificationsWithPage:(NSUInteger)page andCount:(NSUInteger)count andBlock:(void (^ _Nonnull)(NSArray * _Nullable notifs, NSError * _Nullable error))block;

- (_Nonnull instancetype)initWithCoder:(NSCoder * _Nonnull)coder;
- (void)encodeWithCoder:(NSCoder * _Nonnull)coder;

@end
