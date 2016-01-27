//
//  ProfileStandardInputViewController.m
//  Abletive
//
//  Created by Cali on 10/18/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ProfileStandardInputViewController.h"
#import "STPopup.h"
#import "AppColor.h"
#import "MozTopAlertView.h"
#import "NSString+CCNSString_Validation.h"

#define ROW_HEIGHT 30

@interface ProfileStandardInputViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *lengthCountLabel;

@end

@implementation ProfileStandardInputViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 160);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 160);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [AppColor mainBlack];
    if (self.isEmail) {
        self.inputField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    if (self.isNumeric) {
        self.inputField.keyboardType = UIKeyboardTypeNumberPad;
    }
    self.inputField.text = self.defaultText;
    self.inputField.backgroundColor = [AppColor mainBlack];
    self.inputField.layer.masksToBounds = YES;
    self.inputField.layer.borderWidth = 1.f;
    self.inputField.layer.cornerRadius = 10.f;
    self.inputField.layer.borderColor = [AppColor transparent].CGColor;
    self.inputField.returnKeyType = UIReturnKeyDone;
    self.lengthCountLabel.textColor = [AppColor lightTranslucent];
    self.lengthCountLabel.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.inputLimit - self.defaultText.length]];
    
    [self.inputField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)inputDidEndEditing:(id)sender {
    self.inputField.layer.borderColor = [AppColor transparent].CGColor;
}

- (IBAction)inputDidBeginEditing:(id)sender {
    self.inputField.layer.borderColor = [AppColor lightSeparator].CGColor;
}

- (IBAction)inputDidEndOnExit:(UITextField *)sender {
    if ([sender.text length] > self.inputLimit) {
        [MozTopAlertView showWithType:MozAlertTypeWarning text:[NSString stringWithFormat:@"长度不得超过%lu个字符",(unsigned long)self.inputLimit] parentView:self.view];
        return;
    }
    if (![sender.text isEmailAddress:sender.text] && self.isEmail) {
        [MozTopAlertView showWithType:MozAlertTypeError text:@"请输入正确的邮箱地址" parentView:self.view];
        return;
    }
    if (![sender.text isQQNumber:sender.text] && self.isNumeric) {
        [MozTopAlertView showWithType:MozAlertTypeError text:@"请输入正确的QQ号" parentView:self.view];
        return;
    }
    [self.delegate textChanged:[sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)inputDidChangeValue:(UITextField *)sender {
    if ([sender.text length] > self.inputLimit) {
        self.lengthCountLabel.textColor = [AppColor mainRed];
    } else {
        self.lengthCountLabel.textColor = [AppColor lightTranslucent];
    }
    self.lengthCountLabel.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.inputLimit - [sender.text length]]];
}

- (IBAction)confirmDidClick:(id)sender {
    [self inputDidEndOnExit:self.inputField];
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
