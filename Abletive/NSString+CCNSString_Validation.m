//
//  NSString+CCNSString_Validation.m
//  Abletive
//
//  Created by Cali on 10/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "NSString+CCNSString_Validation.h"

@implementation NSString (CCNSString_Validation)

- (BOOL)isEmailAddress:(NSString*)email {
    
    NSString *emailRegex = @"^\\w+((\\-\\w+)|(\\.\\w+))*@[A-Za-z0-9]+((\\.|\\-)[A-Za-z0-9]+)*.[A-Za-z0-9]+$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
    
}

- (BOOL)isQQNumber:(NSString *)qqNum {
    NSString *qqRegex = @"^[0-9]*$";
    NSPredicate *qqTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", qqRegex];
    return [qqTest evaluateWithObject:qqNum];
}

- (BOOL)isURL:(NSString *)url {
    NSString *urlRegex = @"^(http|https)\\://([a-zA-Z0-9]([a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])?\\.)+[a-zA-Z]{2,6}$";
    NSPredicate *urlTest1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];

    urlRegex = @"(http|ftp|https):\\/\\/[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~\\+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?";
    NSPredicate *urlTest2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    
    return [urlTest1 evaluateWithObject:url] || [urlTest2 evaluateWithObject:url];
}
@end
