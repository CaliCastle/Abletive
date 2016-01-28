//
//  UserOrder.h
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserOrder : NSObject

#pragma mark Properties

/**
 *  Unique order ID (Primary Key in DB)
 */
@property (nonatomic,assign) NSUInteger orderID;
/**
 *  Created date
 */
@property (nonatomic,strong) NSString *date;
/**
 *  Name of the product
 */
@property (nonatomic,strong) NSString *productName;
/**
 *  Total price spent
 */
@property (nonatomic,strong) NSString *totalPrice;
/**
 *  Single object price
 */
@property (nonatomic,strong) NSString *singlePrice;
/**
 *  How many in this order
 */
@property (nonatomic,assign) NSUInteger quantity;
/**
 *  Current order status
 */
@property (nonatomic,strong) NSString *status;
/**
 *  Yes is spent in Cash, or else in Credit
 */
@property (nonatomic,assign) BOOL cash;

#pragma mark Methods

/**
 *  Factory Method for instantiation a UserOrder model
 *
 *  @param attributes JSON results
 *
 *  @return An instance being created
 */
+ (instancetype)userOrderWithAttributes:(NSDictionary *)attributes;

/**
 *  Send request for User's Order
 *
 *  @param userID Whose order shall we get
 *  @param page   Page index
 *  @param count  How many per page
 *  @param block  Called when the operation is done
 *
 *  @return Data task
 */
+ (NSURLSessionDataTask *)getOrdersByUserID:(NSUInteger)userID andPage:(NSUInteger)page withCount:(NSUInteger)count andBlock:(void (^)(NSArray *orders, NSError *error))block;

@end
