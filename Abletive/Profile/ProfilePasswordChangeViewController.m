//
//  ProfilePasswordChangeViewController.m
//  Abletive
//
//  Created by Cali on 10/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ProfilePasswordChangeViewController.h"
#import "MozTopAlertView.h"
#import "STPopup.h"
#import "AppColor.h"
#import "User.h"
#import "TAOverlay.h"

@interface ProfilePasswordChangeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *secondPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation ProfilePasswordChangeViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 150);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 150);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"修改密码", nil);
    
    self.view.backgroundColor = [AppColor mainBlack];
    self.firstPasswordField.backgroundColor = [AppColor transparent];
    self.secondPasswordField.backgroundColor = [AppColor transparent];
    self.firstPasswordField.textColor = [AppColor mainWhite];
    self.secondPasswordField.textColor = [AppColor mainWhite];
    self.firstPasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"更改的密码..." attributes:@{NSForegroundColorAttributeName: [AppColor lightTranslucent]}];
    self.secondPasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"再输一遍密码..." attributes:@{NSForegroundColorAttributeName: [AppColor lightTranslucent]}];
    [self.firstPasswordField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)firstPasswordDidEndOnExit:(UITextField *)sender {
    if ([[sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        return;
    }
    [self.secondPasswordField becomeFirstResponder];
}

- (IBAction)secondPasswordDidEndOnExit:(UITextField *)sender {
    if (![[sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:self.firstPasswordField.text]) {
        [MozTopAlertView showWithType:MozAlertTypeError text:@"两次密码不一样，逗我呢" parentView:self.view];
        return;
    }
    [self confirmButtonDidClick:nil];
}

- (IBAction)confirmButtonDidClick:(id)sender {
    [self.view endEditing:YES];
    if ([[self.firstPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] || [[self.secondPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [MozTopAlertView showWithType:MozAlertTypeError text:@"请认真输入" parentView:self.view];
        return;
    }
    if (![[self.secondPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:self.firstPasswordField.text]) {
        [MozTopAlertView showWithType:MozAlertTypeError text:@"两次密码不一样，逗我呢" parentView:self.view];
        return;
    }
    [TAOverlay showOverlayWithLogo];
    self.confirmButton.enabled = NO;
    
    [User updateCurrentUserPassword:self.firstPasswordField.text andPassword2:self.secondPasswordField.text andBlock:^(BOOL success, NSString *message) {
        [TAOverlay hideOverlayWithCompletionBlock:^(BOOL finished) {
            if (success) {
                [MozTopAlertView showWithType:MozAlertTypeSuccess text:message parentView:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            } else {
                [MozTopAlertView showWithType:MozAlertTypeError text:message parentView:self.view];
                self.confirmButton.enabled = YES;
            }
        }];
    }];
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
