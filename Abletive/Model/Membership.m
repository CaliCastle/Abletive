//
//  Membership.m
//  Abletive
//
//  Created by Cali Castle on 12/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "Membership.h"

@implementation Membership

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.startTime = attributes[@"startTime"];
        self.endTime = attributes[@"endTime"];
        self.type = attributes[@"user_type"];
        self.status = attributes[@"user_status"];
    }
    return self;
}

+ (instancetype)membershipWithAttributes:(NSDictionary *)attributes {
    return [[Membership alloc]initWithAttributes:attributes];
}

+ (void)getCurrentMembership:(void (^)(Membership *membership))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/membership" parameters:@{@"user_id":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            Membership *membership = [Membership membershipWithAttributes:JSON[@"member"]];
            block(membership);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(nil);
    }];
}

+ (void)payMembershipWithType:(NSUInteger)type andBlock:(void (^)(Membership *))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/payment_succeeded" parameters:@{@"user_id":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"],@"passphrase":@"AbletiveiOSPassphrase",@"vip_type":[NSNumber numberWithUnsignedInteger:type]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSDictionary *membershipAttr = JSON[@"membership"];
            Membership *newMembership = [Membership membershipWithAttributes:membershipAttr];
            block(newMembership);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(nil);
    }];
}

@end
