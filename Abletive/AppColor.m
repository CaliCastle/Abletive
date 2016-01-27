//
//  AppColor.m
//  Abletive
//
//  Created by Cali on 6/15/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "AppColor.h"

@implementation AppColor

+ (UIColor *)mainBlack {
    return [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
}

+ (UIColor *)mainYellow {
    return [UIColor colorWithRed:1.0 green:0.69 blue:0 alpha:1];
}

+ (UIColor *)mainWhite {
    return [UIColor colorWithWhite:1 alpha:1];
}

+ (UIColor *)mainRed {
    return [UIColor colorWithRed:200/255.0 green:20/255.0 blue:10/255.0 alpha:1];
}

+ (UIColor *)secondaryBlack {
    return [UIColor colorWithRed:0.19 green:0.19 blue:0.19 alpha:1];
}

+ (UIColor *)secondaryWhite {
    return [UIColor colorWithRed:0.82 green:0.9 blue:0.84 alpha:1];
}

+ (UIColor *)transparent {
    return [UIColor clearColor];
}

+ (UIColor *)darkTranslucent {
    return [UIColor colorWithWhite:0 alpha:0.3];
}

+ (UIColor *)lightTranslucent {
    return [UIColor colorWithWhite:1 alpha:0.3];
}

+ (UIColor *)loginButtonColor {
    return [UIColor colorWithRed:218/255.0 green:139/255.0 blue:0 alpha:1];
}

+ (UIColor *)registerButtonColor {
    return [UIColor colorWithRed:0 green:149/255.0 blue:222/255.0 alpha:1];
}

+ (UIColor *)darkOverlay {
    return [UIColor colorWithWhite:0.0f alpha:0.7f];
}

+ (UIColor *)lightSeparator {
    return [UIColor colorWithWhite:1 alpha:0.15];
}

+ (UIColor *)darkSeparator {
    return [UIColor colorWithWhite:0 alpha:0.15];
}

@end
