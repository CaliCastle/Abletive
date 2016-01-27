//
//  NSString+FullImagePath.m
//  Abletive
//
//  Created by Cali on 6/26/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "NSString+FullImagePath.h"

@implementation NSString (FullImagePath)

+ (NSString *)getFullImagePathWithThumbnail:(NSString *)thumbnailPath {
    if ([thumbnailPath containsString:@"-75x75"]) {
        NSRange range = [thumbnailPath rangeOfString:@"-75x75"];
        NSString *fullPath = [thumbnailPath substringToIndex:range.location];
        fullPath = [fullPath stringByAppendingPathExtension:[thumbnailPath pathExtension]];
        return fullPath;
    }
    else
        return thumbnailPath;
}

@end
