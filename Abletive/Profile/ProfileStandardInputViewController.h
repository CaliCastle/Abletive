//
//  ProfileStandardInputViewController.h
//  Abletive
//
//  Created by Cali on 10/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileStandardInputDelegate <NSObject>

- (void)textChanged:(NSString *)text;

@end

@interface ProfileStandardInputViewController : UIViewController

@property (nonatomic,weak) id<ProfileStandardInputDelegate> delegate;

@property (nonatomic,assign) NSUInteger inputLimit;

@property (nonatomic,strong) NSString *defaultText;

@property (nonatomic,assign) BOOL isEmail;

@property (nonatomic,assign) BOOL isNumeric;

@end
