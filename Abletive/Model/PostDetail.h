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
 ID of the post
 */
@property (nonatomic,assign) NSUInteger postID;
/**
 Title of the post
 */
@property (nonatomic,strong) NSString *title;
/**
 Author of the post
 */
@property (nonatomic,strong) User *author;
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
 Content of the post
 */
 @property (nonatomic,strong) NSString *content;
/**
 Comments of the post
 */
 @property (nonatomic,strong) NSMutableArray *comments;
/**
 Url of the post
 */
@property (nonatomic,strong) NSString *postUrl;
/**
 Thumbnail path
 */
@property (nonatomic,strong) NSString *thumbnail;
/**
 Short description of the post
 */
@property (nonatomic,strong) NSString *shortDescription;

@property (nonatomic,assign) NSUInteger numberOfLikes;

@property (nonatomic,assign) NSUInteger numberOfBookmarks;

#pragma mark Methods

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

+ (instancetype)postDetailWithAttributes:(NSDictionary *)attributes;

+ (NSURLSessionDataTask *)postDetailByID:(NSUInteger)id withCookie:(NSString *)cookie andBlock:(void (^)(PostDetail *,NSError *))block;

+ (void)pageDetailByID:(NSUInteger)pageID andBlock:(void (^)(PostDetail *, NSError *))block;

+ (void)getPostDetailBySlug:(NSString *)slug andBlock:(void (^)(PostDetail *, NSError *))block;

@end
