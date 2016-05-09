//
//  ScreenCastRootViewController.m
//  Abletive
//
//  Created by Cali Castle on 3/1/16.
//  Copyright © 2016 CaliCastle. All rights reserved.
//

#import "ScreenCastRootViewController.h"

@interface ScreenCastRootViewController ()

@end

@implementation ScreenCastRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBar.items objectAtIndex:0].image = [[UIImage imageNamed:@"v-index"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:0].selectedImage = [[UIImage imageNamed:@"v-index-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:1].image = [[UIImage imageNamed:@"v-skill"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:1].selectedImage = [[UIImage imageNamed:@"v-skill-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:2].image = [[UIImage imageNamed:@"v-me"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:2].selectedImage = [[UIImage imageNamed:@"v-me-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchDidClick)];
}

- (void)searchDidClick {
    NSLog(@"..");
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
