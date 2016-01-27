//
//  MrLoadingView.h
//  MrLoadingView
//
//  Created by ChenHao on 2/11/15.
//  Copyright (c) 2015 xxTeam. All rights reserved.
//  Modified by Cali on 18/06/15.

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HHAlertButton)
{
    HHAlertButtonOk,
    HHAlertButtonCancel
};

typedef NS_ENUM(NSInteger, HHAlertStyle)
{
    HHAlertStyleDefault,
    HHAlertStyleOk,
    HHAlertStyleError,
    HHAlertStyleWarning,
};

typedef void (^selectButton)(HHAlertButton buttonindex);


@protocol HHAlertViewDelegate <NSObject>


@optional
/**
 *  the delegate to tell user whitch button is clicked
 *
 *  @param button button
 */
- (void)didClickButtonAnIndex:(HHAlertButton )button;

@end


@interface HHAlertView : UIView

/**
 *  the singleton of the calss
 *
 *  @return the sington
 */
+ (instancetype)shared;

/**
 *  dismiss the alertview
 */
+ (void)Hide;

/**
 *  show the alertview and use delegate to know which button is clicked
 *
 *  @param HHAlertStyle style
 *  @param view         view
 *  @param title        title
 *  @param detail       etail
 *  @param cancel       cancelButtonTitle
 *  @param ok           okButtonTitle
 */
+ (void)showAlertWithStyle:(HHAlertStyle )HHAlertStyle
                    inView:(UIView *)view
                     Title:(NSString *)title
                    detail:(NSString *)detail
              cancelButton:(NSString *)cancel
                  Okbutton:(NSString *)ok;


/**
 *  show the alertview and use Block to know which button is clicked
 *
 *  @param HHAlertStyle style
 *  @param view         view
 *  @param title        title
 *  @param detail       etail
 *  @param cancel       cancelButtonTitle
 *  @param ok           okButtonTitle
 */
+ (void)showAlertWithStyle:(HHAlertStyle)HHAlertStyle
                    inView:(UIView *)view
                     Title:(NSString *)title
                    detail:(NSString *)detail
              cancelButton:(NSString *)cancel
                  Okbutton:(NSString *)ok
                     block:(selectButton)block;

@property (nonatomic, weak) id<HHAlertViewDelegate> delegate;

@end
