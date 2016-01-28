//
//  PostCategory.h
//  Abletive
//
//  Created by Cali on 6/30/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Post Category model
 */
@interface PostCategory : NSObject

#pragma mark Properties

/**
 ID for the category, primary key
 */
@property (nonatomic,assign) NSUInteger categoryID;
/**
 The slug of the category (unique and only lower-case letters)
 */
@property (nonatomic,strong) NSString *slug;
/**
 The name of the cateogry (such like a Chinese string)
 */
@property (nonatomic,strong) NSString *name;
/**
 Short description of the category
 */
@property (nonatomic,strong) NSString *categoryDesc;
/**
 How many posts are in this category
 */
@property (nonatomic,assign) NSUInteger postCount;

#pragma mark Methods
/**
 *  Initializer with the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return Post Category instance
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

/**
 *  Get post categories
 *
 *  @param block Callback block
 */
+ (void)postCategoriesWithBlock:(void (^)(NSArray *, NSError *))block;

@end
