//
//  UserOrder.m
//  Abletive
//
//  Created by Cali on 10/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "UserOrder.h"
#import "AbletiveAPIClient.h"

@implementation UserOrder

/**
 *  Instantiate a UserOrder model
 *
 *  @param attributes JSON results
 *
 *  @return An instance being created
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    if (self = [super init]) {
        self.orderID = [attributes[@"order_id"]intValue];
        self.productName = attributes[@"product_name"];
        self.date = attributes[@"order_time"];
        self.status = attributes[@"order_status"];
        self.quantity = [attributes[@"quantity"]intValue];
        self.totalPrice = attributes[@"order_total_price"];
        self.singlePrice = attributes[@"order_price"];
        self.cash = [attributes[@"order_currency"] isEqualToString:@"credit"]?NO:YES;
    }
    return self;
}

+ (instancetype)userOrderWithAttributes:(NSDictionary *)attributes {
    return [[UserOrder alloc]initWithAttributes:attributes];
}

+ (NSURLSessionDataTask *)getOrdersByUserID:(NSUInteger)userID andPage:(NSUInteger)page withCount:(NSUInteger)count andBlock:(void (^)(NSArray *, NSError *))block {
    return [[AbletiveAPIClient sharedClient] POST:@"user/get_order_list" parameters:@{@"user_id":[NSNumber numberWithInteger:userID],@"page":[NSNumber numberWithInteger:page],@"count":[NSNumber numberWithInteger:count]} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
        if ([JSON[@"status"] isEqualToString:@"ok"]) {
            NSArray *orderList = JSON[@"order_list"];
            NSMutableArray *orders = [NSMutableArray array];
            
            for (NSDictionary *attribute in orderList) {
                UserOrder *order = [UserOrder userOrderWithAttributes:attribute];
                [orders addObject:order];
            }
            if (block) {
                block(orders,nil);
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (block) {
            block(nil,error);
        }
    }];
}

@end
