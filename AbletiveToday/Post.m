//
//  Post.m
//  Abletive
//
//  Created by Cali on 6/16/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "Post.h"
#import "NSString+ConvertAmpersandSymbol.h"

@interface Post()

@end

@implementation Post

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.postID = [attributes[@"id"]unsignedIntegerValue];
        self.title = [NSString parseString:attributes[@"title"]];
        self.url = attributes[@"url"];
        self.author = [[User alloc]initWithShortAttributes:attributes[@"author"]];
        if (attributes[@"thumbnail_images"]) {
            NSString *imagePath = attributes[@"thumbnail_images"][@"full"][@"url"]?attributes[@"thumbnail_images"][@"full"][@"url"]:@"";
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:imagePath];
            self.imageFullPath = [imagePath stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
            
            imagePath = attributes[@"thumbnail_images"][@"large"][@"url"]?attributes[@"thumbnail_images"][@"large"][@"url"]:@"";
            characterSet = [NSCharacterSet characterSetWithCharactersInString:imagePath];
            self.imageLargePath = [imagePath stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
            
            imagePath = attributes[@"thumbnail_images"][@"medium"][@"url"]?attributes[@"thumbnail_images"][@"medium"][@"url"]:@"";
            characterSet = [NSCharacterSet characterSetWithCharactersInString:imagePath];
            self.imageMediumPath = [imagePath stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        }
        self.visitCount = [[attributes[@"custom_fields"][@"views"]firstObject]integerValue];
        self.commentCount = [attributes[@"comment_count"]integerValue];
        self.belongedCategories = [NSMutableArray arrayWithArray:attributes[@"categories"]];
        self.tags = [NSMutableArray arrayWithArray:attributes[@"tags"]];
        self.date = attributes[@"date"];
        self.shortDescription = attributes[@"excerpt"];
    }
    return self;
}

- (instancetype)initWithCache:(NSDictionary *)cache {
    if (self = [super init]) {
        self.postID = [cache[@"post_id"]intValue];
        self.title = cache[@"title"];
        self.author = [User userWithAttributes:cache[@"author"]];
        self.imageFullPath = cache[@"thumbnail"];
        self.imageMediumPath = cache[@"thumbnail"];
        self.visitCount = [cache[@"visit_count"]intValue];
        self.commentCount = [cache[@"comment_count"]intValue];
        self.belongedCategories = [NSMutableArray arrayWithArray:@[cache[@"category"]]];
        self.date = cache[@"date"];
        self.shortDescription = cache[@"description"];
    }
    return self;
}

+ (NSURLSessionDataTask *)globalTimelinePostsWithPage:(NSInteger)page WithBlock:(void (^)(Post *, NSError *))block {
    NSURLSessionDataTask *task = [[AbletiveAPIClient sharedClient] POST:@"get_posts" parameters:@{@"page":[NSNumber numberWithInteger:page],@"count":[NSNumber numberWithInt:1]} success:^(NSURLSessionDataTask * __unused task, NSDictionary  *JSON) {
        NSArray *postsFromResponse = JSON[@"posts"];
        
        NSDictionary *attributes = [postsFromResponse firstObject];
        Post *post = [[Post alloc] initWithAttributes:attributes];
        
        if (block) {
            block(post, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
    
    return task;
}

@end
