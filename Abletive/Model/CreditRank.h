//
//  CreditRank.h
//  Abletive
//
//  Created by Cali Castle on 1/16/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  CreditRank model
 */
@interface CreditRank : NSObject

#pragma mark Properties

/**
 *  User's name
 */
@property (nonatomic,strong) NSString * _Nonnull name;

/**
 *  User's avatar
 */
@property (nonatomic,strong) NSString * _Nonnull avatarURL;

/**
 *  User's credit
 */
@property (nonatomic,strong) NSString * _Nonnull credit;

/**
 *  User's ID
 */
@property (nonatomic,assign) NSUInteger userID;

#pragma mark Methods

/**
 *  Factory method of newing up with the given attributes
 *
 *  @param attributes NSDictionary
 *
 *  @return CreditRank instance
 */
+ (_Nonnull instancetype)creditRankWithAttributes:(NSDictionary * _Nonnull )attributes;

/**
 *  Get credit rank
 *
 *  @param limit Limits
 *  @param block Callback block
 */
+ (void)getCreditRankWithLimit:(NSInteger)limit andBlock:(void (^ _Nonnull)(NSArray *_Nullable rankList))block;

@end
