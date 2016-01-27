//
//  PostTag.m
//  Abletive
//
//  Created by Cali on 6/30/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PostTag.h"
#import "Networking Extension/AbletiveAPIClient.h"

@implementation PostTag

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        self.tagID = [attributes[@"id"]unsignedIntegerValue];
        self.slug = attributes[@"slug"];
        self.name = attributes[@"title"];
        self.postCount = [attributes[@"post_count"]unsignedIntegerValue];
    }
    return self;
}

+ (void)postTagWithBlock:(void (^)(NSArray *, NSError *))block {
    [[AbletiveAPIClient sharedClient] POST:@"get_tag_index" parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *postTagsFromResponse = JSON[@"tags"];
            NSMutableArray *tags = [NSMutableArray arrayWithCapacity:postTagsFromResponse.count];
            for (NSDictionary *attributes in postTagsFromResponse) {
                PostTag *tag = [[PostTag alloc]initWithAttributes:attributes];
                [tags addObject:tag];
            }
            if (block) {
                block([NSArray arrayWithArray:tags],nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block([NSArray array],error);
        }
    }];
}

@end
