//
//  Team.h
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Team model
 */
@interface Team : NSObject

#pragma mark Properties

/**
 *  Team member name
 */
@property (nonatomic,strong) NSString *name;

/**
 *  Member avatar path
 */
@property (nonatomic,strong) NSString *avatarPath;

/**
 *  Member's about me
 */
@property (nonatomic,strong) NSString *aboutMe;

/**
 *  Member's position
 */
@property (nonatomic,strong) NSString *position;

/**
 *  Member's background color if assigned
 */
@property (nonatomic,strong) UIColor *backgroundColor;

#pragma mark Methods

/**
 *  All team members
 *
 *  @return NSArray
 */
+ (NSArray *)allTeamMembers;

@end
