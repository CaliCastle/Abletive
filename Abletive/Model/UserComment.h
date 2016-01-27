//
//  UserComment.h
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserComment : NSObject

@property (nonatomic,assign) NSUInteger postID;

@property (nonatomic,assign) NSUInteger commentID;

@property (nonatomic,strong) NSString *commentDate;

@property (nonatomic,strong) NSString *content;

@property (nonatomic,assign) BOOL isFromApp;

@property (nonatomic,strong) NSString *postTitle;

+ (instancetype)userCommentWithAttributes:(NSDictionary *)attributes;

@end
