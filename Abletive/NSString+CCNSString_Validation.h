//
//  NSString+CCNSString_Validation.h
//  Abletive
//
//  Created by Cali on 10/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CCNSString_Validation)

- (BOOL)isEmailAddress:(NSString *)email;
- (BOOL)isQQNumber:(NSString *)qqNum;
- (BOOL)isURL:(NSString *)url;

@end
