//
//  Comment.h
//  Abletive
//
//  Created by Cali on 7/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbletiveAPIClient.h"
#import "User.h"

@interface Comment : NSObject

/**
 *  Comment ID (Primary Key)
 */
@property (nonatomic,assign) NSUInteger commentID;
/**
 *  Comment content
 */
@property (nonatomic,strong) NSString *content;
/**
 *  Comment date
 */
@property (nonatomic,strong) NSString *date;
/**
 *  Comment is a reply to whom (commentID)
 */
@property (nonatomic,assign) NSUInteger parent;
/**
 *  The author posted the comment
 */
@property (nonatomic,strong) User *author;
/**
 *  User agent of the comment
 */
@property (nonatomic,strong) NSString *agent;

/**
 *  Instantiate a Comment object
 *
 *  @param attributes JSON (Dictionary) attribute
 *
 *  @return Comment object
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

/**
 *  Factory method for instantiation
 *
 *  @param atttributes JSON (Dictionary) attribute
 *
 *  @return Comment object
 */
+ (instancetype)commentWithAttributes:(NSDictionary *)atttributes;

/**
 *  Submit a comment to a post
 *
 *  @param post_id  Which post (Unique ID)
 *  @param userInfo Comment information
 *  @param block    Called once we're done
 */
+ (void)submitCommentWithPostID:(NSUInteger)post_id andUserInfo:(NSDictionary *)userInfo inBlock:(void (^)(Comment *,NSError *))block;

@end