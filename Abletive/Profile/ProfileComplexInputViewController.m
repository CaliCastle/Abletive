//
//  ProfileComplexInputViewController.m
//  Abletive
//
//  Created by Cali on 10/19/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "ProfileComplexInputViewController.h"
#import "STPopup.h"
#import "AppColor.h"
#import "MozTopAlertView.h"
#import "NSString+CCNSString_Validation.h"

@interface ProfileComplexInputViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end

@implementation ProfileComplexInputViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width, 300);
    self.landscapeContentSizeInPopup = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, 300);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.text = self.defaultText;
    self.view.backgroundColor = [AppColor mainBlack];
    self.textView.textColor = [AppColor mainWhite];
    self.textView.backgroundColor = [AppColor transparent];
    
    [self.textView becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmDidClick:(id)sender {
    if ([self.textView.text length] > self.inputLimit) {
        [MozTopAlertView showWithType:MozAlertTypeWarning text:[NSString stringWithFormat:@"长度不得超过%lu",(unsigned long)self.inputLimit] parentView:self.view];
        return;
    }
    [self.delegate textChanged:self.textView.text];
    [self dismissViewControllerAnimated:YES completion:nil];
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
