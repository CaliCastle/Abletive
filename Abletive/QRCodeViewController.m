//
//  QRCodeViewController.m
//  Abletive
//
//  Created by Cali on 11/14/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "QRCodeViewController.h"
#import "AppColor.h"
#import "User.h"
#import "NSString+CCNSString_Validation.h"
#import "KINWebBrowser/KINWebBrowserViewController.h"
#import "MozTopAlertView.h"
#import "TAOverlay.h"
#import "Personal Page/PersonalPageTableViewController.h"
#import "ZXingObjC/ZXingObjC.h"
#import <AVFoundation/AVFoundation.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    NSUInteger maxY;
    NSUInteger minY;
    NSTimer *timer;
    UIImageView *line;
    CGRect cropRect;
}

@property (nonatomic,assign) BOOL isReading;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL isLightOn;

@property ( strong , nonatomic ) AVCaptureDevice * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput * output;
@property ( strong , nonatomic ) AVCaptureSession * captureSession;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * videoPreviewLayer;

@property (weak, nonatomic) IBOutlet UIView *myQRCodeView;
@property (weak, nonatomic) IBOutlet UIView *torchView;

@property (weak, nonatomic) IBOutlet UIImageView *myQRCodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *myQRCodeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *torchImageView;
@property (weak, nonatomic) IBOutlet UILabel *torchLabel;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIImageView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@end

static BOOL isLoading = NO;

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _isReading = NO;
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openPhotoAlbum)];
    
    self.title = NSLocalizedString(@"扫二维码", nil);
    [self loadBeepSound];
    
    cropRect = CGRectMake(60, 50, 220, 220);
    
    [_viewPreview setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
    self.torchImageView.tintColor = [AppColor mainWhite];
    self.myQRCodeImageView.tintColor = [AppColor mainWhite];
    
    if (ScreenHeight <= 500) {
        self.tipsLabel.hidden = YES;
    }
    
    self.torchImageView.image = [[UIImage imageNamed:@"torch"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.myQRCodeImageView.image = [[UIImage imageNamed:@"qrcode"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.torchLabel.text = @"开灯";
    self.myQRCodeLabel.text = @"我的二维码";
    
    UITapGestureRecognizer *torchTapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(torchDidClick)];
    [self.torchView addGestureRecognizer:torchTapper];
    
    UITapGestureRecognizer *myQRCodeTapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myQRCodeDidClick)];
    [self.myQRCodeView addGestureRecognizer:myQRCodeTapper];
    
    if ([self startReading]) {
        maxY = cropRect.origin.y + cropRect.size.height;
        minY = cropRect.origin.y;
        line = [[UIImageView alloc]initWithFrame:CGRectMake(cropRect.origin.x+20, 0, cropRect.size.width-4, 1.5)];
        [line setImage:[[UIImage imageNamed:@"code-scanner"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        line.tintColor = [AppColor mainYellow];
        [_viewPreview addSubview:line];
        
        UIView *mask1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (ScreenWidth - cropRect.size.width)/2, ScreenHeight)];
        mask1.backgroundColor = [AppColor darkOverlay];
        
        [_viewPreview addSubview:mask1];
        
        UIView *mask2 = [[UIView alloc]initWithFrame:CGRectMake(mask1.frame.size.width, 0, ScreenWidth - mask1.frame.size.width, cropRect.origin.y)];
        mask2.backgroundColor = [AppColor darkOverlay];
        [_viewPreview addSubview:mask2];
        
        UIView *mask3 = [[UIView alloc]initWithFrame:CGRectMake(mask1.frame.size.width, cropRect.origin.y + cropRect.size.height, cropRect.size.width, ScreenHeight)];
        mask3.backgroundColor = [AppColor darkOverlay];
        [_viewPreview addSubview:mask3];
        
        UIView *mask4 = [[UIView alloc]initWithFrame:CGRectMake(ScreenWidth - (ScreenWidth - cropRect.size.width)/2, cropRect.origin.y, (ScreenWidth - cropRect.size.width)/2, ScreenHeight)];
        mask4.backgroundColor = [AppColor darkOverlay];
        [_viewPreview addSubview:mask4];
        
//        timer = [NSTimer scheduledTimerWithTimeInterval:1.0/40 target:self selector:@selector(move) userInfo:nil repeats:YES];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    if (_captureSession) {
        [_captureSession startRunning];
        [timer fire];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopReading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 *
 AVCaptureMetadataOutput object. This class in combination with the AVCaptureMetadataOutputObjectsDelegate protocol will manage to intercept any metadata found in the input device (meaning data in a QR code captured by our camera) and translate it to a human readable format.
 */
- (BOOL)startReading {
    NSError *error;
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    _captureSession = [[AVCaptureSession alloc] init];
    
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Capture Rect
    captureMetadataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/ScreenHeight, cropRect.origin.x/ScreenWidth, cropRect.size.height/ScreenHeight, cropRect.size.width/ScreenWidth);
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    //show to user what the camera of the device sees  using a AVCaptureVideoPreviewLayer
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
    return YES;
}

- (void)stopReading{
    [_captureSession stopRunning];
//    _captureSession = nil;
    
//    [_videoPreviewLayer removeFromSuperlayer];
//    [timer invalidate];
}

-(void)loadBeepSound{
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"QRCodeComplete" ofType:@"wav"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        [_audioPlayer prepareToPlay];
    }
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            if (_audioPlayer) {
                [_audioPlayer play];
            }
//            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
            [self stopReading];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self detectQRCode:[metadataObj stringValue]];
            });
            _isReading = NO;
        }
    }
}

//- (void)move {
//    static BOOL flag = TRUE;  // true down  and false up
//    if (flag) {
//        if (line.frame.origin.y <maxY) {
//            line.frame = CGRectMake(
//                                    line.frame.origin.x, line.frame.origin.y +5,
//                                    line.frame.size.width, line.frame.size.height
//                                    );
//        } else {
//            flag = !flag;
//            if (_isReading&&[timer isValid]) {
//                [timer invalidate];
//            }
//        }
//    } else {
//        if (line.frame.origin.y >minY) {
//            line.frame = CGRectMake(
//                                    line.frame.origin.x, line.frame.origin.y -5,
//                                    line.frame.size.width, line.frame.size.height
//                                    );
//        } else {
//            flag = !flag;
//        }
//    }
//}

- (void)torchDidClick {
    if (self.isLightOn) {
        self.torchLabel.text = @"开灯";
        self.torchImageView.tintColor = [AppColor mainWhite];
        self.torchLabel.textColor = [AppColor mainWhite];
        [self systemLightSwitch:NO];
    } else {
        self.torchLabel.text = @"关灯";
        self.torchImageView.tintColor = [AppColor mainYellow];
        self.torchLabel.textColor = [AppColor mainYellow];
        [self systemLightSwitch:YES];
    }
    self.isLightOn = !self.isLightOn;
}

- (void)systemLightSwitch:(BOOL)open {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (open) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

- (void)myQRCodeDidClick {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"PersonalCard"] animated:YES];
}

- (void)detectQRCode:(NSString *)QRCode {
    if (isLoading) {
        return;
    }
    [MozTopAlertView showWithType:MozAlertTypeSuccess text:@"扫码成功" parentView:self.navigationController.navigationBar];
    QRCodeScanType scanType = QRCodeScanTypeURL;
    
    if ([QRCode containsString:@"abletive://user/"]) {
        // In-App actions
        scanType = QRCodeScanTypePersonalCard;
        QRCode = [QRCode substringFromIndex:@"abletive://user/".length];
    } else {
        if ([QRCode isURL:QRCode]) {
            scanType = QRCodeScanTypeURL;
        } else {
            scanType = QRCodeScanTypeText;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self codeScanned:QRCode andType:scanType];
    });
}

- (void)codeScanned:(NSString *)code andType:(QRCodeScanType)scanType {
    switch (scanType) {
        case QRCodeScanTypeURL:
        {
            UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];
            [self presentViewController:webBrowser animated:YES completion:^{
                [webBrowser.rootWebBrowser loadURLString:code];
            }];
            break;
        }
        case QRCodeScanTypeText:
        {
            UINavigationController *webBrowser = [KINWebBrowserViewController navigationControllerWithWebBrowser];
            [self presentViewController:webBrowser animated:YES completion:^{
                [webBrowser.rootWebBrowser loadHTMLString:code];
            }];
            break;
        }
        case QRCodeScanTypePersonalCard:
        {
            NSUInteger userID = [code integerValue];
            [TAOverlay showOverlayWithLoading];
            [User getUserinfoWithID:userID andBlock:^(User *userInfo, NSError *error) {
                [TAOverlay hideOverlayWithCompletionBlock:^(BOOL finished) {
                    if (!error || userInfo) {
                        PersonalPageTableViewController *personalPageTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PersonalPage"];
                        personalPageTVC.currentUser = userInfo;
                        [self.navigationController pushViewController:personalPageTVC animated:YES];
                    } else {
                        [TAOverlay showOverlayWithError];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                    }
                }];
            }];
            break;
        }
        default:
            break;
    }
}

- (void)openPhotoAlbum {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = NO;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    });
}

- (void)getInfoWithImage:(UIImage *)img{
    UIImage *loadImage= img;
    CGImageRef imageToDecode = loadImage.CGImage;
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    if (result) {
        // Success
        NSString *contents = result.text;
        
        [self detectQRCode:contents];
    } else {
        // Failure
        [MozTopAlertView showWithType:MozAlertTypeError text:@"解析失败" parentView:self.navigationController.navigationBar];
    }
}

#pragma mark UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
//    NSData *imageData = UIImagePNGRepresentation(image);
    [self getInfoWithImage:image];
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
