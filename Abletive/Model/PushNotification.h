//
//  PushNotification.h
//  Abletive
//
//  Created by Cali on 11/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotification : NSObject

@property (nonatomic,strong) NSString *deviceToken;

+ (void)sendDeviceToken:(NSString *)token;

+ (void)updateUserID:(NSUInteger)userID withToken:(NSString *)token;

+ (void)removeUserWithToken:(NSString *)token;

@end
