//
//  NSString+CCNSStringReverse.m
//  Abletive
//
//  Created by Cali Castle on 1/13/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import "NSString+CCNSStringReverse.h"

@implementation NSString (CCNSStringReverse)

- (NSString *)reverse {
    NSUInteger length = [self length];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:length];
    
    for(long i=length-1; i>=0; i--) {
        unichar c = [self characterAtIndex:i];
        [array addObject:[NSString stringWithFormat:@"%c",c]];
    }
    
    NSMutableString *str = [NSMutableString stringWithCapacity:length];
    
    for(int i=0; i<=length-1; i++) {
        [str appendString:array[i]];
    }
    
    return str;
}

@end
