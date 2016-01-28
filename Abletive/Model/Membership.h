//
//  Membership.h
//  Abletive
//
//  Created by Cali Castle on 12/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Membership model
 */
@interface Membership : NSObject

#pragma mark Properties

/**
 *  Start date time
 */
@property (nonatomic, strong) NSString *startTime;

/**
 *  End date time
 */
@property (nonatomic, strong) NSString *endTime;

/**
 *  Membership type
 */
@property (nonatomic, strong) NSString *type;

/**
 *  Membership status
 */
@property (nonatomic, strong) NSString *status;

#pragma mark Methods


/**
 *  Factory method of newing by the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return Membership instance
 */
+ (instancetype)membershipWithAttributes:(NSDictionary *)attributes;

/**
 *  Get current user's membership
 *
 *  @param block Callback block
 */
+ (void)getCurrentMembership:(void (^)(Membership *membership))block;

/**
 *  Successfully paid with type
 *
 *  @param type  Membership type
 *  @param block Callback block
 */
+ (void)payMembershipWithType:(NSUInteger)type andBlock:(void (^)(Membership *))block;

@end
