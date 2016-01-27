//
//  User.h
//  Abletive
//
//  Created by Cali on 6/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserComment.h"

typedef NS_ENUM(NSUInteger, UserGenderType){
    UserGenderMale,
    UserGenderFemale,
    UserGenderOther
};

typedef NS_ENUM(NSUInteger, UserMembershipType){
    UserMembershipTypeNone,
    UserMembershipTypeExpired,
    UserMembershipTypeMonthly,
    UserMembershipTypeSeasonly,
    UserMembershipTypeYearly,
    UserMembershipTypeEternal
};

@interface User : NSObject

/**
 User's ID, primary key
 */
@property (nonatomic,assign) NSUInteger userID;
/**
 Username for displaying
 */
@property (nonatomic,strong) NSString * _Nonnull name;
/**
 Description of the user
 */
@property (nonatomic,strong) NSString * _Nullable aboutMe;
/**
 Email address
 */
@property (nonatomic,strong) NSString * _Nonnull mailAddress;
/**
 Path for avatar icon
 */
@property (nonatomic,strong) NSString * _Nullable avatarPath;
/**
 Gender
 */
@property (nonatomic,assign) UserGenderType gender;
/**
 Membership
 */
@property (nonatomic,assign) UserMembershipType membership;

- (_Nonnull instancetype)initWithShortAttributes:(NSDictionary * _Nonnull)attributes;

+ (_Nonnull instancetype)userWithAttributes:(NSDictionary * _Nonnull)attributes;

@end
