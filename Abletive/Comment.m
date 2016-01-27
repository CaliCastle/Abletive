//
//  Comment.m
//  Abletive
//
//  Created by Cali on 7/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "Comment.h"

static NSString * const submitCommentUrl = @"respond/submit_comment";

@implementation Comment

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        self.commentID = [attributes[@"id"]unsignedIntegerValue];
        self.content = attributes[@"content"];
        self.date = attributes[@"date"];
        self.parent = [attributes[@"parent"]unsignedIntegerValue];
        self.author = [User userWithAttributes:attributes[@"author"]];
        self.agent = attributes[@"agent"];
    }
    return self;
}

+ (instancetype)commentWithAttributes:(NSDictionary *)attributes {
    return [[Comment alloc]initWithAttributes:attributes];
}

+ (void)submitCommentWithPostID:(NSUInteger)post_id andUserInfo:(NSDictionary *)userInfo inBlock:(void (^)(Comment *,NSError *))block {
    [[AbletiveAPIClient sharedClient] POST:submitCommentUrl parameters:@{@"post_id":[NSNumber numberWithInteger:post_id],@"user_id":[NSNumber numberWithInt:[userInfo[@"user_id"] intValue]],@"content":userInfo[@"content"],@"name":userInfo[@"name"],@"parent":userInfo[@"parent"],@"email":userInfo[@"email"]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        
        if ([JSON[@"status"] isEqualToString:@"ok"] && [JSON[@"comment_id"] intValue] != 0) {
            Comment *newComment = [[Comment alloc]initWithAttributes:@{@"id":JSON[@"comment_id"],@"parent":userInfo[@"parent"],@"content":userInfo[@"content"],@"date":JSON[@"comment_date"],@"author":@{@"id":userInfo[@"user_id"],@"avatar":[[NSUserDefaults standardUserDefaults]stringForKey:@"user_avatar_path"],@"name":userInfo[@"name"]},@"agent":@"iOS APP"}];
            if (block) {
                block(newComment,nil);
            }
        } else {
            if (block) {
                block(nil,[NSError errorWithDomain:@"abletive.com" code:101 userInfo:nil]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

@end
