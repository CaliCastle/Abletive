//
//  LaunchpadProject.h
//  Abletive
//
//  Created by Cali on 11/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaunchpadProject : NSObject
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

+ (instancetype)launchpadProjectWithAttributes:(NSDictionary *)attributes;

+ (void)getLaunchpadProjectsWithStar:(NSUInteger)star andBlock:(void (^)(NSArray *projects, NSError *error))block;

@end
