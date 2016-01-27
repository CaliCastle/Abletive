//
//  MeLoggedHeaderViewController.m
//  Abletive
//
//  Created by Cali on 6/21/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "MeLoggedHeaderViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Networking Extension/AbletiveAPIClient.h"
#import "AFNetworking.h"
#import "UIView+MJAlertView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Circle.h"
#import "CCDeviceDetecter.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenPadding 10

@interface MeLoggedHeaderViewController ()

@property (nonatomic,strong) NSString *avatarPath;
@property (nonatomic,strong) UIVisualEffectView *blurEffectView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@property (weak, nonatomic) IBOutlet UIButton *collectionButton;

@end

@implementation MeLoggedHeaderViewController

- (UIVisualEffectView *)blurEffectView {
    if (!_blurEffectView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    }
    _blurEffectView.frame = CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height);
    return _blurEffectView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    self.iconView.layer.masksToBounds = YES;
    self.iconView.layer.cornerRadius = 37.5f;
    self.iconView.layer.borderWidth = 2.0f;
    self.iconView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
    
    self.profileButton.layer.cornerRadius = 14.0f;
    self.profileButton.layer.borderColor = [AppColor mainYellow].CGColor;
    self.profileButton.layer.masksToBounds = YES;
    self.profileButton.layer.borderWidth = 1.1f;
    
    self.collectionButton.layer.cornerRadius = 14.0f;
    self.collectionButton.layer.borderColor = [AppColor mainYellow].CGColor;
    self.collectionButton.layer.masksToBounds = YES;
    self.collectionButton.layer.borderWidth = 1.1f;
    
    [self animation];
    [self.view insertSubview:self.blurEffectView aboveSubview:self.backgroundImageView];
    [self setDataWithAttributes:[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]]];
}

- (void)animation {
    CGRect startFrame = self.iconView.frame;
    CGRect endFrame = startFrame;
    
    startFrame = CGRectMake(startFrame.origin.x, startFrame.origin.y - 50, startFrame.size.width, startFrame.size.height);
    self.iconView.frame = startFrame;
    self.iconView.alpha = 0.2;
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.iconView.frame = endFrame;
        self.iconView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    startFrame = self.descriptionLabel.frame;
    endFrame = startFrame;
    
    startFrame = CGRectMake(startFrame.origin.x, startFrame.origin.y + 50, startFrame.size.width, startFrame.size.height);
    self.descriptionLabel.frame = startFrame;
    self.descriptionLabel.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.descriptionLabel.frame = endFrame;
        self.descriptionLabel.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    startFrame = self.profileButton.frame;
    endFrame = startFrame;
    
    startFrame = CGRectMake(startFrame.origin.x - 67, startFrame.origin.y, startFrame.size.width, startFrame.size.height);
    self.profileButton.frame = startFrame;
    self.profileButton.alpha = 0;
    
    [UIView animateWithDuration:0.35 delay:0.32 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.profileButton.frame = endFrame;
        self.profileButton.alpha = 1;
    } completion:nil];
    
    startFrame = self.collectionButton.frame;
    endFrame = startFrame;
    
    startFrame = CGRectMake(startFrame.origin.x + 67, startFrame.origin.y, startFrame.size.width, startFrame.size.height);
    self.collectionButton.frame = startFrame;
    self.collectionButton.alpha = 0;
    
    [UIView animateWithDuration:0.35 delay:0.62 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.collectionButton.frame = endFrame;
        self.collectionButton.alpha = 1;
    } completion:nil];
    
}

- (void)setDataWithAttributes:(nonnull NSMutableDictionary *)attributes {
    self.nameLabel.text = attributes[@"public_info"][@"display_name"];
    self.descriptionLabel.text = attributes[@"public_info"][@"description"];
    [self getFullAvatarWithAttributes:attributes];
}

- (void)getFullAvatarWithAttributes:(nonnull NSMutableDictionary *)attributes {
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"user_avatar_path"]) {
        // Initialize image
        [[AbletiveAPIClient sharedClient]GET:@"user/get_avatar" parameters:@{@"user_id":attributes[@"id"],@"type":@"full"} success:^(NSURLSessionDataTask *task, NSDictionary *JSON) {
            if ([JSON[@"status"] isEqualToString:@"ok"]) {
                NSString *fullAvatarPath = JSON[@"avatar"];
                // Get the img src
                if ([fullAvatarPath containsString:@"img src"]) {
                    NSRange range = [fullAvatarPath rangeOfString:@"\"" options:NSLiteralSearch];
                    fullAvatarPath = [fullAvatarPath substringFromIndex:range.location+1];
                    range = [fullAvatarPath rangeOfString:@"\"" options:NSLiteralSearch];
                    fullAvatarPath = [fullAvatarPath substringToIndex:range.location];
                }
                // Decode the string to url standard
                NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:fullAvatarPath];
                fullAvatarPath = [fullAvatarPath stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
                // Return the full avatar url path
                [[NSUserDefaults standardUserDefaults]setObject:fullAvatarPath forKey:@"user_avatar_path"];
                [self updateAvatarWithFileName:fullAvatarPath];
            }
            else {
                [UIView addMJNotifierWithText:@"加载头像时出错" andStyle:MJAlertViewError dismissAutomatically:YES];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [UIView addMJNotifierWithText:@"头像加载失败" andStyle:MJAlertViewError dismissAutomatically:YES];
        }];
    }
    else {
        [self updateAvatarWithFileName:[[NSUserDefaults standardUserDefaults]objectForKey:@"user_avatar_path"]];
    }
}

- (void)updateAvatarWithFileName:(nullable NSString *)avatarPath {
    if (avatarPath) {
        [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:avatarPath] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.iconView.image = image;
            [self.delegate avatarLoadSucceeded];
        }];
    }
    else {
        self.backgroundImageView.image = [UIImage imageNamed:@"default-avatar"];
        self.iconView.image = [UIImage imageNamed:@"default-avatar"];
        [self.delegate avatarLoadSucceeded];
    }
}

- (void)updateUserData {
    [self setDataWithAttributes:[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"]]];
    if (IOS_VERSION_9_OR_ABOVE) {
        // Available only in iOS 9 or above
        // ==== IMPORTANT ====
        // Change the Shortcut Item Subtitle of "Me"
        UIApplication *application = [UIApplication sharedApplication];
        NSArray *shortcutItems = [application shortcutItems];
        UIMutableApplicationShortcutItem *oldItem = [shortcutItems lastObject];
        UIMutableApplicationShortcutItem *mutableItem = [oldItem mutableCopy];
        [mutableItem setLocalizedTitle:[NSString stringWithFormat:@"%@的主页",[[NSUserDefaults standardUserDefaults]dictionaryForKey:@"user"][@"displayname"]]];
        [mutableItem setLocalizedSubtitle:@""];
        
        id updatedShortcutItems = [shortcutItems mutableCopy];
        [updatedShortcutItems replaceObjectAtIndex:[shortcutItems count]-1 withObject: mutableItem];
        [application setShortcutItems: updatedShortcutItems];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logoutDidClick:(id)sender {
    [self.delegate logoutButtonDidClick];
}

- (IBAction)profileDidClick:(id)sender {
    [self.delegate profileDidSelect];
}

- (IBAction)collectionDidClick:(id)sender {
    [self.delegate collectionDidSelect];
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
