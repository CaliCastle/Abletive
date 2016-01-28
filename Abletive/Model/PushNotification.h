//
//  PushNotification.h
//  Abletive
//
//  Created by Cali on 11/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Push Notification model
 */
@interface PushNotification : NSObject

#pragma mark Properties

/**
 *  Device token (Unique)
 */
@property (nonatomic,strong) NSString *deviceToken;


#pragma mark Methods

/**
 *  Send device token to the server
 *
 *  @param token Token
 */
+ (void)sendDeviceToken:(NSString *)token;

/**
 *  Update user's token
 *
 *  @param userID User's ID
 *  @param token  Token
 */
+ (void)updateUserID:(NSUInteger)userID withToken:(NSString *)token;

/**
 *  Delete user's token
 *
 *  @param token Token
 */
+ (void)removeUserWithToken:(NSString *)token;

@end
