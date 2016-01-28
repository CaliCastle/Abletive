//
//  LaunchpadProject.h
//  Abletive
//
//  Created by Cali on 11/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  LaunchpadProject model
 */
@interface LaunchpadProject : NSObject

#pragma mark Properties

/**
 *  Name of the project
 */
@property (nonatomic,strong) NSString *projectName;
/**
 *  Baidu Cloud download link
 */
@property (nonatomic,strong) NSString *baiduLink;
/**
 *  Qiniu download link
 */
@property (nonatomic,strong) NSString *qiniuLink;
/**
 *  Thumbnail of the project video
 */
@property (nonatomic,strong) NSString *thumbnail;
/**
 *  Video url
 */
@property (nonatomic,strong) NSString *videoLink;
/**
 *  Original post link
 */
@property (nonatomic,strong) NSString *postLink;
/**
 *  Difficulty in Stars
 */
@property (nonatomic,assign) NSUInteger star;
/**
 *  Who made the project (name)
 */
@property (nonatomic,strong) NSString *maker;

#pragma mark Methods

/**
 *  Factory method of newing up with the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return LaunchpadProject instance
 */
+ (instancetype)launchpadProjectWithAttributes:(NSDictionary *)attributes;

/**
 *  Get projects with star
 *
 *  @param star  Star number
 *  @param block Callback block
 */
+ (void)getLaunchpadProjectsWithStar:(NSUInteger)star andBlock:(void (^)(NSArray *projects, NSError *error))block;

@end
