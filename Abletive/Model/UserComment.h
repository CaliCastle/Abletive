//
//  UserComment.h
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  UserComment model
 */
@interface UserComment : NSObject

#pragma mark Properties

/**
 *  Of which post
 */
@property (nonatomic,assign) NSUInteger postID;

/**
 *  Comment identifier
 */
@property (nonatomic,assign) NSUInteger commentID;

/**
 *  Comment datetime
 */
@property (nonatomic,strong) NSString *commentDate;

/**
 *  Comment content (HTML)
 */
@property (nonatomic,strong) NSString *content;

/**
 *  Is from iOS app
 */
@property (nonatomic,assign) BOOL isFromApp;

/**
 *  Post's title
 */
@property (nonatomic,strong) NSString *postTitle;


#pragma mark Methods

/**
 *  Factory method of newing up by the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return UserComment instance
 */
+ (instancetype)userCommentWithAttributes:(NSDictionary *)attributes;

@end
