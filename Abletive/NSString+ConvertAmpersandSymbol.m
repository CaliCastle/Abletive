//
//  NSString+ConvertAmpersandSymbol.m
//  Abletive
//
//  Created by Cali on 6/26/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "NSString+ConvertAmpersandSymbol.h"

@implementation NSString (ConvertAmpersandSymbol)

+ (nonnull NSString *)parseString:(nullable NSString *)string {
    if (!string) {
        return @"";
    }
    NSString *parsedString = string;
    if ([parsedString containsString:@"&"]) {
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"&#8211;" withString:@"-"];
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"amp;" withString:@""];
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"&#8212;" withString:@"–"];
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"&#8212" withString:@"-"];
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"&hellip;" withString:@"..."];
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    }
    if ([parsedString containsString:@"<"] || [parsedString containsString:@">"]) {
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        parsedString = [parsedString stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    }
    return parsedString;
}

@end
