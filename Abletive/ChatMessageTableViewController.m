//
//  ChatMessageTableViewController.m
//  Abletive
//
//  Created by Cali on 11/27/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>

#import "ChatMessageTableViewController.h"
#import "MessagePlainTableViewCell.h"
#import "MessageTimeTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "AppColor.h"
#import "STInputBar.h"
#import "TAOverlay.h"
#import "KINWebBrowser/KINWebBrowserViewController.h"
#import "PersonalPageTableViewController.h"
#import "SinglePostTableViewController.h"
#import "CCDateToString.h"
#import "UIBarButtonItem+Badge.h"

#define DEFAULT_BAR_HEIGHT 44.0

@interface ChatMessageTableViewController ()<UITableViewDataSource,UITableViewDelegate,MessageTableViewDelegate>

@property (nonatomic,strong) NSMutableArray *allMessages;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) STInputBar *inputBar;

@property (nonatomic,assign) BOOL isKeyboardOpen;
@property (nonatomic,assign) CGPoint lastPoint;
@property (nonatomic,assign) CGFloat barHeight;
@property (nonatomic, strong) NSNotification *lastNotification;

@end

@implementation ChatMessageTableViewController {
    BOOL animationLock;
    BOOL messageLoaded;
    SystemSoundID sentSoundID;
    SystemSoundID receivedSoundID;
    NSUInteger newMessageCount;
}

- (NSMutableArray *)allMessages {
    if (_allMessages) {
        return _allMessages;
    }
    
    _allMessages = [NSMutableArray array];
    
    return _allMessages;
}

- (UITableView *)tableView {
    if (_tableView) {
        return _tableView;
    }
    
    _tableView                      =   [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.inputBar.frame.size.height)];
    _tableView.fd_debugLogEnabled   =   NO;
    _tableView.separatorStyle       =   UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor      =   [AppColor secondaryBlack];
    _tableView.delegate             =   self;
    _tableView.dataSource           =   self;
    _tableView.keyboardDismissMode  =   UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.indicatorStyle       =   UIScrollViewIndicatorStyleWhite;
    
    [_tableView registerClass:[MessagePlainTableViewCell class] forCellReuseIdentifier:kCellReuseIDWithSenderAndType(0,(long)ChatMessageTypePlainText)];
    [_tableView registerClass:[MessagePlainTableViewCell class] forCellReuseIdentifier:kCellReuseIDWithSenderAndType(1, (long)ChatMessageTypePlainText)];
    [_tableView registerClass:[MessageTimeTableViewCell class] forCellReuseIdentifier:kTimeCellReusedID];
    
    return _tableView;
}

- (STInputBar *)inputBar {
    if (!_inputBar) {
        _inputBar = [STInputBar new];
        _inputBar.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.inputBar.frame) + CGRectGetHeight(self.inputBar.frame)/2);
        _inputBar.fitWhenKeyboardShowOrHide = YES;
    }
    return _inputBar;
}

- (void)setupInputBar {
    __weak typeof(self) weakSelf = self;
    self.barHeight = self.inputBar.frame.size.height;
    [self.inputBar setDidSendClicked:^(NSString *text) {
        [weakSelf sendMessage:text];
    }];
    [self.inputBar setInputBarSizeChangedHandle:^(CGFloat height) {
        [weakSelf inputBarSizeWillChange:height];
    }];
    [self.view addSubview:self.inputBar];
}

- (void)fetchMessages {
    [TAOverlay showOverlayWithLogo];
    if (!self.currentUser) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [User getUserinfoWithID:self.userID andBlock:^(User * _Nullable user, NSError * _Nullable error) {
                if (!error) {
                    self.currentUser = user;
                    [ChatMessage getChatMessagesFromUserID:self.currentUser.userID andBlock:^(NSArray *chatMessages) {
                        [self messagesLoaded:chatMessages];
                    }];
                    [self setupUser];
                } else {
                    [TAOverlay showOverlayWithErrorText:@"加载失败, 请重试"];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [ChatMessage getChatMessagesFromUserID:self.currentUser.userID andBlock:^(NSArray *chatMessages) {
                [self messagesLoaded:chatMessages];
            }];
        });
    }
}

- (void)setupSound {
    NSString *soundFile = [[NSBundle mainBundle] pathForResource:@"Message_Sent" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &sentSoundID);
        
    soundFile = [[NSBundle mainBundle] pathForResource:@"Message_Received" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundFile], &receivedSoundID);
}

- (void)setupUser {
    self.title = self.currentUser ? self.currentUser.name : @"加载中...";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"author"] style:UIBarButtonItemStyleDone target:self action:@selector(avatarDidTap)];
}

- (void)messagesLoaded:(NSArray *)chatMessages {
    [TAOverlay hideOverlay];
    if (chatMessages) {
        messageLoaded = YES;
        if (chatMessages.count) {
            NSInteger i = 1;
//            NSString *lastDateString = @"";
            for (ChatMessage *message in chatMessages) {
                if (i != 1 && chatMessages.count >= 2) {
                    // If lasted longer than 5 minutes
                    [self addMessageModel:message];
                } else {
                    ChatMessage *time = [ChatMessage chatMessageWithContent:[CCDateToString getStringFromDate:message.date] andType:ChatMessageTypeTime andIsSender:NO withUserID:0];
                    time.date = message.date;
                    [self.allMessages addObject:time];
                    [self.allMessages addObject:message];
//                    lastDateString = message.date;
                }
                i++;
            }
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        } else {
            ChatMessage *helloMessage = [ChatMessage chatMessageWithContent:@"Hi😄, 我们还没聊过天呢，想找我说些什么？" andType:ChatMessageTypePlainText andIsSender:NO withUserID:self.currentUser.userID];
            [self.allMessages addObject:helloMessage];
            [self.tableView reloadData];
        }
    } else {
        [TAOverlay showOverlayWithErrorText:@"加载失败, 请重试"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)addMessageModel:(ChatMessage *)message {
    NSString *lastDateString = @"";
    
    for (NSInteger i = self.allMessages.count - 1; i > 0; i--) {
        ChatMessage *message = self.allMessages[i];
        if (message.messageType == ChatMessageTypeTime) {
            lastDateString = message.date;
            break;
        }
    }
    
    ChatMessage *lastOne = self.allMessages.lastObject;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *lastDate = [formatter dateFromString:lastOne.date];
    NSDate *lastDate2 = [formatter dateFromString:lastDateString];
    NSDate *newDate = [formatter dateFromString:message.date];
    
    if ([newDate timeIntervalSinceDate:lastDate] > 60 * 5 || [newDate timeIntervalSinceDate:lastDate2] > 60 * 10) {
        ChatMessage *time = [ChatMessage chatMessageWithContent:[CCDateToString getStringFromDate:message.date] andType:ChatMessageTypeTime andIsSender:NO withUserID:0];
        time.date = message.date;
        [self.allMessages addObject:time];
        [self.allMessages addObject:message];
        
        return YES;
    } else {
        [self.allMessages addObject:message];
        
        return NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchMessages];
    [self setupUser];
    [self setupSound];
    
    self.lastPoint = CGPointZero;
    
    
    UIImage *buttonImage = [[UIImage imageNamed:@"backbutton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, buttonImage.size.height, buttonImage.size.height);
    [leftButton addTarget:self action:@selector(backDidClick) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tintColor = [AppColor mainYellow];
    [leftButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.view.backgroundColor = [AppColor secondaryBlack];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self.view addSubview:self.tableView];
    [self setupInputBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedPushNotification:) name:@"NewMessage" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backDidClick {
    [self.navigationController popViewControllerAnimated:YES];
}
     
- (void)receivedPushNotification:(NSNotification *)aNotification {
    if (messageLoaded) {
        if (self.currentUser) {
            if ([aNotification.userInfo[@"user_id"] intValue] == self.currentUser.userID) {
                [self updateMessage:aNotification.userInfo[@"message"]];
            } else {
                newMessageCount++;
                self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:newMessageCount]];
            }
        } else {
            if ([aNotification.userInfo[@"user_id"] intValue] == self.userID) {
                [self updateMessage:aNotification.userInfo[@"message"]];
            } else {
                newMessageCount++;
                self.navigationItem.leftBarButtonItem.badgeValue = [NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:newMessageCount]];
            }
        }
    }
}

- (void)updateMessage:(NSString *)message {
    // Play sound
    AudioServicesPlaySystemSound(receivedSoundID);
    
    ChatMessage *newMessage = [ChatMessage chatMessageWithContent:message andType:ChatMessageTypePlainText andIsSender:NO withUserID:self.currentUser.userID];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    newMessage.date = [dateFormatter stringFromDate:[NSDate new]];
    newMessage.avatarURL = self.currentUser.avatarPath;
    
    BOOL hasTime = [self addMessageModel:newMessage];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0];
    [self.tableView beginUpdates];
    if (hasTime) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0], indexPath] withRowAnimation:UITableViewRowAnimationRight];
    } else {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardWillShow:(NSNotification *)aNotification {
    [self keyboardEvent:aNotification and:YES];
    self.isKeyboardOpen = YES;
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self keyboardEvent:aNotification and:NO];
    self.isKeyboardOpen = NO;
}

- (void)keyboardEvent:(NSNotification *)aNotification and:(BOOL)isOpen {
    if (!messageLoaded) {
        return;
    }
    
    if (isOpen) {
        self.tableView.frame = CGRectMake(self.lastPoint.x, self.lastPoint.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
        self.lastPoint = self.tableView.frame.origin;
    }
    NSDictionary *userInfo = aNotification.userInfo;
    
    NSTimeInterval animationDuration = 0;
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseIn;
    CGRect keyboardFrame = CGRectZero;
    
    [userInfo[UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [userInfo[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat contentSizeHeight = self.tableView.contentSize.height + self.navigationController.navigationBar.frame.size.height;
    
    if (self.tableView.frame.size.height - keyboardFrame.size.height >= contentSizeHeight) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } else {
        /**
         *  If we currently have a keyboard (Mostly likely when the user taps on Emoticon button)
         */
        if (self.isKeyboardOpen && isOpen) {
            if (contentSizeHeight >= self.tableView.frame.size.height) {
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (keyboardFrame.size.height * (isOpen ? -1 : 1)), self.tableView.frame.size.width, self.tableView.frame.size.height);
            } else {
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (isOpen ? -1 : 1) * (contentSizeHeight - (self.tableView.frame.size.height - keyboardFrame.size.height)), self.tableView.frame.size.width, self.tableView.frame.size.height);
            }
            
        } else {
            if (animationLock && !isOpen) {
                animationLock = NO;
                return;
            }
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:animationCurve];
            [UIView setAnimationDuration:animationDuration];
            
            if (contentSizeHeight >= self.tableView.frame.size.height) {
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (keyboardFrame.size.height * (isOpen ? -1 : 1)) + ((self.inputBar.frame.size.height - DEFAULT_BAR_HEIGHT) * (isOpen ? -1 : 1)), self.tableView.frame.size.width, self.tableView.frame.size.height);
            } else {
                self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + (isOpen ? -1 : 1) * (contentSizeHeight - (self.tableView.frame.size.height - keyboardFrame.size.height)) + ((self.inputBar.frame.size.height - DEFAULT_BAR_HEIGHT) * (isOpen ? -1 : 1)), self.tableView.frame.size.width, self.tableView.frame.size.height);
            }
            
//            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [UIView commitAnimations];
            if (!isOpen && self.tableView.isDragging) {
                animationLock = YES;
            }
        }
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

- (void)inputBarSizeWillChange:(CGFloat)height {
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y - height + self.barHeight, self.tableView.frame.size.width, self.tableView.frame.size.height);
    self.barHeight = height;
}

- (void)sendMessage:(NSString *)text {
    if ([[text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        return;
    }
    
    ChatMessage *newMessage = [ChatMessage chatMessageWithContent:text andType:ChatMessageTypePlainText andIsSender:YES withUserID:self.currentUser.userID];
    newMessage.status = MessageSendStatusSending;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    newMessage.date = [dateFormatter stringFromDate:[NSDate new]];
    
    BOOL hasTime = [self addMessageModel:newMessage];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.allMessages.count-1 inSection:0];
    
    [self.tableView beginUpdates];
    if (hasTime) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0], indexPath] withRowAnimation:UITableViewRowAnimationRight];
    } else {
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    [ChatMessage sendChatMessageWithContent:text andToWhom:self.currentUser.userID andBlock:^(BOOL success, ChatMessage *message) {
        self.allMessages[indexPath.row] = message;
        
        [self.tableView reloadData];
        // Play sound
        AudioServicesPlaySystemSound(sentSoundID);
    }];
}

- (void)avatarDidTap {
    [self avatarDidTap:NO];
}

- (void)avatarDidTap:(BOOL)isMyself {
    // User tapped the sender's avatar
    PersonalPageTableViewController *personalPage = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
    personalPage.currentUser = isMyself ? nil : self.currentUser;
    
    [self.navigationController pushViewController:personalPage animated:YES];
}

- (void)linkDidTapAtURL:(NSString *)url {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"链接操作" message:url preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"打开链接" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self openLink:url];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拷贝链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = url;
        [TAOverlay showOverlayWithSuccessText:@"拷贝成功"];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"在Safari打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openLink:(NSString *)url {
    if ([url containsString:@"//abletive.com/"] && ![url containsString:@"//abletive.com/author"]) {
        SinglePostTableViewController *singlePostTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SinglePostTVC"];
        singlePostTVC.postSlug = url;
        
        [self.navigationController pushViewController:singlePostTVC animated:YES];
    } else {
        KINWebBrowserViewController *webBrowser = [KINWebBrowserViewController webBrowser];
        [self.navigationController pushViewController:webBrowser animated:YES];
        [webBrowser loadURLString:url];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *model = self.allMessages[indexPath.row];
    if (!model.isSender) {
        model.avatarURL = self.currentUser.avatarPath;
    }
    
    NSInteger height = model.height;
    
    if (!height){
        height = [tableView fd_heightForCellWithIdentifier:kCellReuseID(model) configuration:^(MessageBaseTableViewCell* cell)
                  {
                      [cell setMessageModel:model];
                  }];
    }
    
    return height+2;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = self.allMessages.count;
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *model = self.allMessages[indexPath.row];
    MessageBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseID(model)];
    cell.delegate = self;
    // Configure the cell...
    [cell setMessageModel:model];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
