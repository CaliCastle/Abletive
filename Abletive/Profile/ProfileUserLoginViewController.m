//
//  ProfileUserLoginViewController.m
//  Abletive
//
//  Created by Cali on 10/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ProfileUserLoginViewController.h"
#import "STPopup.h"
#import "AppColor.h"

@interface ProfileUserLoginViewController ()

@end

@implementation ProfileUserLoginViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 100, 100);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 150, 100);
    self.title = NSLocalizedString(@"用户名说明", nil);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [AppColor mainBlack];
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
