//
//  CCDateToString.m
//  Abletive
//
//  Created by Cali on 11/29/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "CCDateToString.h"

@implementation CCDateToString

+ (NSString *)getStringFromDate:(NSString *)date {
    NSDate *today = [NSDate new];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    
    NSDate *targetDate = [dateFormatter dateFromString:date];
    
    
    dateFormatter.dateFormat = @"YYYY";
    
    NSUInteger todayYear = [[dateFormatter stringFromDate:today] integerValue];
    NSUInteger targetYear = [[dateFormatter stringFromDate:targetDate] integerValue];
    
    dateFormatter.dateFormat = @"MM";
    
    NSUInteger todayMonth = [[dateFormatter stringFromDate:today] integerValue];
    NSUInteger targetMonth = [[dateFormatter stringFromDate:targetDate] integerValue];
    
    dateFormatter.dateFormat = @"dd";
    
    NSUInteger todayDate = [[dateFormatter stringFromDate:today] integerValue];
    NSUInteger targetDay = [[dateFormatter stringFromDate:targetDate] integerValue];
    
    dateFormatter.dateFormat = @"HH";
    
    NSUInteger todayHour = [[dateFormatter stringFromDate:today] integerValue];
    NSUInteger targetHour = [[dateFormatter stringFromDate:targetDate] integerValue];
    
    dateFormatter.dateFormat = @"mm";
    
    NSUInteger todayMinute = [[dateFormatter stringFromDate:today] integerValue];
    NSUInteger targetMinute = [[dateFormatter stringFromDate:targetDate] integerValue];
    
    dateFormatter.dateFormat = @"ss";
    
    NSMutableString *dateString = [NSMutableString stringWithString:@""];
    
    if ((todayYear - targetYear) >= 1) {
        [dateString appendFormat:@"%ld年%ld月%ld日",(unsigned long)targetYear, (unsigned long)targetMonth, (unsigned long)targetDay];
    } else {
        if ((todayMonth - targetMonth) >= 1) {
            [dateString appendFormat:@"%ld月%ld日 %@:%@",(unsigned long)targetMonth, (unsigned long)targetDay, targetHour >= 10 ? [NSNumber numberWithInteger:targetHour] : [NSString stringWithFormat:@"0%ld",(unsigned long)targetHour], targetMinute >= 10 ? [NSNumber numberWithInteger:targetMinute] : [NSString stringWithFormat:@"0%ld",(unsigned long)targetMinute]];
        } else {
            if ((todayDate - targetDay) == 1) {
                [dateString appendFormat:@"昨天 %@:%@",targetHour >= 10 ? [NSNumber numberWithInteger:targetHour] : [NSString stringWithFormat:@"0%ld",(unsigned long)targetHour], targetMinute >= 10 ? [NSNumber numberWithInteger:targetMinute] : [NSString stringWithFormat:@"0%ld",(unsigned long)targetMinute]];
            } else if ((todayDate - targetDay) == 2) {
                [dateString appendFormat:@"前天 %@:%@",targetHour >= 10 ? [NSNumber numberWithInteger:targetHour] : [NSString stringWithFormat:@"0%ld",(unsigned long)targetHour], targetMinute >= 10 ? [NSNumber numberWithInteger:targetMinute] : [NSString stringWithFormat:@"0%ld",(unsigned long)targetMinute]];
            } else if ((todayDate - targetDay) >= 3) {
                [dateString appendFormat:@"%ld天前 %@:%@",(unsigned long)(todayDate - targetDay),targetHour >= 10 ? [NSNumber numberWithInteger:targetHour] : [NSString stringWithFormat:@"0%ld",(unsigned long)targetHour], targetMinute >= 10 ? [NSNumber numberWithInteger:targetMinute] : [NSString stringWithFormat:@"0%ld",(unsigned long)targetMinute]];
            } else {
                if ((todayHour - targetHour) >= 1) {
                    [dateString appendFormat:@"%ld小时前",(unsigned long)(todayHour - targetHour)];
                } else {
                    if ((todayMinute - targetMinute) >= 1) {
                        [dateString appendFormat:@"%ld分钟前",(unsigned long)(todayMinute - targetMinute)];
                    } else {
                        [dateString appendString:@"刚刚"];
                    }
                }
            }
        }
    }
    
    return dateString;
}

+ (NSString *)getStringFromNSDate:(NSDate *)date {
    return @"";
}

@end
