//
//  UserCollection.h
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCollection : NSObject

@property (nonatomic,assign) NSUInteger postID;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *authorName;
@property (nonatomic,assign) NSUInteger views;
@property (nonatomic,strong) NSString *thumbnail;
@property (nonatomic,strong) NSString *categoryName;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *excerpt;
@property (nonatomic,strong) NSString *commentCount;

+ (instancetype)userCollectionWithAttributes:(NSDictionary *)attributes;

+ (NSURLSessionDataTask *)getCollectionListByUserID:(NSUInteger)userID andPage:(NSUInteger)page andCount:(NSUInteger)count andBlock:(void (^)(NSArray *, NSError *))block;

@end
