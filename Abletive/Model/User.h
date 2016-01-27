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

+ (NSURLSessionDataTask * _Nonnull)getUserAvatarPathWithID:(NSUInteger)identification andBlock:(void (^ _Nullable)(NSString * _Nullable, NSError * _Nullable))block;

+ (void)getUserinfoWithID:(NSUInteger)userID andBlock:(void (^ _Nullable)(User * _Nullable, NSError * _Nullable))block;

+ (NSURLSessionDataTask * _Nonnull)getPersonalPageDetailWithUserID:(NSUInteger)userID andCurrentUserID:(NSUInteger)currentUserID andBlock:(void (^ _Nullable)(NSDictionary * _Nullable details, NSError * _Nullable error))block;

+ (NSURLSessionDataTask * _Nonnull)followUserToWhom:(NSUInteger)followUserID withCurrentUserID:(NSUInteger)currentUserID toFollow:(BOOL)isFollow andBlock:(void (^ _Nullable)(BOOL success, NSDictionary * _Nullable JSON, NSError * _Nullable error))block;

+ (NSURLSessionDataTask * _Nonnull)getFollowListByUserID:(NSUInteger)userID andType:(NSString * _Nonnull)type withPage:(NSUInteger)page forCountPerPage:(NSUInteger)count andBlock:(void (^ _Nullable)(NSDictionary * _Nullable JSON, NSError * _Nullable error))block;

+ (NSURLSessionDataTask * _Nonnull)dailyCheckIn:(NSUInteger)userID andBlock:(void (^ _Nullable)(NSDictionary * _Nullable JSON, NSError * _Nullable error))block;

+ (NSURLSessionDataTask * _Nonnull)getCommentListByUserID:(NSUInteger)userID andPage:(NSUInteger)page withCount:(NSUInteger)count andBlock:(void (^ _Nullable)(NSArray * _Nullable, NSError * _Nullable))block;

+ (NSURLSessionDataTask * _Nonnull)collectPostByPostID:(NSUInteger)postID forRemove:(BOOL)remove andBlock:(void (^ _Nullable)(BOOL success, BOOL collected))block;

+ (NSURLSessionDataTask * _Nonnull)likePostByPostID:(NSUInteger)postID andBlock:(void (^ _Nullable)(BOOL success, BOOL liked, NSUInteger credit))block;

+ (NSURLSessionDataTask * _Nonnull)getCurrentUserProfileInBlock:(void (^ _Nullable)(NSDictionary * _Nullable profile, NSError * _Nullable error))block;

/**
 *  Update current user's profile
 *
 *  @param attributes [NSDictionary] update attributes
 *  @param block      Called once the operation is done
 *
 *  @return Session Data Task
 */
+ (NSURLSessionDataTask * _Nonnull)updateCurrentUserProfileWithAttributes:(NSDictionary * _Nonnull)attributes andBlock:(void (^ _Nullable)(BOOL,NSString * _Nullable))block;

/**
 *  Update current user's password
 *
 *  @param password1 The first time input password string to be updated
 *  @param password2 The second time input password string to validate
 *  @param block    Called once the operation is done
 *
 *  @return Session Data Task
 */
+ (NSURLSessionDataTask * _Nonnull)updateCurrentUserPassword:(NSString * _Nonnull)password1 andPassword2:(NSString * _Nonnull)password2 andBlock:(void (^ _Nullable)(BOOL success, NSString * _Nonnull message))block;

+ (void)updateCurrentUserAvatar:(NSData * _Nonnull)data andBlock:(void (^ _Nonnull)(BOOL success,NSString * _Nonnull message,  NSString * _Nullable avatarURL))block;

+ (void)getCurrentUserMembership:(void (^ _Nonnull)(BOOL hasExpired))block;

+ (void)getFriendshipRequestInBlock:(void (^ _Nullable)(NSArray * _Nullable users, NSError * _Nullable error))block;

@end
