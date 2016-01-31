//
//  AppDelegate.m
//  Abletive
//
//  Created by Cali on 6/13/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "AppDelegate.h"
#import "AppColor.h"

// ====== Share SDK header =======
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

// Post search for Shortcut Item
#import "PostSearchResultsController.h"

// Personal page for Shortcut Item
#import "Personal Page/PersonalPageTableViewController.h"
#import "SinglePostTableViewController.h"
#import "ChatMessageTableViewController.h"
#import "QRCodeViewController.h"

#import "TAOverlay.h"

#import "User.h"
#import "PushNotification.h"
#import "CCQRCodeImage.h"

#import "Abletive-Swift.h"

#import <WatchConnectivity/WatchConnectivity.h>

// ====== Predefined ========
#define SHARESDK_APP_KEY @"adf97e60feda"
#define SHARESDK_APP_SECRET @"2b62a0786163f34286dc5a95978d6e19"

#define APNS_PASSPHRASE @"AbletiveiOSAPNS"

#define IOS_VERSION_9_OR_ABOVE (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)? (YES): (NO))

static NSString * const todayActionPrefix = @"abletive://today_click/";
static NSString * const userPagePrefix = @"abletive://user/";

typedef NS_ENUM(NSUInteger, ThemeType){
    ThemeTypeDefault,
    ThemeTypeLight
};

@interface AppDelegate () <WCSessionDelegate>

@property UIApplicationShortcutItem *launchedShortcutItem;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if (application.applicationIconBadgeNumber) {
        application.applicationIconBadgeNumber = 0;
    }
    
    if (launchOptions != nil){
        NSDictionary *remoteDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (remoteDictionary != nil){
            NSLog(@"Launched from push notification: %@", remoteDictionary);
            
            NSDictionary *notification = remoteDictionary[@"aps"];
            if (notification[@"new_post"]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UITabBarController *baseController = (UITabBarController *)self.window.rootViewController;
                    SinglePostTableViewController *singlePostTVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
                    singlePostTVC.postID = [notification[@"new_post"] intValue];
                    [baseController.selectedViewController pushViewController:singlePostTVC animated:YES];
                });
            }
            if (notification[@"new_comment"]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    UITabBarController *baseController = (UITabBarController *)self.window.rootViewController;
                    SinglePostTableViewController *singlePostTVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
                    singlePostTVC.postID = [notification[@"new_comment"] intValue];
                    [baseController.selectedViewController pushViewController:singlePostTVC animated:YES];
                });
            }
            
        }
        NSDictionary *localDictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (localDictionary != nil) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UITabBarController *baseController = (UITabBarController *)self.window.rootViewController;
                [baseController.selectedViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:[baseController.storyboard instantiateViewControllerWithIdentifier:@"CheckIn"]] animated:YES completion:nil];
            });
        }
    }
    
    if (IOS_VERSION_9_OR_ABOVE) {
        // Available only in iOS 9 or above
        // ==== IMPORTANT ====
        NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults]objectForKey:@"user"];
        UIMutableApplicationShortcutItem *shortcutItemDynamic = nil;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"3DTouchCheckInEnabled"]) {
             shortcutItemDynamic = [[UIMutableApplicationShortcutItem alloc]initWithType:@"CheckIn" localizedTitle:@"签到" localizedSubtitle:@"一键快速签到" icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"checkin"] userInfo:nil];
        } else {
             shortcutItemDynamic = [[UIMutableApplicationShortcutItem alloc]initWithType:@"Settings" localizedTitle:@"设置" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"setting"] userInfo:nil];
        }
        
        UIMutableApplicationShortcutItem *shortcutItemCommunity = [[UIMutableApplicationShortcutItem alloc]initWithType:@"ScanQRCode" localizedTitle:@"扫二维码" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"scan-qrcode"] userInfo:nil];
        UIMutableApplicationShortcutItem *shortcutItemMe = [[UIMutableApplicationShortcutItem alloc]initWithType:@"Me" localizedTitle:@"个人主页" localizedSubtitle:userInfo?[NSString stringWithFormat:@"%@的主页",userInfo[@"displayname"]]:@"登录后查看" icon:[UIApplicationShortcutIcon iconWithTemplateImageName:@"me"] userInfo:nil];
        application.shortcutItems = @[shortcutItemDynamic,shortcutItemCommunity,shortcutItemMe];
    }
    
    // Setup theme
    [self setupTheme];
    // Register for Notifications
    [self registerForNotifications];
    
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstTimeLaunch"]) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstTimeLaunch"];
        // TODO: Load welcome screens at the first time
        
    }
    
    /**
     *  Get user's membership info
     */
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        [User getCurrentUserMembership:^(BOOL hasExpired) {
            if (!hasExpired) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsVIP"];
            } else {
                if ([[NSUserDefaults standardUserDefaults]boolForKey:@"IsVIP"]) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"IsVIP"];
                }
            }
        }];
    }
    /**
     *  Track how many times the user has opened the app
     */
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"LaunchTimes"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"LaunchTimes"];
    } else {
        NSNumber *launchTimes = [[NSUserDefaults standardUserDefaults]objectForKey:@"LaunchTimes"];
        launchTimes = [NSNumber numberWithInteger:[launchTimes integerValue]+1];
        [[NSUserDefaults standardUserDefaults] setObject:launchTimes forKey:@"LaunchTimes"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupTheme) name:@"themeChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn) name:@"User_Login" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut) name:@"User_Logout" object:nil];
    
    // If WatchConnectivity Session supported, turn it on for message receiving
    if (IOS_VERSION_9_OR_ABOVE) {
        if ([WCSession isSupported] && [WCSession defaultSession].isPaired && [WCSession defaultSession].isWatchAppInstalled) {
            WCSession *session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
        }
    }
    
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个参数用于指定要使用哪些社交平台，以数组形式传入。第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:SHARESDK_APP_KEY
          activePlatforms:@[@(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeMail),
                            @(SSDKPlatformTypeSMS),
                            @(SSDKPlatformTypeCopy),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType) {
                      // TODO:
                  case SSDKPlatformTypeSinaWeibo:
                      [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
                                                appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                                              redirectUri:@"http://www.sharesdk.cn"
                                                 authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:@"wx4868b35061f87885"
                                            appSecret:@"64020361b8ec4c99936c0e3999a9f249"];
                      break;
                  case SSDKPlatformTypeQQ:
                      [appInfo SSDKSetupQQByAppId:@"100371282"
                                           appKey:@"aed9b0303e3ed1e27bae87c33761161d"
                                         authType:SSDKAuthTypeBoth];
                      break;

                  default:
                      break;
              }
          }];
    
    return YES;
}

/*
 * Handle the message that comes from watchOS
 */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    if ([message objectForKey:@"fetchUserDefaults"]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"YYYYMMdd"];
        NSString *checkedDate = [[NSUserDefaults standardUserDefaults] stringForKey:@"daily_checkin"]?[[NSUserDefaults standardUserDefaults] stringForKey:@"daily_checkin"]:@"";
        BOOL hasCheckedIn = [checkedDate isEqualToString:[dateFormatter stringFromDate:[NSDate date]]];
        
        NSMutableDictionary *replies = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]];
        replies[@"avatar"] = [[NSUserDefaults standardUserDefaults]stringForKey:@"user_avatar_path"] ? [NSURL URLWithString:[[NSUserDefaults standardUserDefaults]stringForKey:@"user_avatar_path"]].absoluteString : @"";
        replies[@"hasSignedIn"] = [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"user_is_logged"]];
        replies[@"hasCheckedIn"] = [NSNumber numberWithBool:hasCheckedIn];
        replyHandler(replies);
    } else if ([message objectForKey:@"checkIn"]) {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
            [User dailyCheckIn:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]integerValue] andBlock:^(NSDictionary *JSON, NSError *error) {
                if (!error && [JSON[@"status"] isEqualToString:@"ok"]) {
                    // Succeeded
                    replyHandler(@{@"status":@"ok",@"message":JSON[@"msg"]});
                } else {
                    // Failed
                    replyHandler(@{@"status":@"error"});
                }
            }];
        }
         
    } else if ([message objectForKey:@"fetchQRCode"]) {
        if ([[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]) {
             UIImage *qrImage = [CCQRCodeImage createNonInterpolatedUIImageFormCIImage:[CCQRCodeImage createQRForString:[NSString stringWithFormat:@"abletive://user/%@",[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]]] withSize:250];
            NSData *data = [NSData dataWithData:UIImagePNGRepresentation(qrImage)];
            replyHandler(@{@"image":data,@"message":@"ok"});
        }
    }
}

- (void)userLoggedIn {
    if ([WCSession isSupported] && [[WCSession defaultSession]isReachable] && [[WCSession defaultSession]isPaired] && [[WCSession defaultSession]isWatchAppInstalled]) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]];
        
        [[WCSession defaultSession] sendMessage:@{@"userLoggedIn":@"1",@"userInfo":userInfo} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            
        } errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
    }
}

- (void)userLoggedOut {
    if ([WCSession isSupported] && [[WCSession defaultSession]isReachable] && [[WCSession defaultSession]isPaired] && [[WCSession defaultSession]isWatchAppInstalled]) {
        [[WCSession defaultSession] sendMessage:@{@"userLoggedOut":@"1"} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            
        } errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
    }
}

- (void)setupTheme {
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"theme"]) {
        [self loadThemeColor:ThemeTypeDefault];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        switch ([[NSUserDefaults standardUserDefaults]integerForKey:@"theme"]) {
            case 0:
                [self loadThemeColor:ThemeTypeDefault];
                break;
            case 1:
                [self loadThemeColor:ThemeTypeLight];
                break;
            default:
                break;
        }
    });
}

- (void)loadThemeColor:(ThemeType)type {
    UIColor *backColor = [UIColor clearColor];
    UIColor *secondBackColor = [UIColor clearColor];
    UIColor *frontColor = [UIColor clearColor];
    UIColor *tintColor = [UIColor clearColor];
    UIColor *separatorColor = [UIColor clearColor];
    
    switch (type) {
        case ThemeTypeDefault:
        {
            backColor = [AppColor mainBlack];
            tintColor = [AppColor mainYellow];
            secondBackColor = [AppColor secondaryBlack];
            frontColor = [AppColor mainWhite];
            separatorColor = [UIColor colorWithWhite:1 alpha:0.1];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            break;
        }
        case ThemeTypeLight:
        {
            backColor = [AppColor mainWhite];
            tintColor = [AppColor mainRed];
            secondBackColor = [AppColor secondaryWhite];
            frontColor = [AppColor mainBlack];
            separatorColor = [UIColor colorWithWhite:0 alpha:0.1];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
            break;
        }
        default:
            break;
    }
    
    // Set navigation bar background and item
    [[UINavigationBar appearance]setBarTintColor:backColor];
    [[UIBarButtonItem appearance]setTintColor:tintColor];
    [[UINavigationBar appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:frontColor,NSForegroundColorAttributeName, nil]];
    // Set the tab bar background to black
    [[UITabBar appearance]setBarTintColor:backColor];
    // Set the tab bar item to yellow
    [[UITabBarItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:tintColor,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    [[UITabBar appearance]setTintColor:tintColor];
    // Set the table view background to black
    [[UITableView appearance]setBackgroundColor:secondBackColor];
    [[UITableView appearance]setSeparatorColor:separatorColor];
    // Set the table cell background and no selection/separator style
    [[UITableViewCell appearance]setBackgroundColor:[AppColor transparent]];
    [[UITableViewCell appearance]setSelectionStyle:UITableViewCellSelectionStyleNone];
    // Set the text label's color when inside table view
    if (IOS_VERSION_9_OR_ABOVE) {
        [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableView class]]]setTextColor:frontColor];
    } else {
        [[UILabel appearanceWhenContainedIn:[UITableView class], nil] setTextColor:frontColor];
    }
    // Set the switch color
    [[UISwitch appearance]setTintColor:tintColor];
    [[UISwitch appearance]setOnTintColor:tintColor];
}

- (void)registerForNotifications {
    UIMutableUserNotificationAction *checkInfirstViewAction = [[UIMutableUserNotificationAction alloc]init];
    checkInfirstViewAction.identifier = @"CHECKIN_VIEW";
    checkInfirstViewAction.destructive = false;
    checkInfirstViewAction.title = @"前往签到";
    checkInfirstViewAction.activationMode = UIUserNotificationActivationModeForeground;
    
    UIMutableUserNotificationCategory *checkInCategory = [[UIMutableUserNotificationCategory alloc]init];
    checkInCategory.identifier = @"CHECKIN_CATEGORY";
    
    NSArray *defaultActions = @[checkInfirstViewAction];
    [checkInCategory setActions:defaultActions forContext:UIUserNotificationActionContextDefault];
    [checkInCategory setActions:defaultActions forContext:UIUserNotificationActionContextMinimal];

    NSSet *categories = [NSSet setWithObjects:checkInCategory, nil];
    
    UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"deviceToken"]) {
        [PushNotification sendDeviceToken:newToken];
    }
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]) {
        [PushNotification updateUserID:[[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"id"]intValue] withToken:newToken];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@",error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if ([notification.userInfo[@"identifier"] isEqualToString:@"checkin"]) {
        if ([[UIApplication sharedApplication]applicationState] != UIApplicationStateActive) {
            UITabBarController *baseController = (UITabBarController *)self.window.rootViewController;
            [baseController.selectedViewController presentViewController:[[UINavigationController alloc]initWithRootViewController:[baseController.storyboard instantiateViewControllerWithIdentifier:@"CheckIn"]] animated:YES completion:nil];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received notification: %@", userInfo);
    NSDictionary *notification = userInfo[@"aps"];
    UITabBarController *baseController = (UITabBarController *)self.window.rootViewController;
    if (notification[@"new_post"]) {
        SinglePostTableViewController *singlePostTVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
        singlePostTVC.postID = [notification[@"new_post"] intValue];
        [baseController.selectedViewController pushViewController:singlePostTVC animated:YES];
        return;
    }
    if (notification[@"new_comment"]) {
        SinglePostTableViewController *singlePostTVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
        singlePostTVC.postID = [notification[@"new_comment"] intValue];
        [baseController.selectedViewController pushViewController:singlePostTVC animated:YES];
        return;
    }
    if (notification[@"message_from"]) {
        ChatMessageTableViewController *chatMessageTVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"ChatMessage"];
        chatMessageTVC.userID = [notification[@"message_from"] intValue];
        
        [baseController.selectedViewController pushViewController:chatMessageTVC animated:YES];
    }
}

// Local notification action handler
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler {
    UITabBarController *baseController = (UITabBarController *)self.window.rootViewController;
    if ([identifier isEqualToString:@"CHECKIN_VIEW"]) {
        [baseController.selectedViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:[baseController.storyboard instantiateViewControllerWithIdentifier:@"CheckIn"]] animated:YES completion:nil];
    }
    completionHandler();
}

// Available only in iOS 9 or above
// ==== IMPORTANT ====
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    [self handleShortcutItem:shortcutItem];
}

// Available only in iOS 9 or above
// ==== IMPORTANT ====
- (void)handleShortcutItem:(UIApplicationShortcutItem *)shortcutItem {
    NSString *type = shortcutItem.type;
    UITabBarController *baseController = (UITabBarController *)self.window.rootViewController;
    if ([type isEqualToString:@"Search"]){
        // Search Shortcut
        PostSearchResultsController *postSearchVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"PostSearch"];
        [baseController.selectedViewController pushViewController:postSearchVC animated:NO];
    } else if ([type isEqualToString:@"Settings"]){
        // Setting Shortcut
        [baseController.selectedViewController pushViewController:[baseController.storyboard instantiateViewControllerWithIdentifier:@"Setting"] animated:NO];
    } else if ([type isEqualToString:@"ScanQRCode"]){
        // QRCode Shortcut
        [baseController.selectedViewController pushViewController:[baseController.storyboard instantiateViewControllerWithIdentifier:@"QRCodeScan"] animated:NO];
    } else if ([type isEqualToString:@"CheckIn"]) {
        // Check in Shortcut
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]){
            [baseController.selectedViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:[baseController.storyboard instantiateViewControllerWithIdentifier:@"CheckIn"]] animated:YES completion:nil];
        } else {
            [TAOverlay showOverlayWithErrorText:@"请先登录~"];
        }
        
    } else {
        // Me Shortcut
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"user_is_logged"]){
            PersonalPageTableViewController *personalPageTVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
            [baseController.selectedViewController pushViewController:personalPageTVC animated:NO];
        } else {
            [TAOverlay setCompletionBlock:^(BOOL) {
                
            }];
            [TAOverlay showOverlayWithLabel:NSLocalizedString(@"您还未登录",  nil) Options:TAOverlayOptionAutoHide | TAOverlayOptionOverlaySizeFullScreen | TAOverlayOptionOverlayTypeError];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (IOS_VERSION_9_OR_ABOVE) {
        // Available only in iOS 9 or above
        // ==== IMPORTANT ====
        if (!self.launchedShortcutItem){ return; }
        [self handleShortcutItem:self.launchedShortcutItem];
        self.launchedShortcutItem = nil;
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return  YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    UITabBarController *baseController = (UITabBarController *)self.window.rootViewController;
    // Today widget
    if ([[url absoluteString] rangeOfString:todayActionPrefix].location != NSNotFound) {
        NSString *actionID = [[url absoluteString] substringWithRange:NSMakeRange(todayActionPrefix.length, [url absoluteString].length - todayActionPrefix.length)];
        baseController.selectedIndex = 0;
        SinglePostTableViewController *singlePostTVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
        singlePostTVC.postID = [actionID intValue];
        [baseController.selectedViewController pushViewController:singlePostTVC animated:YES];
    }
    
    // User personal page
    if ([[url absoluteString] rangeOfString:userPagePrefix].location != NSNotFound) {
        NSString *userID = [[url absoluteString] substringWithRange:NSMakeRange(userPagePrefix.length, [url absoluteString].length - userPagePrefix.length)];
        [TAOverlay showOverlayWithLogo];
        PersonalPageTableViewController *personalPageTVC = [baseController.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
        [User getUserinfoWithID:[userID intValue] andBlock:^(User * _Nullable user, NSError * _Nullable error) {
            [TAOverlay hideOverlay];
            if (!error){
                personalPageTVC.currentUser = user;
                [baseController.selectedViewController pushViewController:personalPageTVC animated:YES];
            }
        }];
    }
    
    return YES;
}

@end
