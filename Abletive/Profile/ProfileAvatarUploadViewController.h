//
//  ProfileAvatarUploadViewController.h
//  Abletive
//
//  Created by Cali on 10/20/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileAvatarUploadDelegate <NSObject>

- (void)avatarChanged:(UIImage *)avatar;

@end

@interface ProfileAvatarUploadViewController : UIViewController

@property (nonatomic,weak) id<ProfileAvatarUploadDelegate> delegate;

@end
