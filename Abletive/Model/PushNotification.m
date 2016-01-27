//
//  PushNotification.m
//  Abletive
//
//  Created by Cali on 11/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PushNotification.h"

@implementation PushNotification

+ (void)sendDeviceToken:(NSString *)token {
    [[AbletiveAPIClient sharedPushClient] POST:@"apns.php" parameters:@{@"passphrase":@"AbletiveiOSAPNS",@"device_token":token,@"action":@"add"} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"deviceToken"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}

+ (void)updateUserID:(NSUInteger)userID withToken:(NSString *)token {
    [[AbletiveAPIClient sharedPushClient] POST:@"apns.php" parameters:@{@"passphrase":@"AbletiveiOSAPNS",@"device_token":token,@"user_id":[NSNumber numberWithInteger:userID],@"action":@"update"} success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}

+ (void)removeUserWithToken:(NSString *)token {
    [[AbletiveAPIClient sharedPushClient] POST:@"apns.php" parameters:@{@"passphrase":@"AbletiveiOSAPNS",@"device_token":token,@"action":@"delete"} success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%@",error);
    }];
}

@end