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

static NSString * const getCategoryURL = @"get_category_posts";
static NSString * const getTagURL = @"get_tag_posts";
static NSString * const getAuthorURL = @"get_author_posts";
static NSString * const getCalendarURL = @"get_date_posts";
static NSString * const getCollectionURL = @"user/get_collection_list";


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
        self.shortDescription = [NSString parseString:attributes[@"excerpt"]];
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

+ (NSURLSessionDataTask *)globalTimelinePostsWithCookie:(nullable NSString *)cookie andPage:(NSUInteger)page andCount:(NSUInteger)count andBlock:(void (^)(NSArray *, NSArray *, NSError *))block {
    NSURLSessionDataTask *task = [[AbletiveAPIClient sharedClient] POST:@"get_posts" parameters:@{@"page":[NSString stringWithFormat:@"%ld",(unsigned long)page],@"count":[NSString stringWithFormat:@"%ld",(unsigned long)count],@"cookie":cookie?cookie:@""} success:^(NSURLSessionDataTask * __unused task, NSDictionary  *JSON) {
        NSArray *postsFromResponse = JSON[@"posts"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        NSMutableArray *postsAttribute = [NSMutableArray arrayWithCapacity:[postsFromResponse count]];
        for (NSDictionary *attributes in postsFromResponse) {
            Post *post = [[Post alloc] initWithAttributes:attributes];
            [mutablePosts addObject:post];
            [postsAttribute addObject:@{@"post_id":[NSNumber numberWithInteger:post.postID],@"title":post.title,@"description":post.shortDescription,@"date":post.date,@"comment_count":[NSNumber numberWithInteger:post.commentCount],@"author":attributes[@"author"],@"visit_count":[NSNumber numberWithInteger:post.visitCount],@"category":[post.belongedCategories lastObject],@"thumbnail":post.imageMediumPath?post.imageMediumPath:@""}];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], [NSArray arrayWithArray:postsAttribute], nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block([NSArray array], [NSArray array], error);
        }
    }];
    
    return task;
}

+ (NSURLSessionDataTask *)recentPostsWithCookie:(nullable NSString *)cookie andBlock:(void (^)(NSArray *,NSArray *,NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"get_recent_posts" parameters:@{@"count":@"3",@"cookie":cookie?cookie:@""} success:^(NSURLSessionDataTask * __unused task, NSDictionary *JSON) {
        NSArray *postsFromResponse = JSON[@"posts"];
        NSMutableArray *recentPosts = [NSMutableArray arrayWithCapacity:postsFromResponse.count];
        for (NSDictionary *attributes in postsFromResponse) {
            Post *post = [[Post alloc]initWithAttributes:attributes];
            [recentPosts addObject:post];
        }
        if (block) {
            block([NSArray arrayWithArray:recentPosts],postsFromResponse,nil);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error:%@",error.userInfo);
        if (block) {
            block([NSArray array],[NSArray array],error);
        }
    }];
}

+ (void)postSortedWithSortType:(PostSortType)type andID:(NSUInteger)identification withDate:(NSString *)date atPage:(NSUInteger)page inBlock:(void (^)(NSArray *, NSError *))block {
    switch (type) {
        case PostSortTypeCategory:
        {
            [[AbletiveAPIClient sharedClient] POST:getCategoryURL parameters:@{@"page":[NSString stringWithFormat:@"%ld",(unsigned long)page],@"count":@"20",@"id":[NSString stringWithFormat:@"%ld",(unsigned long)identification]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
                 if ([JSON[@"status"] isEqualToString:@"ok"]) {
                     NSArray *postsFromResponse = JSON[@"posts"];
                     NSMutableArray *posts = [NSMutableArray arrayWithCapacity:postsFromResponse.count];
                     for (NSDictionary *attributes in postsFromResponse) {
                         Post *post = [[Post alloc]initWithAttributes:attributes];
                         [posts addObject:post];
                     }
                     if (block) {
                         block([NSArray arrayWithArray:posts],nil);
                     }
                 }
                 else {
                     if (block) {
                         block([NSArray array],nil);
                     }
                 }
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 if (block) {
                     block([NSArray array],error);
                 }
             }];
             return;
        }
        case PostSortTypeTag:
        {
            [[AbletiveAPIClient sharedClient] POST:getTagURL parameters:@{@"page":[NSString stringWithFormat:@"%ld",(unsigned long)page],@"count":@"20",@"id":[NSString stringWithFormat:@"%ld",(unsigned long)identification]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
                if ([JSON[@"status"] isEqualToString:@"ok"]) {
                    NSArray *postsFromResponse = JSON[@"posts"];
                    NSMutableArray *posts = [NSMutableArray arrayWithCapacity:postsFromResponse.count];
                    for (NSDictionary *attributes in postsFromResponse) {
                        Post *post = [[Post alloc]initWithAttributes:attributes];
                        [posts addObject:post];
                    }
                    if (block) {
                        block([NSArray arrayWithArray:posts],nil);
                    }
                }
                else {
                    if (block) {
                        block([NSArray array],nil);
                    }
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block([NSArray array],error);
                }
            }];
            return;
        }
        case PostSortTypeAuthor:
        {
            [[AbletiveAPIClient sharedClient] POST:getAuthorURL parameters:@{@"page":[NSString stringWithFormat:@"%ld",(unsigned long)page],@"count":@"20",@"id":[NSString stringWithFormat:@"%ld",(unsigned long)identification]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
                if ([JSON[@"status"] isEqualToString:@"ok"]) {
                    NSArray *postsFromResponse = JSON[@"posts"];
                    NSMutableArray *posts = [NSMutableArray arrayWithCapacity:postsFromResponse.count];
                    for (NSDictionary *attributes in postsFromResponse) {
                        Post *post = [[Post alloc]initWithAttributes:attributes];
                        [posts addObject:post];
                    }
                    if (block) {
                        block([NSArray arrayWithArray:posts],nil);
                    }
                }
                else {
                    if (block) {
                        block([NSArray array],nil);
                    }
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block([NSArray array],error);
                }
            }];
            return;
        }
        case PostSortTypeCalendar:
        {
            [[AbletiveAPIClient sharedClient] POST:getCalendarURL parameters:@{@"page":[NSString stringWithFormat:@"%ld",(unsigned long)page],@"count":@"20",@"date":date} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
                if ([JSON[@"status"] isEqualToString:@"ok"]) {
                    NSArray *postsFromResponse = JSON[@"posts"];
                    NSMutableArray *posts = [NSMutableArray arrayWithCapacity:postsFromResponse.count];
                    for (NSDictionary *attributes in postsFromResponse) {
                        Post *post = [[Post alloc]initWithAttributes:attributes];
                        [posts addObject:post];
                    }
                    if (block) {
                        block([NSArray arrayWithArray:posts],nil);
                    }
                }
                else {
                    if (block) {
                        block([NSArray array],nil);
                    }
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                if (block) {
                    block([NSArray array],error);
                }
            }];
            return;
        }
        default:
            break;
    }
    
}

+ (void)postSearchWithSearchText:(NSString *)searchText forPage:(NSUInteger)page inBlock:(void (^)(NSArray *, NSError *))block {
    [[AbletiveAPIClient sharedClient] POST:@"get_search_results" parameters:@{@"search":searchText,@"count":@"20",@"page":[NSString stringWithFormat:@"%ld",(unsigned long)page]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *postsFromResponse = JSON[@"posts"];
            NSMutableArray *posts = [NSMutableArray arrayWithCapacity:postsFromResponse.count];
            for (NSDictionary *attributes in postsFromResponse) {
                Post *post = [[Post alloc]initWithAttributes:attributes];
                [posts addObject:post];
            }
            if (block) {
                block([NSArray arrayWithArray:posts],nil);
            }
        }
        else {
            if (block) {
                block([NSArray array],nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block([NSArray array],error);
        }
    }];
}

@end
