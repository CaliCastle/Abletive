//
//  RootViewController.m
//  Abletive
//
//  Created by Cali on 6/17/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "RootViewController.h"
#import "SKSplashIcon.h"
#import "SKSplashView.h"
#import "TAOverlay.h"
#import "Personal Page/PersonalPageTableViewController.h"
#import "AppColor.h"
#import "PostTableViewController.h"
#import "Abletive-Swift.h"

@interface RootViewController ()<UITabBarControllerDelegate>

@property (nonatomic,strong) SKSplashView *splashView;

@end

@implementation RootViewController {
    BOOL _doubleTapped;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    // Set the tab bar icon and selected icon
    [self.tabBar.items objectAtIndex:0].image = [[UIImage imageNamed:@"post"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:0].selectedImage = [[UIImage imageNamed:@"post-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:1].image = [[UIImage imageNamed:@"chat"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:1].selectedImage = [[UIImage imageNamed:@"chat-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:2].image = [[UIImage imageNamed:@"community"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:2].selectedImage = [[UIImage imageNamed:@"community-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:3].image = [[UIImage imageNamed:@"me"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    [self.tabBar.items objectAtIndex:3].selectedImage = [[UIImage imageNamed:@"me-selected"]imageWithRenderingMode:UIImageRenderingModeAutomatic];
    
    SKSplashIcon *abletiveSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"LaunchLOGO.png"] animationType:SKIconAnimationTypeBounce];
    UIColor *bgColor = [AppColor secondaryBlack];
    _splashView = [[SKSplashView alloc] initWithSplashIcon:abletiveSplashIcon backgroundColor:bgColor animationType:SKSplashAnimationTypeNone];
    _splashView.animationDuration = 1.5;
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
    
    [self registerNotifications];
}

- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentPersonalPage) name:@"ShortcutPersonalPage" object:nil];
}

- (void)presentPersonalPage {
    PersonalPageTableViewController *personalPageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    [self.navigationController pushViewController:personalPageTVC animated:YES];
}

//
// ======= Double Tap on the Tab Bar Item, Scrolls to Top =========
//
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.tabBar.selectedItem.tag == 0) {
        if (_doubleTapped) {
            _doubleTapped = NO;
            UINavigationController *navi = (UINavigationController *)tabBarController.selectedViewController;
            PostTableViewController *postTVC = [navi.viewControllers firstObject];
            [postTVC.tableView setContentOffset:CGPointMake(0, -30) animated:YES];
            return;
        }
        _doubleTapped = YES;
        return;
    }
    _doubleTapped = NO;
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
