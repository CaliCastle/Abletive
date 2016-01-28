//
//  User.h
//  Abletive
//
//  Created by Cali on 6/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserComment.h"

/**
 *  Enumeration for user's gender
 */
typedef NS_ENUM(NSUInteger, UserGenderType) {
    /**
     *  Male
     */
    UserGenderMale,
    /**
     *  Female
     */
    UserGenderFemale,
    /**
     *  Other/Unknown
     */
    UserGenderOther
};

/**
 *  Type Enumeration for user's membership
 */
typedef NS_ENUM(NSUInteger, UserMembershipType) {
    /**
     *  Never paid for membership
     */
    UserMembershipTypeNone,
    /**
     *  Paid but expired
     */
    UserMembershipTypeExpired,
    /**
     *  Currently active, monthly
     */
    UserMembershipTypeMonthly,
    /**
     *  Currently active, seasonly
     */
    UserMembershipTypeSeasonly,
    /**
     *  Currently active, yearly
     */
    UserMembershipTypeYearly,
    /**
     *  Currently active, eternal
     */
    UserMembershipTypeEternal
};

/**
 *  User model
 */
@interface User : NSObject

#pragma mark Properties

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


#pragma mark Methods

/**
 *  Initializer with dictionary attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return User instance
 */
- (_Nonnull instancetype)initWithShortAttributes:(NSDictionary * _Nonnull)attributes;

/**
 *  Factory method with dictionary attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return User instance
 */
+ (_Nonnull instancetype)userWithAttributes:(NSDictionary * _Nonnull)attributes;

/**
 *  Get the user's avatar URL
 *
 *  @param identification userID
 *  @param block          Callback block(url, error)
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask * _Nonnull)getUserAvatarPathWithID:(NSUInteger)identification andBlock:(void (^ _Nullable)(NSString * _Nullable, NSError * _Nullable))block;

/**
 *  Get the information by the given userID
 *
 *  @param userID user's identifier
 *  @param block  Callback block
 */
+ (void)getUserinfoWithID:(NSUInteger)userID andBlock:(void (^ _Nullable)(User * _Nullable, NSError * _Nullable))block;

/**
 *  Get the personal detail by the given userID
 *
 *  @param userID        user's identifier
 *  @param currentUserID currently logged in user's identifier
 *  @param block         Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask * _Nonnull)getPersonalPageDetailWithUserID:(NSUInteger)userID andCurrentUserID:(NSUInteger)currentUserID andBlock:(void (^ _Nullable)(NSDictionary * _Nullable details, NSError * _Nullable error))block;

/**
 *  Follow someone in the personal page
 *
 *  @param followUserID  Who do you wanna follow
 *  @param currentUserID Who are you
 *  @param isFollow      Action, follow/unfollow
 *  @param block         Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask * _Nonnull)followUserToWhom:(NSUInteger)followUserID withCurrentUserID:(NSUInteger)currentUserID toFollow:(BOOL)isFollow andBlock:(void (^ _Nullable)(BOOL success, NSDictionary * _Nullable JSON, NSError * _Nullable error))block;

/**
 *  Get the follower/ing list by the given userID
 *
 *  @param userID user's identifier
 *  @param type   Follower or following
 *  @param page   Page number
 *  @param count  Count per page
 *  @param block  Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask * _Nonnull)getFollowListByUserID:(NSUInteger)userID andType:(NSString * _Nonnull)type withPage:(NSUInteger)page forCountPerPage:(NSUInteger)count andBlock:(void (^ _Nullable)(NSDictionary * _Nullable JSON, NSError * _Nullable error))block;

/**
 *  Daily check in by the given userID
 *
 *  @param userID user's identifier
 *  @param block  Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask * _Nonnull)dailyCheckIn:(NSUInteger)userID andBlock:(void (^ _Nullable)(NSDictionary * _Nullable JSON, NSError * _Nullable error))block;

/**
 *  Get the comment history by the given userID
 *
 *  @param userID user's identifier
 *  @param page   Page number
 *  @param count  Count per page
 *  @param block  Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask * _Nonnull)getCommentListByUserID:(NSUInteger)userID andPage:(NSUInteger)page withCount:(NSUInteger)count andBlock:(void (^ _Nullable)(NSArray * _Nullable, NSError * _Nullable))block;

/**
 *  Collect/star a post by the given postID
 *
 *  @param postID post's identifier
 *  @param remove Remove or collect
 *  @param block  Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask * _Nonnull)collectPostByPostID:(NSUInteger)postID forRemove:(BOOL)remove andBlock:(void (^ _Nullable)(BOOL success, BOOL collected))block;

/**
 *  Like a post by the given postID
 *
 *  @param postID post's identifier
 *  @param block  Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask * _Nonnull)likePostByPostID:(NSUInteger)postID andBlock:(void (^ _Nullable)(BOOL success, BOOL liked, NSUInteger credit))block;

/**
 *  Get the current user's profile
 *
 *  @param block Callback block
 *
 *  @return NSURLSessionDataTask
 */
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

/**
 *  Update current user's avatar
 *
 *  @param data  Actual image data
 *  @param block Callback block
 */
+ (void)updateCurrentUserAvatar:(NSData * _Nonnull)data andBlock:(void (^ _Nonnull)(BOOL success,NSString * _Nonnull message,  NSString * _Nullable avatarURL))block;

/**
 *  Get current user's membership, see if expired
 *
 *  @param block Callback block
 */
+ (void)getCurrentUserMembership:(void (^ _Nonnull)(BOOL hasExpired))block;

/**
 *  Get friendship request
 *
 *  @param block Callback block
 */
+ (void)getFriendshipRequestInBlock:(void (^ _Nullable)(NSArray * _Nullable users, NSError * _Nullable error))block;

@end
