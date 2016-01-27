//
//  Team.h
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Team : NSObject

@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) NSString *avatarPath;

@property (nonatomic,strong) NSString *aboutMe;

@property (nonatomic,strong) NSString *position;

@property (nonatomic,strong) UIColor *backgroundColor;

+ (NSArray *)allTeamMembers;

@end
