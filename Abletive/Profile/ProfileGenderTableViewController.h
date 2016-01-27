//
//  ProfileGenderTableViewController.h
//  Abletive
//
//  Created by Cali on 10/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfile.h"

@protocol ProfileGenderDelegate <NSObject>

- (void)genderChanged:(UserGenderType)gender;

@end

@interface ProfileGenderTableViewController : UITableViewController

@property (nonatomic,assign) UserGenderType gender;

@property (nonatomic,weak) id<ProfileGenderDelegate> delegate;

@end
