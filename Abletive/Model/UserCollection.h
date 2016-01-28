//
//  UserCollection.h
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  UserCollection model
 */
@interface UserCollection : NSObject

#pragma mark Properties

/**
 *  Which post
 */
@property (nonatomic,assign) NSUInteger postID;

/**
 *  Post's title
 */
@property (nonatomic,strong) NSString *title;

/**
 *  The author name of the post
 */
@property (nonatomic,strong) NSString *authorName;

/**
 *  Post views
 */
@property (nonatomic,assign) NSUInteger views;

/**
 *  Post thumbnail url
 */
@property (nonatomic,strong) NSString *thumbnail;

/**
 *  Post category
 */
@property (nonatomic,strong) NSString *categoryName;

/**
 *  Datetime
 */
@property (nonatomic,strong) NSString *date;

/**
 *  Excerpt/short description
 */
@property (nonatomic,strong) NSString *excerpt;

/**
 *  Count of its comment
 */
@property (nonatomic,strong) NSString *commentCount;


#pragma mark Methods

/**
 *  Factory method of newing up by the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return UserCollection instance
 */
+ (instancetype)userCollectionWithAttributes:(NSDictionary *)attributes;

/**
 *  Get the collection list by the given userID
 *
 *  @param userID user's identifier
 *  @param page   Page number
 *  @param count  Count per page
 *  @param block  Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)getCollectionListByUserID:(NSUInteger)userID andPage:(NSUInteger)page andCount:(NSUInteger)count andBlock:(void (^)(NSArray *, NSError *))block;

@end
