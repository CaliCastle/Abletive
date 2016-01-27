//
//  AbletiveAPIClient.h
//  Abletive
//
//  Created by Cali on 6/24/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface AbletiveAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
