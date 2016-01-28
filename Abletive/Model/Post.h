//
//  Post.h
//  Abletive
//
//  Created by Cali on 6/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "AbletiveAPIClient.h"

/**
 *  Enumeration for different sort type
 */
typedef NS_ENUM(NSInteger, PostSortType) {
    /**
     *  By Category
     */
    PostSortTypeCategory,
    /**
     *  By Tag
     */
    PostSortTypeTag,
    /**
     *  By Author
     */
    PostSortTypeAuthor,
    /**
     *  By Calendar
     */
    PostSortTypeCalendar
};

/**
 *  Post model
 */
@interface Post : NSObject

#pragma mark Properties

/**
 Post ID of the post
 */
@property (nonatomic,assign) NSUInteger postID;
/**
 Title of the post
 */
@property (nonatomic,strong) NSString *title;
/**
 The one and only url of the post
 */
@property (nonatomic,strong) NSString *url;
/**
 Author of the post 
 */
@property (nonatomic,strong) User *author;
/**
 Thumbnail image medium path of the post
 */
@property (nonatomic,strong) NSString *imageMediumPath;
/**
 Thumbnail image full path of the post
 */
@property (nonatomic,strong) NSString *imageFullPath;
/**
 Thumbnail image large path of the post
 */
@property (nonatomic,strong) NSString *imageLargePath;
/**
 Publish date of the post
 */
@property (nonatomic,strong) NSString *date;
/**
 Count of total visits 
 */
@property (nonatomic,assign) NSUInteger visitCount;
/**
 Count of total comments 
 */
@property (nonatomic,assign) NSUInteger commentCount;
/**
 Categories of the post 
 */
@property (nonatomic,strong) NSMutableArray *belongedCategories;
/**
 Tags of the post 
 */
@property (nonatomic,strong) NSMutableArray *tags;
/**
 Short description of the post 
 */
@property (nonatomic,strong) NSString *shortDescription;

#pragma mark Methods

/**
 *  Initializer with the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return Post instance
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

/**
 *  Initializer with the given cache
 *
 *  @param cache NSDictionary
 *
 *  @return Post instance
 */
- (instancetype)initWithCache:(NSDictionary *)cache;

/**
 *  Send request to the server and get global timeline posts
 *
 *  @param cookie The cookie stored in the User Defaults
 *  @param page   The current page index
 *  @param count  How many posts to be loaded
 *  @param block  Call back when the posts are done loaded
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)globalTimelinePostsWithCookie:(NSString *)cookie andPage:(NSUInteger)page andCount:(NSUInteger)count andBlock:(void (^)(NSArray *, NSArray *, NSError *))block;

/**
 *  Get recent posts
 *
 *  @param cookie The cookie stored in the User Defaults
 *  @param block  Callback block
 *
 *  @return NSURLSessionDataTask
 */
+ (NSURLSessionDataTask *)recentPostsWithCookie:(NSString *)cookie andBlock:(void (^)(NSArray *,NSArray *,NSError *))block;

/**
 *  Sorted posts with sort type
 *
 *  @param type           Sort type
 *  @param identification identifier
 *  @param date           Datetime
 *  @param page           Page number
 *  @param block          Callback block
 */
+ (void)postSortedWithSortType:(PostSortType)type andID:(NSUInteger)identification withDate:(NSString *)date atPage:(NSUInteger)page inBlock:(void (^)(NSArray *, NSError *))block;

/**
 *  Search posts with keywords
 *
 *  @param searchText keywords
 *  @param page       Page number
 *  @param block      Callback block
 */
+ (void)postSearchWithSearchText:(NSString *)searchText forPage:(NSUInteger)page inBlock:(void (^)(NSArray *, NSError *))block;

@end
