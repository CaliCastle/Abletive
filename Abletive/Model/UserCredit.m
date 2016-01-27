//
//  UserCredit.m
//  Abletive
//
//  Created by Cali on 10/17/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "UserCredit.h"

@implementation UserCredit

/**
 *  Initializes an instance of UserCredit
 *
 *  @param attributes JSON results
 *
 *  @return A model Instance Being Created
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.date = attributes[@"date"];
        self.content = attributes[@"content"];
    }
    return self;
}

+ (instancetype)userCreditWithAttributes:(NSDictionary *)attributes {
    return [[UserCredit alloc]initWithAttributes:attributes];
}

+ (NSURLSessionDataTask *)getUserCreditWithUserID:(NSUInteger)userID andPage:(NSUInteger)page withCount:(NSUInteger)count andBlock:(void (^)(NSArray *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/get_credit_list" parameters:@{@"user_id":[NSNumber numberWithInteger:userID],@"page":[NSNumber numberWithInteger:page],@"count":[NSNumber numberWithInteger:count]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *credit_list = JSON[@"credit_list"];
            NSMutableArray *credits = [NSMutableArray array];
            for (NSDictionary *attribute in credit_list) {
                UserCredit *credit = [UserCredit userCreditWithAttributes:attribute];
                [credits addObject:credit];
            }
            
            if (block) {
                block(credits,nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}
@end
