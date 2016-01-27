//
//  AbletiveAPIClient.m
//  Abletive
//
//  Created by Cali on 6/24/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "AbletiveAPIClient.h"

static NSString * const AbletiveAPIBaseURLString = @"http://abletive.com/api/";

@implementation AbletiveAPIClient

+ (instancetype)sharedClient {
    static AbletiveAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AbletiveAPIClient alloc]initWithBaseURL:[NSURL URLWithString:AbletiveAPIBaseURLString]];
//        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    
    return _sharedClient;
}

@end
