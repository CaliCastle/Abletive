//
//  NotificationViewController.m
//  Abletive
//
//  Created by Cali on 6/17/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "NotificationViewController.h"

@interface NotificationViewController ()

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set the tab bar icon and selected icon
    [self.tabBar.items objectAtIndex:0].image = [[UIImage imageNamed:@"reply"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:0].selectedImage = [[UIImage imageNamed:@"reply-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:1].image = [[UIImage imageNamed:@"friend-request"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:1].selectedImage = [[UIImage imageNamed:@"friend-request-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
