//
//  UserProfile.h
//  Abletive
//
//  Created by Cali on 10/11/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

/**
 *  User's profile
 */
@interface UserProfile : NSObject

#pragma mark Properties

/**
 *  User's identifier
 */
@property (nonatomic,assign) NSUInteger userID;

/**
 *  User's display name
 */
@property (nonatomic,strong) NSString *displayName;

/**
 *  User's QQ number
 */
@property (nonatomic,strong) NSString *QQ;

/**
 *  User's Weibo name
 */
@property (nonatomic,strong) NSString *sinaWeibo;

/**
 *  User's web url
 */
@property (nonatomic,strong) NSString *url;

/**
 *  User's credits
 */
@property (nonatomic,assign) NSUInteger credit;

/**
 *  User's email address
 */
@property (nonatomic,strong) NSString *email;

/**
 *  User's collections count
 */
@property (nonatomic,strong) NSString *collectionCount;

/**
 *  User's comments count
 */
@property (nonatomic,strong) NSString *commentsCount;

/**
 *  User's posts count
 */
@property (nonatomic,strong) NSString *postsCount;

/**
 *  User's membership model
 */
@property (nonatomic,strong) NSDictionary *membership;

/**
 *  Days since registered
 */
@property (nonatomic,strong) NSString *registeredDays;

/**
 *  User's gender
 */
@property (nonatomic,assign) UserGenderType gender;

/**
 *  User's orders count
 */
@property (nonatomic,strong) NSString *ordersCount;

#pragma mark Methods

/**
 *  Factory method of newing up by the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return UserProfile instance
 */
+ (instancetype)userProfileWithAttributes:(NSDictionary *)attributes;

@end
