//
//  CreditRank.h
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreditRank : NSObject

@property (nonatomic,strong) NSString * _Nonnull name;

@property (nonatomic,strong) NSString * _Nonnull avatarURL;

@property (nonatomic,strong) NSString * _Nonnull credit;

@property (nonatomic,assign) NSUInteger userID;

+ (_Nonnull instancetype)creditRankWithAttributes:(NSDictionary * _Nonnull )attributes;

+ (void)getCreditRankWithLimit:(NSInteger)limit andBlock:(void (^ _Nonnull)(NSArray *_Nullable rankList))block;

@end
