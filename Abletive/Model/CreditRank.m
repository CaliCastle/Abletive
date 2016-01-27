//
//  CreditRank.m
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import "CreditRank.h"
#import "AbletiveAPIClient.h"
#import "NSString+FilterHTML.h"

@implementation CreditRank

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.name = attributes[@"name"];
        self.credit = attributes[@"credit"];
        self.avatarURL = [NSString filterImageTag:attributes[@"avatar"]];
        self.userID = [attributes[@"user_id"] intValue];
    }
    return self;
}

+ (instancetype)creditRankWithAttributes:(NSDictionary *)attributes {
    return [[CreditRank alloc]initWithAttributes:attributes];
}

+ (void)getCreditRankWithLimit:(NSInteger)limit andBlock:(void (^)(NSArray *))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/get_credit_ranks" parameters:@{@"limit":[NSNumber numberWithInteger:limit]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *list = JSON[@"credit_list"];
            NSMutableArray *rankList = [NSMutableArray arrayWithCapacity:list.count];
            for (NSDictionary *attribute in list) {
                CreditRank *creditRank = [CreditRank creditRankWithAttributes:attribute];
                [rankList addObject:creditRank];
            }
            block(rankList);
        } else {
            block(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(nil);
    }];
}

@end
