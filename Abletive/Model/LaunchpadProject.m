//
//  LaunchpadProject.m
//  Abletive
//
//  Created by Cali on 11/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "LaunchpadProject.h"
#import "AbletiveAPIClient.h"

@implementation LaunchpadProject

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.projectName = attributes[@"title"];
        self.baiduLink = attributes[@"baidu"];
        self.qiniuLink = attributes[@"qiniu"];
        self.thumbnail = attributes[@"img_src"];
        self.star = [attributes[@"star"]intValue];
        self.maker = attributes[@"maker"];
        self.videoLink = attributes[@"video"];
        self.postLink = attributes[@"post_url"];
    }
    return self;
}

+ (instancetype)launchpadProjectWithAttributes:(NSDictionary *)attributes {
    return [[LaunchpadProject alloc]initWithAttributes:attributes];
}

+ (void)getLaunchpadProjectsWithStar:(NSUInteger)star andBlock:(void (^)(NSArray *, NSError *))block {
    [[AbletiveAPIClient sharedVIPClient] POST:@"interface.php" parameters:@{@"star":[NSNumber numberWithInteger:star]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if (JSON[@"list"]) {
            NSArray *rawAttributes = JSON[@"list"];
            NSMutableArray *projects = [NSMutableArray array];
            for (NSDictionary *attributes in rawAttributes) {
                LaunchpadProject *project = [LaunchpadProject launchpadProjectWithAttributes:attributes];
                [projects addObject:project];
            }
            
            if (block) {
                block(projects, nil);
            }
        } else {
            if (block) {
                block(nil, [NSError new]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

@end
