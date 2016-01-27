//
//  SettingVersionInfoViewController.m
//  Abletive
//
//  Created by Cali on 10/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "SettingVersionInfoViewController.h"
#import "KINWebBrowserViewController.h"
#import "Abletive-Swift.h"

@interface SettingVersionInfoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SettingVersionInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [NSString stringWithFormat:@"v%@ (Build %@)", [AppConfiguration versionNumber], [AppConfiguration buildNumber]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)versionInfoDidClick:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"查看版本功能" message:@"选择查看详细功能页面还是特性图" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"详细功能" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadWebPage];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"特性图" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self loadWelcomeViewController];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loadWebPage {
    KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowser];
    webBrowser.actionButtonHidden = YES;
    [self.navigationController pushViewController:webBrowser animated:YES];
    [webBrowser loadURLString:@"http://abletive.com/ios/app_versioninfo.html"];
}

- (void)loadWelcomeViewController {
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Welcome"] animated:YES completion:nil];
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
