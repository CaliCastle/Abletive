//
//  SinglePostHeaderViewController.m
//  Abletive
//
//  Created by Cali on 7/3/15.
//  Copyright © 2015 CaliCastle. All rights reserved.
//

#import "SinglePostHeaderViewController.h"
#import "UIImageView+WebCache.h"
#import "NSString+ConvertAmpersandSymbol.h"
#import "UICopiableLabel.h"
#import "CCDateToString.h"
#import "AppFont.h"
#import "AppColor.h"

#import "MLPhotoBrowserAssets.h"
#import "MLPhotoBrowserViewController.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenPadding 10
#define LabelHeight 20
#define VideoHeight 180 * (ScreenWidth / 375)


@interface SinglePostHeaderViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *visitCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (nonatomic,assign) CGFloat fullHeight;

@end

@implementation SinglePostHeaderViewController

- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableArray *)videos {
    if (!_videos) {
        _videos = [NSMutableArray array];
    }
    return _videos;
}

- (NSMutableArray *)links {
    if (!_links) {
        _links = [NSMutableArray array];
    }
    return _links;
}

- (NSMutableArray *)imagesWithAttribute {
    if (!_imagesWithAttribute) {
        _imagesWithAttribute = [NSMutableArray arrayWithCapacity:[_images count]];
    }
    return _imagesWithAttribute;
}

- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (NSMutableArray *)videoViews {
    if (!_videoViews) {
        _videoViews = [NSMutableArray array];
    }
    return _videoViews;
}

- (NSMutableArray *)linkLabels {
    if (!_linkLabels) {
        _linkLabels = [NSMutableArray array];
    }
    return _linkLabels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Initialize
    self.fullHeight = self.dateLabel.frame.origin.y + self.dateLabel.bounds.size.height;
    
    // Setup
    self.view.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = self.currentPost.title;
    self.visitCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.currentPost.visitCount];
    self.commentCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.currentPost.commentCount];
    
    self.dateLabel.text = [CCDateToString getStringFromDate:self.currentPost.date];
    self.categoryLabel.text = [self.currentPost.belongedCategories firstObject][@"title"];
    
    self.currentPost.content = [self filterWPPlayer:self.currentPost.content];
    self.currentPost.content = [self filterImageText:self.currentPost.content];
    self.currentPost.content = [self filterSmartideo:self.currentPost.content];
    self.currentPost.content = [self filterLinkText:self.currentPost.content];
    if ([self.currentPost.content containsString:@"http://share.acg.tv/flash.swf"]) {
        self.currentPost.content = [self filterBilibili:self.currentPost.content];
    }
    
    self.currentPost.content = [self filterHTML:self.currentPost.content];
    self.currentPost.content = [NSString parseString:self.currentPost.content];
    
    if ([self.images count] > 0) {
        for (NSString *imageString in self.images) {
            NSDictionary *attributes = [self getImageAttributes:imageString];
            [self.imagesWithAttribute addObject:attributes];
        }
    }
    
    [self addContent];
    [self.view setFrame:CGRectMake(0, 0, ScreenWidth, self.fullHeight + 2 * ScreenPadding)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Filter String

- (NSString *)filterWPPlayer:(NSString *)html {
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *text = nil;
    while ([scanner isAtEnd] == NO) {
        // Find the tag beginning
        [scanner scanUpToString:@"<!--wp-player start-->" intoString:nil];
        // Find the tag ending
        [scanner scanUpToString:@"<!--wp-player end-->" intoString:&text];
        // Replace string
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",text] withString:@""];
    }
    return html;
}

- (NSString *)filterSmartideo:(NSString *)html {
    while ([html containsString:@"如果视频无法播放，点击这里试试"]) {
        NSString *temp = @"<div class=\"tips\">";
        NSRange range = [html rangeOfString:temp];
        if (range.length == 0) return html;
        NSUInteger begin_location = range.location;
        NSUInteger video_location = begin_location;
        
        temp = @"如果视频无法播放，点击这里试试</a>";
        range = [html rangeOfString:temp];
        NSUInteger end_location = range.location;
        NSUInteger video_length = end_location - video_location + [temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *video_string = [html substringWithRange:NSMakeRange(begin_location, end_location - begin_location)];
        temp = @"href=\"";
        range = [video_string rangeOfString:temp];
        begin_location = range.location;
        NSUInteger begin_length = range.length;
        
        temp = @"\" target=";
        range = [video_string rangeOfString:temp];
        end_location = range.location;
        
        NSString *video_path = [video_string substringWithRange:NSMakeRange(begin_location + begin_length, end_location - begin_location - begin_length)];
        [self.videos addObject:video_path];
        
        html = [html stringByReplacingOccurrencesOfString:@"<div class=\"tips\">" withString:@"" options:NSLiteralSearch range:NSMakeRange(video_location, video_length)];
        html = [html stringByReplacingOccurrencesOfString:@"如果视频无法播放，点击这里试试" withString:@"`VIDEO" options:NSLiteralSearch range:NSMakeRange(video_location,video_length)];
    }
    return html;
}

- (NSString *)filterBilibili:(NSString *)html {
    NSScanner *scanner = [NSScanner scannerWithString:html];
    NSString *tempHtml = html;
    NSString *text = nil;
    while ([scanner isAtEnd] == NO) {
        // Find the tag beginning
        [scanner scanUpToString:@"flashvars=\"" intoString:nil];
        // Find the tag ending
        [scanner scanUpToString:@"\" pluginspage" intoString:&text];
        // Replace string
        html = [text substringFromIndex:11];
    }
    NSString *link = [NSString stringWithFormat:@"http://www.bilibili.com/av%@",html];
    link = [link stringByReplacingOccurrencesOfString:@"aid=" withString:@""];
    link = [link stringByReplacingOccurrencesOfString:@"&page=1" withString:@""];
    [self.videos addObject:link];
    
    scanner = [NSScanner scannerWithString:tempHtml];
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:@"<embed " intoString:nil];
        // Find the tag ending
        [scanner scanUpToString:@"\">" intoString:&text];
        tempHtml = [tempHtml stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\">",text] withString:@"`VIDEO"];
    }
    return tempHtml;
}

- (NSDictionary *)getImageAttributes:(NSString *)imageString {
    if (!imageString) {
        return nil;
    }
    
    NSRange classBeginRange = [imageString rangeOfString:@"class=\""];
    NSRange srcBeginRange = [imageString rangeOfString:@"src=\""];
    if (classBeginRange.location > srcBeginRange.location) {
        // <img src="" alt="" width="" height="" class="" />
        NSRange srcEndRange = [imageString rangeOfString:@"\" alt"];
        NSString *srcUrl = [imageString substringWithRange:NSMakeRange(srcBeginRange.location + srcBeginRange.length, srcEndRange.location - srcBeginRange.location - srcEndRange.length)];
        NSRange widthBeginRange = [imageString rangeOfString:@"width=\""];
        NSRange widthEndRange = [imageString rangeOfString:@"\" height"];
        NSUInteger imgWidth = [[imageString substringWithRange:NSMakeRange(widthBeginRange.location + widthBeginRange.length, widthEndRange.location - widthBeginRange.location)]integerValue];
        NSRange heightBeginRange = [imageString rangeOfString:@"height=\""];
        NSRange heightEndRange = [imageString rangeOfString:@"\" class"];
        NSUInteger imgHeight = [[imageString substringWithRange:NSMakeRange(heightBeginRange.location + heightBeginRange.length, heightEndRange.location - heightBeginRange.location)]integerValue];
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[srcUrl,[NSNumber numberWithInteger:imgWidth],[NSNumber numberWithInteger:imgHeight]] forKeys:@[@"url",@"width",@"height"]];
        return attributes;
    } else {
        // <img class="" src="" alt="" width="" height="" />
        NSRange srcEndRange = [imageString rangeOfString:@"\" alt"];
        NSString *srcUrl = [imageString substringWithRange:NSMakeRange(srcBeginRange.location + srcBeginRange.length, srcEndRange.location - srcBeginRange.location - srcEndRange.length)];
        NSRange widthBeginRange = [imageString rangeOfString:@"width=\""];
        NSRange widthEndRange = [imageString rangeOfString:@"\" height"];
        NSUInteger imgWidth = [[imageString substringWithRange:NSMakeRange(widthBeginRange.location + widthBeginRange.length, widthEndRange.location - widthBeginRange.location)]integerValue];
        NSRange heightBeginRange = [imageString rangeOfString:@"height=\""];
        NSRange heightEndRange = [imageString rangeOfString:@"\" /"];
        NSUInteger imgHeight = [[imageString substringWithRange:NSMakeRange(heightBeginRange.location + heightBeginRange.length, heightEndRange.location - heightBeginRange.location - heightBeginRange.length)]integerValue];
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjects:@[srcUrl,[NSNumber numberWithInteger:imgWidth],[NSNumber numberWithInteger:imgHeight]] forKeys:@[@"url",@"width",@"height"]];
        return attributes;
    }
}

-(NSString *)filterImageText:(NSString *)html {
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO) {
        // Find the tag beginning
        [scanner scanUpToString:@"<img" intoString:nil];
        // Find the tag ending
        [scanner scanUpToString:@">" intoString:&text];
        // Store the image tag to the array
        if ([self.images indexOfObject:text] != 0 && text){
            if (![text containsString:@"wp-smiley"]) {
                [self.images addObject:text];
            } else {
                continue;
            }
        }
        // Replace string
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@"`IMG"];
    }
    return html;
}

- (NSString *)filterLinkText:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"document.createElement('video');" withString:@""];
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO) {
        // Find the tag beginning
        [scanner scanUpToString:@"<a" intoString:nil];
        // Find the tag ending
        [scanner scanUpToString:@"</a>" intoString:&text];
        // Store the image tag to the array
        if ([text containsString:@"`IMG"] || [text containsString:@"`VIDEO"] || [text containsString:@"fa fa-"]) {
            continue;
        }
        [self.links addObject:text];
        // Replace string
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@</a>",text] withString:@"`LINK"];
    }
    return html;
}

-(NSString *)filterHTML:(NSString *)html {
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        // Find the tag beginning
        [scanner scanUpToString:@"<" intoString:nil];
        // Find the tag ending
        [scanner scanUpToString:@">" intoString:&text];
        // Replace string
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}

- (NSString *)getLinkURL:(NSString *)linkTag {
    NSScanner * scanner = [NSScanner scannerWithString:linkTag];
    while([scanner isAtEnd]==NO) {
        // Find the tag beginning
        [scanner scanUpToString:@"href=\"" intoString:nil];
        // Find the tag ending
        [scanner scanUpToString:@"\" " intoString:&linkTag];
        // Replace string
//        linkTag = [url substringFromIndex:6];
    }
    return [linkTag substringFromIndex:6];
}

#pragma mark Insert Content Once We're Ready

- (void)addContent {
    NSMutableArray *mutableComponents = [[self.currentPost.content componentsSeparatedByString:@"\n"] mutableCopy];
    NSUInteger currentYOffset = self.dateLabel.frame.origin.y + self.dateLabel.bounds.size.height;
    // No need to display the blank space
    [mutableComponents removeObject:@""];
    // Clear out the suffix of "赞一个，收藏"
    [mutableComponents removeLastObject];
    
    NSUInteger videoIndex = 0;
    NSUInteger imageIndex = 0;
    NSUInteger linkIndex = 0;
    
    for (NSString *component in mutableComponents) {
        NSRange imgRange = [component rangeOfString:@"`IMG"];
        if (imgRange.length > 0) {
            // Add Image
            CGFloat imageWidth = ScreenWidth - 2 * ScreenPadding;
            CGFloat imageHeight = imageWidth * ([self.imagesWithAttribute[imageIndex][@"height"]floatValue] / [self.imagesWithAttribute[imageIndex][@"width"]floatValue]);
            UIImageView *imgThumb = [[UIImageView alloc]initWithFrame:CGRectMake(ScreenPadding, currentYOffset + 2 * ScreenPadding, imageWidth, imageHeight)];
            imgThumb.backgroundColor = [UIColor clearColor];
            imgThumb.contentMode = UIViewContentModeScaleAspectFit;
            imgThumb.tag = imageIndex;
            imgThumb.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapped:)];
            [imgThumb addGestureRecognizer:tapper];
            [imgThumb sd_setImageWithURL:[NSURL URLWithString:self.imagesWithAttribute[imageIndex][@"url"]]
                        placeholderImage:[UIImage imageNamed:@"banner_placeholder"]
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   imgThumb.image = image;
                                   imgThumb.layer.masksToBounds = YES;
                                   imgThumb.layer.cornerRadius = 10.0f;
                                   imgThumb.contentMode = UIViewContentModeScaleToFill;
                               }];
            [self.view addSubview:imgThumb];
            [self.imageViews addObject:imgThumb];
            imageIndex++;
            // Increment it
            currentYOffset+=(imageHeight + ScreenPadding);
            self.fullHeight+=(imageHeight + (2 * ScreenPadding));
            
            continue;
        }
        NSRange vidRange = [component rangeOfString:@"`VIDEO"];
        if (vidRange.length > 0) {
            // Add Video
            UIImageView *videoThumb = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video-thumbnail"]];
            videoThumb.userInteractionEnabled = YES;
            [videoThumb setFrame:CGRectMake(ScreenPadding, currentYOffset + 2 * ScreenPadding, ScreenWidth - 2 * ScreenPadding, VideoHeight)];
            videoThumb.tag = videoIndex;
            videoThumb.layer.masksToBounds = YES;
            videoThumb.layer.cornerRadius = 10.0f;
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openVideo:)];
            [videoThumb addGestureRecognizer:tapGesture];
            [self.view addSubview:videoThumb];
            
            [self.videoViews addObject:videoThumb];
            videoIndex++;
            // Increment it
            currentYOffset+=(VideoHeight + ScreenPadding);
            self.fullHeight+=(VideoHeight + ScreenPadding);
            
            continue;
        }
        // Or else just add normal text labels
        // Calculate the totally lines
        NSUInteger lines = 1;
        NSUInteger length = [component lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        while (length >= 28) {
            length -= 28;
            lines++;
        }
        UICopiableLabel *textLabel = [[UICopiableLabel alloc]initWithFrame:CGRectMake(ScreenPadding, currentYOffset + 2 * ScreenPadding, ScreenWidth - 2 * ScreenPadding, lines * LabelHeight)];
        textLabel.numberOfLines = lines;
        textLabel.userInteractionEnabled = YES;
        textLabel.text = component;
        textLabel.font = [AppFont defaultFont];
        
        if ([component containsString:@"`LINK"]) {
            if ([[self getLinkURL:self.links[linkIndex]] containsString:@".mp4"] || [[self getLinkURL:self.links[linkIndex]] containsString:@".flv"]
                || [[self getLinkURL:self.links[linkIndex]] containsString:@".wmv"] || [[self getLinkURL:self.links[linkIndex]] containsString:@".avi"]) {
                // This is actually a video
                UIImageView *videoThumb = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"video-thumbnail"]];
                videoThumb.userInteractionEnabled = YES;
                [videoThumb setFrame:CGRectMake(ScreenPadding, currentYOffset + 2 * ScreenPadding, ScreenWidth - 2 * ScreenPadding, VideoHeight)];
                videoThumb.tag = videoIndex;
                videoThumb.layer.masksToBounds = YES;
                videoThumb.layer.cornerRadius = 10.0f;
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openVideo:)];
                [videoThumb addGestureRecognizer:tapGesture];
                [self.view addSubview:videoThumb];
                
                [self.videoViews addObject:videoThumb];
                
                NSString *videoLink = [self getLinkURL:self.links[linkIndex]];
                videoLink = [videoLink substringToIndex:[videoLink rangeOfString:@"\""].location];
                
                [self.videos insertObject:videoLink atIndex:videoIndex];
                [self.links removeObjectAtIndex:linkIndex];
                
                videoIndex++;
                // Increment it
                currentYOffset+=(VideoHeight + ScreenPadding);
                self.fullHeight+=(VideoHeight + ScreenPadding);
                
                continue;
            } else {
                textLabel.textColor = [AppColor mainYellow];
                textLabel.text = NSLocalizedString(@"点击查看链接", nil);
                textLabel.tag = linkIndex;
                UITapGestureRecognizer *linkGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openLink:)];
                [textLabel addGestureRecognizer:linkGesture];
                [self.links setObject:[self getLinkURL:self.links[linkIndex]] atIndexedSubscript:linkIndex];
                [self.linkLabels addObject:textLabel];
                linkIndex++;
            }
        } else {
            textLabel.textColor = [UIColor whiteColor];
        }
        [self.view addSubview:textLabel];
        currentYOffset+=(lines * LabelHeight + ScreenPadding);
        self.fullHeight+=(lines * LabelHeight + ScreenPadding);
    }
}

- (void)imageTapped:(UITapGestureRecognizer *)sender {
    NSUInteger imageIndex = sender.view.tag;
    NSMutableArray *urls = [NSMutableArray array];
    for (NSDictionary *attribute in self.imagesWithAttribute) {
        [urls addObject:attribute[@"url"]];
    }
    [self.delegate showPhotos:urls atIndex:imageIndex];
}

- (void)openVideo:(UITapGestureRecognizer *)sender {
    NSUInteger videoIndex = sender.self.view.tag;
    [self.delegate openVideoWithURL:self.videos[videoIndex]];
}

- (void)openLink:(UITapGestureRecognizer *)sender {
    NSUInteger linkIndex = sender.self.view.tag;
    NSString *link = self.links[linkIndex];
    if ([link containsString:@"\">"]) {
        link = [link substringToIndex:[link rangeOfString:@"\">"].location];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"链接操作" message:link preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"复制链接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = link;
        [self.delegate showStatus:@"复制成功"];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"打开链接" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.delegate openLinkWithURL:link];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//- (void)
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
