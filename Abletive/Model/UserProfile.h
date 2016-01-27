//
//  UserProfile.h
//  Abletive
//
//  Created by Cali on 10/11/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserProfile : NSObject

@property (nonatomic,assign) NSUInteger userID;

@property (nonatomic,strong) NSString *displayName;

@property (nonatomic,strong) NSString *QQ;

@property (nonatomic,strong) NSString *sinaWeibo;

@property (nonatomic,strong) NSString *url;

@property (nonatomic,assign) NSUInteger credit;

@property (nonatomic,strong) NSString *email;

@property (nonatomic,strong) NSString *collectionCount;

@property (nonatomic,strong) NSString *commentsCount;

@property (nonatomic,strong) NSString *postsCount;

@property (nonatomic,strong) NSDictionary *membership;

@property (nonatomic,strong) NSString *registeredDays;

@property (nonatomic,assign) UserGenderType gender;

@property (nonatomic,strong) NSString *ordersCount;

+ (instancetype)userProfileWithAttributes:(NSDictionary *)attributes;

@end
