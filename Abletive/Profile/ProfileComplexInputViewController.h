//
//  ProfileComplexInputViewController.h
//  Abletive
//
//  Created by Cali on 10/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileComplexInputDelegate <NSObject>

- (void)textChanged:(NSString *)text;

@end


@interface ProfileComplexInputViewController : UIViewController

@property (nonatomic,weak) id <ProfileComplexInputDelegate> delegate;

@property (nonatomic,strong) NSString *defaultText;

@property (nonatomic,assign) NSUInteger inputLimit;

@end
