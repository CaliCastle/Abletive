//
//  PostCommentInputViewController.h
//  Abletive
//
//  Created by Cali on 11/11/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostCommentDelegate <NSObject>

- (void)inputEnded:(NSString *)text;

@end

@interface PostCommentInputViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (nonatomic,strong) NSString *defaultText;

@property (nonatomic,strong) NSString *defaultPlaceholder;

@property (nonatomic,weak) id <PostCommentDelegate> delegate;

@property (nonatomic,assign) NSUInteger inputLimit;

@end
