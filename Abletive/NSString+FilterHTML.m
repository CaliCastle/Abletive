//
//  NSString+FilterHTML.m
//  Abletive
//
//  Created by Cali on 7/7/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "NSString+FilterHTML.h"

@implementation NSString (FilterHTML)

+ (NSString *)filterHTML:(NSString *)html {
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        // Find the tag beginning
        [scanner scanUpToString:@"<" intoString:nil];
        // Find the tag ending
        [scanner scanUpToString:@">" intoString:&text];
        // Replace string
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}

+ (NSString *)filterImageTag:(NSString *)html {
    if (!html) {
        return @"";
    }
    NSString *fullAvatarPath = [html copy];
    // Get the img src
    if ([fullAvatarPath containsString:@"img src"]) {
        NSRange range = [fullAvatarPath rangeOfString:@"\"" options:NSLiteralSearch];
        fullAvatarPath = [fullAvatarPath substringFromIndex:range.location+1];
        range = [fullAvatarPath rangeOfString:@"\"" options:NSLiteralSearch];
        fullAvatarPath = [fullAvatarPath substringToIndex:range.location];
    }
    // Decode the string to url standard
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:fullAvatarPath];
    return [fullAvatarPath stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
}

@end
