//
//  PostDetail.m
//  Abletive
//
//  Created by Cali on 10/3/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "PostDetail.h"
#import "NSString+ConvertAmpersandSymbol.h"
#import "NSString+CCNSStringReverse.h"

@implementation PostDetail

- (instancetype)initWithAttributes:(NSDictionary *)attributes{
    if (self = [super init]){
        self.postID = [attributes[@"id"]integerValue];
        self.title = [NSString parseString:attributes[@"title"]];
        self.author = [[User alloc]initWithShortAttributes:attributes[@"author"]];
        self.content = [NSString parseString:attributes[@"content"]];
        self.visitCount = [[attributes[@"custom_fields"][@"views"]firstObject]integerValue];
        self.commentCount = [attributes[@"comment_count"]integerValue];
        self.comments = [NSMutableArray arrayWithArray:attributes[@"comments"]];
        self.belongedCategories = [NSMutableArray arrayWithArray:attributes[@"categories"]];
        self.tags = [NSMutableArray arrayWithArray:attributes[@"tags"]];
        self.date = attributes[@"date"];
        self.postUrl = attributes[@"url"];
        self.shortDescription = attributes[@"excerpt"];
        self.numberOfLikes = [[attributes[@"custom_fields"][@"um_post_likes"]firstObject] intValue];
        self.numberOfBookmarks = [[attributes[@"custom_fields"][@"um_post_collects"]firstObject] intValue];
        
        if (attributes[@"thumbnail_images"]) {
            NSString *imagePath = attributes[@"thumbnail_images"][@"full"][@"url"]?attributes[@"thumbnail_images"][@"full"][@"url"]:@"";
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:imagePath];
            self.thumbnail = [imagePath stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        }
        self.rawPresentation = attributes;
    }
    return self;
}

+ (instancetype)postDetailWithAttributes:(NSDictionary *)attributes{
    return [[PostDetail alloc]initWithAttributes:attributes];
}

+ (NSURLSessionDataTask *)postDetailByID:(NSUInteger)post_id withCookie:(NSString *)cookie andBlock:(void (^)(PostDetail *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"get_post" parameters:@{@"id":[NSString stringWithFormat:@"%ld",(unsigned long)post_id],@"cookie":cookie?cookie:@""} success:^(NSURLSessionDataTask * __unused task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            PostDetail *detailPost = [PostDetail postDetailWithAttributes:JSON[@"post"]];
            if (block) {
                block(detailPost,nil);
            }
        } else {
            if (block) {
                block(nil, [NSError new]);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error:%@",error.userInfo);
        if (block) {
            block(nil,error);
        }
    }];
}

+ (void)pageDetailByID:(NSUInteger)pageID andBlock:(void (^)(PostDetail *, NSError *))block {
    [[AbletiveAPIClient sharedClient] POST:@"get_page" parameters:@{@"id":[NSNumber numberWithInteger:pageID]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            PostDetail *detailPage = [PostDetail postDetailWithAttributes:JSON[@"page"]];
            if (block) {
                block(detailPage, nil);
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

+ (void)getPostDetailBySlug:(NSString *)slug andBlock:(void (^)(PostDetail *, NSError *))block {
    if ([slug containsString:@"http://abletive.com/"]) {
        slug = [slug reverse];
        slug = [[slug substringToIndex:[slug rangeOfString:@"/"].location] reverse];
    }
    
    [[AbletiveAPIClient sharedClient] POST:@"get_post" parameters:@{@"slug":slug} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            PostDetail *detailPost = [PostDetail postDetailWithAttributes:JSON[@"post"]];
            if (block) {
                block(detailPost,nil);
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

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self = [self initWithAttributes:[coder decodeObjectForKey:@"raw"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.rawPresentation forKey:@"raw"];
}

@end
