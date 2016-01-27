//
//  MeGuestHeaderViewController.m
//  Abletive
//
//  Created by Cali on 6/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "MeGuestHeaderView.h"
#import "MeGuestHeaderViewController.h"
#import "AppColor.h"
#import "UIImage+Rounded.h"

@interface MeGuestHeaderViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet MeGuestHeaderView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *guestAvatarView;

@end

@implementation MeGuestHeaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [AppColor secondaryBlack];
    self.loginButton.tintColor = [AppColor mainYellow];
    self.guestAvatarView.layer.masksToBounds = YES;
    self.guestAvatarView.layer.cornerRadius = 35.0f;
    self.guestAvatarView.layer.borderWidth = 2.0f;
    self.guestAvatarView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
    self.guestAvatarView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarDidTap)];
    [self.guestAvatarView addGestureRecognizer:tapper];
    self.headerView.userInteractionEnabled = YES;
    [self.headerView addGestureRecognizer:tapper];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)avatarDidTap {
    [self loginDidClick:nil];
}

- (IBAction)loginDidClick:(id)sender {
    [self.delegate openLoginPanel];
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
