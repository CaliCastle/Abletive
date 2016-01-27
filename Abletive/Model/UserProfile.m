//
//  UserProfile.m
//  Abletive
//
//  Created by Cali on 10/11/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.displayName = attributes[@"user_info"][@"display_name"];
        self.userID = [attributes[@"membership"][@"user_id"]unsignedIntegerValue];
        self.postsCount = attributes[@"posts_count"];
        self.commentsCount = attributes[@"comments_count"];
        self.collectionCount = attributes[@"collects_count"];
        self.credit = [attributes[@"credit"]unsignedIntegerValue];
        self.registeredDays = attributes[@"registered_days"];
        self.email = attributes[@"user_info"][@"user_email"];
        self.url = attributes[@"user_info"][@"user_url"]?attributes[@"user_info"][@"user_url"]:@"";
        self.membership = attributes[@"membership"];
        self.ordersCount = attributes[@"orders_count"];
        
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

+ (instancetype)userProfileWithAttributes:(NSDictionary *)attributes {
    return [[UserProfile alloc]initWithAttributes:attributes];
}

@end
