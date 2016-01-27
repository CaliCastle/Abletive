//
//  User.m
//  Abletive
//
//  Created by Cali on 6/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithShortAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.userID = [attributes[@"id"]integerValue];
        self.name = attributes[@"name"]?attributes[@"name"]:attributes[@"displayname"];
        self.aboutMe = attributes[@"description"];
        
        self.avatarPath = attributes[@"avatar"];
        
        if ([attributes[@"membership"] isEqualToString:@"过期会员"]) {
            self.membership = UserMembershipTypeExpired;
        } else if ([attributes[@"membership"] isEqualToString:@"年费会员"]) {
            self.membership = UserMembershipTypeYearly;
        } else if ([attributes[@"membership"] isEqualToString:@"季费会员"]) {
            self.membership = UserMembershipTypeSeasonly;
        } else if ([attributes[@"membership"] isEqualToString:@"月费会员"]) {
            self.membership = UserMembershipTypeMonthly;
        } else if ([attributes[@"membership"] isEqualToString:@"终身会员"]) {
            self.membership = UserMembershipTypeEternal;
        } else {
            self.membership = UserMembershipTypeNone;
        }
        
        if ([attributes[@"gender"] isEqualToString:@"male"]) {
            self.gender = UserGenderMale;
        } else if ([attributes[@"gender"] isEqualToString:@"female"]){
            self.gender = UserGenderFemale;
        } else {
            self.gender = UserGenderOther;
        }
    }
    return self;
}

+ (instancetype)userWithAttributes:(NSDictionary *)attributes {
    return [[User alloc]initWithShortAttributes:attributes];
}

@end
