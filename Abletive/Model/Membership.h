//
//  Membership.h
//  Abletive
//
//  Created by Cali Castle on 12/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Membership : NSObject

@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *status;

+ (instancetype)membershipWithAttributes:(NSDictionary *)attributes;

+ (void)getCurrentMembership:(void (^)(Membership *membership))block;

+ (void)payMembershipWithType:(NSUInteger)type andBlock:(void (^)(Membership *))block;

@end
