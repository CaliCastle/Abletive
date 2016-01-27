//
//  UserComment.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "UserComment.h"

@implementation UserComment

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.postTitle = attributes[@"title"];
        self.postID = [attributes[@"detail"][@"comment_post_ID"]intValue];
        self.commentID = [attributes[@"detail"][@"comment_ID"]intValue];
        self.commentDate = attributes[@"detail"][@"comment_date"];
        self.content = attributes[@"detail"][@"comment_content"];
        self.isFromApp = [attributes[@"detail"][@"comment_agent"] isEqualToString:@"iOS APP"];
    }
    return self;
}

+ (instancetype)userCommentWithAttributes:(NSDictionary *)attributes {
    return [[UserComment alloc]initWithAttributes:attributes];
}

@end
