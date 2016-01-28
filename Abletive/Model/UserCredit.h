//
//  UserCredit.h
//  Abletive
//
//  Created by Cali on 10/17/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbletiveAPIClient.h"

@interface UserCredit : NSObject

#pragma mark Properties

/**
 * The date of the credit being operated
 */
@property (nonatomic,strong) NSString *date;
/**
 *  The detail content of the credit
 */
@property (nonatomic,strong) NSString *content;

#pragma mark Methods

/**
 *  Factory Method for Instantiation
 *
 *  @param attributes JSON results
 *
 *  @return A model instance being created
 */
+ (instancetype)userCreditWithAttributes:(NSDictionary *)attributes;

/**
 *  Get User's Credit log list
 *
 *  @param userID Whose credit shall we get
 *  @param page   Page index
 *  @param count  How many per page
 *  @param block  Called once we're done getting
 *
 *  @return Data task
 */
+ (NSURLSessionDataTask *)getUserCreditWithUserID:(NSUInteger)userID andPage:(NSUInteger)page withCount:(NSUInteger)count andBlock:(void (^)(NSArray *credits,NSError *error))block;

@end
