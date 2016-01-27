//
//  NSString+FilterHTML.h
//  Abletive
//
//  Created by Cali on 7/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FilterHTML)

+ (NSString *)filterHTML:(NSString *)html;
+ (NSString *)filterImageTag:(NSString *)html;

@end
