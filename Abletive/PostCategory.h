//
//  PostCategory.h
//  Abletive
//
//  Created by Cali on 6/30/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostCategory : NSObject

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

- (instancetype)initWithAttributes:(NSDictionary *)attributes;
+ (void)postCategoriesWithBlock:(void (^)(NSArray *, NSError *))block;

@end
