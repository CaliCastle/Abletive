//
//  PostCategory.m
//  Abletive
//
//  Created by Cali on 6/30/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PostCategory.h"
#import "Networking Extension/AbletiveAPIClient.h"

@implementation PostCategory

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        self.categoryID = [attributes[@"id"]unsignedIntegerValue];
        self.slug = attributes[@"slug"];
        if ([attributes[@"title"] containsString:@"&"]) {
            self.name = [attributes[@"title"] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        }
        else {
            self.name = attributes[@"title"];
        }
        self.categoryDesc = attributes[@"description"];
        self.postCount = [attributes[@"post_count"]integerValue];
    }
    return self;
}

+ (void)postCategoriesWithBlock:(void (^)(NSArray *, NSError *))block {
    [[AbletiveAPIClient sharedClient] POST:@"get_category_index" parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *postCategoriesFromResponse = JSON[@"categories"];
            NSMutableArray *categories = [NSMutableArray arrayWithCapacity:postCategoriesFromResponse.count];
            for (NSDictionary *attributes in postCategoriesFromResponse) {
                PostCategory *category = [[PostCategory alloc]initWithAttributes:attributes];
                [categories addObject:category];
            }
            if (block) {
                block([NSArray arrayWithArray:categories],nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block([NSArray array],error);
        }
    }];
}
@end
