//
//  UIView+MJAlertView.h
//  MJAlertView
//
//  Created by Mayur on 2/16/15.
//  Copyright (c) 2015 Persource. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,MJAlertViewStyle){
    MJAlertViewError,
    MJAlertViewWarning,
    MJAlertViewSuccess
};

@interface UIView (MJAlertView)

+ (void) addMJNotifierWithText : (NSString* ) text andStyle : (MJAlertViewStyle) style dismissAutomatically : (BOOL) shouldDismiss;
+ (void) dismissMJNotifier;

@end
