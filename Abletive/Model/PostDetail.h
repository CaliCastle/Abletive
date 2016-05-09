//
//  PostDetail.h
//  Abletive
//
//  Created by Cali on 10/3/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbletiveAPIClient.h"
#import "User.h"

@interface PostDetail : NSObject

#pragma mark Properties

/**
 * ID of the post
 */
@property (nonatomic,assign) NSUInteger postID;
/**
 * Title of the post
 */
@property (nonatomic,strong) NSString *title;
/**
 * Author of the post
 */
@property (nonatomic,strong) User *author;
/**
 * Publish date of the post
 */
@property (nonatomic,strong) NSString *date;
/**
 * Count of total visits
 */
@property (nonatomic,assign) NSUInteger visitCount;
/**
 * Count of total comments
 */
@property (nonatomic,assign) NSUInteger commentCount;
/**
 * Categories of the post
 */
@property (nonatomic,strong) NSMutableArray *belongedCategories;
/**
 * Tags of the post
 */
@property (nonatomic,strong) NSMutableArray *tags;
/**
 * Content of the post
 */
 @property (nonatomic,strong) NSString *content;
/**
 * Comments of the post
 */
 @property (nonatomic,strong) NSMutableArray *comments;
/**
 * Url of the post
 */
@property (nonatomic,strong) NSString *postUrl;
/**
 * Thumbnail url path
 */
@property (nonatomic,strong) NSString *thumbnail;
/**
 * Short description of the post
 */
@property (nonatomic,strong) NSString *shortDescription;

/**
 *  How many people liked
 */
@property (nonatomic,assign) NSUInteger numberOfLikes;

/**
 *  How many people bookmarked
 */
@property (nonatomic,assign) NSUInteger numberOfBookmarks;

/**
 * Raw presentation of the model
 */
@property (nonatomic,strong) NSDictionary *rawPresentation;

#pragma mark Methods

/**
 *  Initializer with the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return Post Detail instance
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

/**
 *  Factory method with the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return Post Detail instance
 */
+ (instancetype)postDetailWithAttributes:(NSDictionary *)attributes;

/**
 *  Get post detail by the given post ID
 *
 *  @param id     postID
 *  @param cookie Cookie string if logged in
 *  @param block  Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)postDetailByID:(NSUInteger)id withCookie:(NSString *)cookie andOrder:(BOOL)order andBlock:(void (^)(PostDetail *,NSError *))block;

/**
 *  Get page detail by the given page ID
 *
 *  @param pageID pageID
 *  @param block  Callback block
 */
+ (void)pageDetailByID:(NSUInteger)pageID andOrder:(BOOL)order andBlock:(void (^)(PostDetail *, NSError *))block;

/**
 *  Get post detail by the given page slug
 *
 *  @param slug  Slug string
 *  @param block Callback block
 */
+ (void)getPostDetailBySlug:(NSString *)slug andOrder:(BOOL)order andBlock:(void (^)(PostDetail *, NSError *))block;

/**
 *  Get page detail by the given page slug
 *
 *  @param slug  Slug string
 *  @param block Callback block
 */
+ (void)getPageDetailBySlug:(NSString *)slug andBlock:(void (^)(PostDetail *, NSError *))block;

/**
 *  Init with coder
 *
 *  @param coder Coder
 *
 *  @return Post Detail instance
 */
- (instancetype)initWithCoder:(NSCoder *)coder;

/**
 *  Encode with coder
 *
 *  @param coder Coder
 */
- (void)encodeWithCoder:(NSCoder *)coder;

@end
