//
//  PostTag.h
//  Abletive
//
//  Created by Cali on 6/30/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostTag : NSObject

#pragma mark Properties
/**
 ID of the tag, primary key
 */
@property (nonatomic,assign) NSUInteger tagID;
/**
 Slug of the tag, for URL
 */
@property (nonatomic,strong) NSString *slug;
/**
 Name of the tag, can contain Chinese string
 */
@property (nonatomic,strong) NSString *name;
/**
 Count of how many posts are in the tag
 */
@property (nonatomic,assign) NSUInteger postCount;

#pragma mark Methods

/**
 *  Initializer with the given attributes
 *
 *  @param attributes NSDicionary
 *
 *  @return Post Tag instance
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

/**
 *  Get post tags
 *
 *  @param block Callback block
 */
+ (void)postTagWithBlock:(void (^)(NSArray *,NSError *))block;

@end
