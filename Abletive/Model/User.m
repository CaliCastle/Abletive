//
//  User.m
//  Abletive
//
//  Created by Cali on 6/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "User.h"
#import "AbletiveAPIClient.h"
#import "NSString+FilterHTML.h"
#import "AFHTTPRequestOperationManager.h"

@implementation User

- (instancetype)initWithShortAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.userID = [attributes[@"id"]integerValue];
        self.name = attributes[@"name"]?attributes[@"name"]:attributes[@"displayname"];
        self.aboutMe = attributes[@"description"];
        
        self.avatarPath = [NSString filterImageTag:attributes[@"avatar"]];
        
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

+ (void)getUserinfoWithID:(NSUInteger)userID andBlock:(void (^)(User * _Nullable, NSError * _Nullable))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/get_userinfo" parameters:@{@"user_id":[NSNumber numberWithInteger:userID]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if (block && ![JSON[@"id"] isKindOfClass:[NSNull class]]) {
                User *userInfo = [User userWithAttributes:JSON];
                block(userInfo,nil);
            } else {
                block(nil,[NSError new]);
            }
        } else {
            block(nil, [NSError new]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)getUserAvatarPathWithID:(NSUInteger)identification andBlock:(void (^)(NSString *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/get_avatar" parameters:@{@"user_id":[NSString stringWithFormat:@"%lu",(unsigned long)identification],@"type":@"full"} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            // Succeed
            NSString *fullAvatarPath = JSON[@"avatar"];
            // Get the img src
            if ([fullAvatarPath containsString:@"img src"]) {
                NSRange range = [fullAvatarPath rangeOfString:@"\"" options:NSLiteralSearch];
                fullAvatarPath = [fullAvatarPath substringFromIndex:range.location+1];
                range = [fullAvatarPath rangeOfString:@"\"" options:NSLiteralSearch];
                fullAvatarPath = [fullAvatarPath substringToIndex:range.location];
            }
            // Decode the string to url standard
            NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:fullAvatarPath];
            fullAvatarPath = [fullAvatarPath stringByAddingPercentEncodingWithAllowedCharacters:characterSet];

            if (block) {
                block(fullAvatarPath,nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(@"",error);
        }
    }];
}


+ (NSURLSessionDataTask *)getPersonalPageDetailWithUserID:(NSUInteger)userID andCurrentUserID:(NSUInteger)currentUserID andBlock:(void (^)(NSDictionary *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/get_personal_page_detail" parameters:@{@"user_id":[NSNumber numberWithInteger:userID],@"current_user_id":[NSNumber numberWithInteger:currentUserID]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if (block) {
                block([NSDictionary dictionaryWithDictionary:JSON],nil);
            }
        } else {
            if (block) {
                block(nil,nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)followUserToWhom:(NSUInteger)followUserID withCurrentUserID:(NSUInteger)currentUserID toFollow:(BOOL)isFollow andBlock:(void (^)(BOOL,NSDictionary *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/follow_act" parameters:@{@"followed":[NSNumber numberWithInteger:followUserID],@"user_id":[NSNumber numberWithInteger:currentUserID],@"act":isFollow?@"follow":@"unfollow"}  success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if (block) {
                block([JSON[@"success"]integerValue] == 1,JSON,nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(NO,nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)getFollowListByUserID:(NSUInteger)userID andType:(NSString *)type withPage:(NSUInteger)page forCountPerPage:(NSUInteger)count andBlock:(void (^)(NSDictionary *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/get_follow_list" parameters:@{@"user_id":[NSNumber numberWithInteger:userID],@"current_user_id":[[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]?[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]:@0,@"type":type,@"page":[NSNumber numberWithInteger:page],@"count":[NSNumber numberWithInteger:count]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if (block) {
                block(JSON,nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)dailyCheckIn:(NSUInteger)userID andBlock:(void (^)(NSDictionary *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/daily_checkin" parameters:@{@"user_id":[NSNumber numberWithInteger:userID]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if (block) {
                block(JSON, nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)getCommentListByUserID:(NSUInteger)userID andPage:(NSUInteger)page withCount:(NSUInteger)count andBlock:(void (^)(NSArray *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/get_comment_list" parameters:@{@"user_id":[NSNumber numberWithInteger:userID],@"current_user_id":[[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]?[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]:@0,@"page":[NSNumber numberWithInteger:page],@"count":[NSNumber numberWithInteger:count]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if (block) {
                NSMutableArray *commentList = [NSMutableArray array];
                for (NSDictionary *commentAttribute in JSON[@"comment_list"]) {
                    UserComment *comment = [UserComment userCommentWithAttributes:commentAttribute];
                    [commentList addObject:comment];
                }
                block(commentList,nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

+ (NSURLSessionDataTask *)collectPostByPostID:(NSUInteger)postID forRemove:(BOOL)remove andBlock:(void (^)(BOOL,BOOL))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/collect" parameters:@{@"post_id":[NSNumber numberWithInteger:postID],@"user_id":[[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]?[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]:@0,@"act":remove?@"remove":@"add"} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if (block && !JSON[@"collected"]) {
                block(YES,NO);
            } else {
                block(YES,YES);
            }
        } else {
            if (block) {
                block(NO,NO);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(NO,NO);
        }
    }];
}

+ (NSURLSessionDataTask *)likePostByPostID:(NSUInteger)postID andBlock:(void (^)(BOOL, BOOL,NSUInteger))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/like_post" parameters:@{@"pid":[NSNumber numberWithInteger:postID],@"user_id":[[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]?[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]:@0} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            block(YES,NO,[JSON[@"credit"] intValue]);
        } else {
            if (block) {
                block(NO,NO,0);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(NO,NO,0);
        }
    }];
}

+ (NSURLSessionDataTask *)getCurrentUserProfileInBlock:(void (^)(NSDictionary *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/get_user_profile" parameters:@{@"user_id":[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]intValue]]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSMutableDictionary *userDefaults = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]];
            [userDefaults addEntriesFromDictionary:@{@"public_info":JSON[@"public_info"],@"social_info":JSON[@"social_info"],@"private_info":JSON[@"private_info"]}];
            [[NSUserDefaults standardUserDefaults] setObject:userDefaults forKey:@"user"];

            if (block) {
                block(@{@"public":JSON[@"public_info"],@"social":JSON[@"social_info"],@"private":JSON[@"private_info"]},nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

+ (NSURLSessionDataTask *)updateCurrentUserProfileWithAttributes:(NSDictionary *)attributes andBlock:(void (^)(BOOL,NSString *))block {
    return [[AbletiveAPIClient sharedClient] GET:@"user/update_user_profile" parameters:attributes success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if ([JSON[@"update_status"] intValue] == 1) {
                block(YES,JSON[@"message"]);
            } else {
                block(NO,JSON[@"message"]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,nil);
    }];
}

+ (NSURLSessionDataTask *)updateCurrentUserPassword:(NSString *)password1 andPassword2:(NSString *)password2 andBlock:(void (^)(BOOL, NSString *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/update_user_password" parameters:@{@"user_id":[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]intValue]],@"pass1":password1,@"pass2":password2} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if ([JSON[@"update_status"]intValue] == 1) {
                block(YES,JSON[@"message"]);
            } else {
                block(NO,JSON[@"message"]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO, nil);
    }];
}

+ (void)updateCurrentUserAvatar:(NSData *)data andBlock:(void (^ _Nonnull)(BOOL success,NSString * _Nonnull message,  NSString * _Nullable avatarURL))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/update_user_avatar" parameters:@{@"user_id":[NSNumber numberWithInt:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]intValue]]} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"avatar" fileName:@"avatar.png" mimeType:@"image/png"];
    } success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            block(([JSON[@"update_status"] intValue] == 1),JSON[@"message"],JSON[@"avatar"]);
        } else {
            block(NO,@"",nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(NO,@"请重试",nil);
    }];
}

+ (void)getCurrentUserMembership:(void (^)(BOOL))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/membership" parameters:@{@"user_id":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            if ([JSON[@"member"][@"user_type"] containsString:@"过期"] || [JSON[@"member"][@"user_type"] containsString:@"非"]) {
                block(YES);
            } else {
                block(NO);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        block(YES);
    }];
}

+ (void)getFriendshipRequestInBlock:(void (^)(NSArray * _Nullable, NSError * _Nullable))block {
    [[AbletiveAPIClient sharedClient] POST:@"user/get_friends_list" parameters:@{@"type":@"unaccepted",@"passphrase":@"AbletiveiOSPassphrase",@"user_id":[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            
        } else {
            if (block) {
                block(nil,[NSError new]);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

@end
