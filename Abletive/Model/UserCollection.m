//
//  UserCollection.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "UserCollection.h"
#import "AbletiveAPIClient.h"
#import "NSString+ConvertAmpersandSymbol.h"

@implementation UserCollection

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.postID = [attributes[@"id"]intValue];
        self.title = [NSString parseString:attributes[@"title"]];
        self.authorName = attributes[@"author"];
        self.date = attributes[@"date"];
        self.thumbnail = attributes[@"thumbnail"][@"0"];
        self.commentCount = attributes[@"comment_count"];
        self.categoryName = attributes[@"category"];
        self.excerpt = attributes[@"excerpt"];
        self.views = [attributes[@"views"]intValue];
    }
    return self;
}

+ (instancetype)userCollectionWithAttributes:(NSDictionary *)attributes {
    return [[UserCollection alloc]initWithAttributes:attributes];
}

+ (NSURLSessionDataTask *)getCollectionListByUserID:(NSUInteger)userID andPage:(NSUInteger)page andCount:(NSUInteger)count andBlock:(void (^)(NSArray *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/get_collection_list" parameters:@{@"user_id":[NSNumber numberWithInteger:userID],@"page":[NSNumber numberWithInteger:page],@"count":[NSNumber numberWithInteger:count]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *collectionList = JSON[@"collection_list"];
            NSMutableArray *userCollections = [NSMutableArray array];
            for (NSDictionary *attribute in collectionList) {
                UserCollection *collection = [UserCollection userCollectionWithAttributes:attribute];
                [userCollections addObject:collection];
            }
            if (block) {
                block(userCollections,nil);
            }
        } else {
            if (block) {
                block(nil,[NSError new]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

@end
