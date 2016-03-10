//
//  ROADTitleScreen.m
//  Road
//
//  Created by Li Pan on 2016-03-02.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADTitleScreen.h"
#import "ROADReadingInterface.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ROADConstants.h"
#import "ROADColors.h"

@interface ROADTitleScreen () <UIScrollViewDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) AVAudioPlayer *backgroundMusicPlayer;
@property (nonatomic, strong) UIWebView *webViewBG;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *quoteLabel;
@property (nonatomic, strong) UILabel *currentBookLabel;

@property (nonatomic, strong) ROADColors *userColor;

@property (nonatomic, strong) UIButton *currentBookButton;
@property (nonatomic, strong) UIButton *libraryButton;
@property (nonatomic, strong) UIButton *toggleMusicButton;

@property (nonatomic, strong) UIView *currentBookLabelContainer;

@property (nonatomic, assign) BOOL musicActivated;

@end

@implementation ROADTitleScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadContent];
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *backGroundMusicPath = [[NSBundle mainBundle] pathForResource:@"Road" ofType:@"mp3"];
    NSURL *backGroundMusicURL = [NSURL fileURLWithPath:backGroundMusicPath];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backGroundMusicURL error:nil];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    //    [self.backgroundMusicPlayer prepareToPlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.webViewBG removeFromSuperview];
    self.webViewBG = nil;
}

- (void) loadContent {
    self.userColor = [[ROADColors alloc]init];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    self.scrollView.frame = self.view.frame;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView setContentOffset:CGPointMake(30, 60)];
    self.scrollView.clipsToBounds = YES;
    
    //    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"darkPaper" ofType:@"png"];
    //    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TitleScreenImage" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    self.webViewBG = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 435.0f, 770.0f)];
    NSURL *url;
    [self.webViewBG loadData:gif MIMEType:@"image/gif" textEncodingName:@"" baseURL:url];
    //    [self.webViewBG loadData:gif MIMEType:@"image/png" textEncodingName:@"" baseURL:url];
    
    self.webViewBG.userInteractionEnabled = NO;
    self.webViewBG.translatesAutoresizingMaskIntoConstraints = NO;
    self.webViewBG.alpha = kZero;
    
    [UIView animateWithDuration:2.0f animations:^{
        self.webViewBG.alpha = 1.0f;
    }];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width * kOneMinusGoldenRatioMinusOne-40, self.view.frame.size.height * kOneMinusGoldenRatioMinusOne, 70, 30)];
    self.titleLabel.font = [UIFont fontWithName:(@"American Typewriter") size:22];
    self.titleLabel.text = @"Road";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.alpha = kGoldenRatioMinusOne;
    
    UIView *dot = [[UIView alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x+65, self.view.frame.size.height * kOneMinusGoldenRatioMinusOne+15.0f, 10, 10)];
    dot.layer.borderWidth = 2.0f;
    dot.layer.borderColor = self.userColor.colorZero.CGColor;
    dot.layer.cornerRadius = 5.0f;
    
    [UIView animateKeyframesWithDuration:3.0f delay:kZero options:UIViewKeyframeAnimationOptionRepeat animations:^{
        dot.alpha = kZero;
    } completion:nil];
    
    self.quoteLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.titleLabel.frame.origin.x-40.0f, self.view.frame.size.height * kOneMinusGoldenRatioMinusOne-85.0f, 300, 100)];
    self.quoteLabel.font = [UIFont fontWithName:(@"American Typewriter") size:14];
    self.quoteLabel.text = @"Wisdom is not a product of schooling\nbut of the lifelong attempt to acquire it\n                   -Albert Einstein.";
    self.quoteLabel.textAlignment = NSTextAlignmentCenter;
    self.quoteLabel.alpha = kOneMinusGoldenRatioMinusOne;
    self.quoteLabel.numberOfLines = kZero;
    
    [UIView animateKeyframesWithDuration:30.0f delay:kZero options:UIViewKeyframeAnimationOptionRepeat animations:^{
        self.quoteLabel.frame = CGRectMake(self.titleLabel.frame.origin.x-100.0f, self.view.frame.size.height * kOneMinusGoldenRatioMinusOne-85.0f, 300, 100);
        self.quoteLabel.alpha = kOneMinusGoldenRatioMinusOne+0.2;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:30 animations:^{
            self.quoteLabel.frame = CGRectMake(self.titleLabel.frame.origin.x-40.0f, self.view.frame.size.height * kOneMinusGoldenRatioMinusOne-85.0f, 300, 100);
            self.quoteLabel.alpha = kOneMinusGoldenRatioMinusOne-0.2;
        }];
    }];
    
    self.currentBookButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-110, 415, 120, 30)];
    [self.currentBookButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.currentBookButton.backgroundColor = [UIColor blackColor];
    self.currentBookButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.currentBookButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.currentBookButton setTitle:@"current book" forState:UIControlStateNormal];
    self.currentBookButton.titleLabel.font = [UIFont fontWithName:@"American Typewriter" size:16];
    self.currentBookButton.alpha = kGoldenRatioMinusOne;
    [self.currentBookButton addTarget:self action:@selector(presentReadingInterface:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *musicIcon = [UIImage imageNamed:@"musicIcon"];
    self.toggleMusicButton = [[UIButton alloc] initWithFrame:CGRectMake(-10, 435, 40, 40)];
    self.toggleMusicButton.backgroundColor = [UIColor blackColor];
    self.toggleMusicButton.layer.cornerRadius = 20;
    self.toggleMusicButton.layer.contents = (__bridge id)musicIcon.CGImage;
    self.toggleMusicButton.alpha = kGoldenRatioMinusOne;
    [self.toggleMusicButton addTarget:self action:@selector(toggleMusic:) forControlEvents:UIControlEventTouchUpInside];
    
    self.currentBookLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-100, 446, 100, 20)];
    self.currentBookLabelContainer.backgroundColor = self.userColor.colorZero;
    self.currentBookLabelContainer.alpha = kHiddenControlRevealedAlhpa;
    self.currentBookLabelContainer.clipsToBounds = YES;
    
    self.currentBookLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    self.currentBookLabel.font = [UIFont fontWithName:@"American Typewriter" size:12];
    self.currentBookLabel.text = @"Niccolo Machiavelli - The Prince 1532 AD";
    self.currentBookLabel.textColor = [UIColor whiteColor];
    
    [UIView animateKeyframesWithDuration:15.0f delay:kZero options:UIViewKeyframeAnimationOptionRepeat animations:^{
        self.currentBookLabel.frame = CGRectMake(-300, 0, 300, 20);
    }completion:nil];
    
    self.libraryButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-110, 475, 120, 30)];
    [self.libraryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.libraryButton.backgroundColor = [UIColor blackColor];
    self.libraryButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.libraryButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    self.libraryButton.titleLabel.font = [UIFont fontWithName:@"American Typewriter" size:16];
    [self.libraryButton setTitle:@"library" forState:UIControlStateNormal];
    self.libraryButton.alpha = kGoldenRatioMinusOne;
    //    [self.libraryButton addTarget:self action:@selector(presentReadingInterface:) forControlEvents:UIControlEventTouchUpInside];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.webViewBG.frame), CGRectGetHeight(self.webViewBG.frame));
    self.scrollView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.webViewBG];
    self.scrollView.clipsToBounds = YES;
    self.scrollView.bounces = NO;
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.quoteLabel];
    [self.view addSubview:self.currentBookButton];
    [self.view addSubview:self.currentBookLabelContainer];
    [self.currentBookLabelContainer addSubview:self.currentBookLabel];
    [self.view addSubview:self.libraryButton];
    [self.view bringSubviewToFront:self.currentBookButton];
    [self.view addSubview:self.toggleMusicButton];
    [self.view bringSubviewToFront:self.toggleMusicButton];
    
    [self.view addSubview:dot];
    
    self.scrollView.delegate = self;
}

- (void)presentReadingInterface: (UIButton *)sender {
    ROADReadingInterface *readingInterface = [[ROADReadingInterface alloc] init];
    [UIView animateWithDuration:1.5f animations:^{
        self.webViewBG.alpha = kZero;
        self.currentBookButton.titleLabel.textColor = [UIColor blackColor];
        self.libraryButton.titleLabel.textColor = [UIColor blackColor];
        self.currentBookButton.backgroundColor = self.userColor.colorSix;
        self.libraryButton.backgroundColor = self.userColor.colorSix;
        self.currentBookLabelContainer.alpha = kZero;
    }];
    [UIView animateWithDuration:2.5f animations:^{
        self.libraryButton.alpha = kZero;
        self.currentBookButton.alpha = kZero;
        self.toggleMusicButton.alpha = kZero;
        self.currentBookLabel.alpha = kZero;
        self.titleLabel.alpha = kZero;
        self.quoteLabel.alpha = kZero;
    }completion:^(BOOL finished) {
        [self presentViewController:readingInterface animated:YES completion:nil];
        [self.backgroundMusicPlayer stop];
        //        [self.webViewBG removeFromSuperview];
        //        self.webViewBG = nil;
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pencil" ofType:@"png"];
        NSData *gif = [NSData dataWithContentsOfFile:filePath];
        
        self.webViewBG = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 435.0f, 770.0f)];
        NSURL *url;
        [self.webViewBG loadData:gif MIMEType:@"image/png" textEncodingName:@"" baseURL:url];
        //    [self.webViewBG loadData:gif MIMEType:@"image/png" textEncodingName:@"" baseURL:url];
    }];
}

- (void)toggleMusic: (UIButton *)button {
    NSLog(@"Music Pressed in Title Screen");
    self.musicActivated = !self.musicActivated;
    if (self.musicActivated) {
        [UIView animateWithDuration:1.0f animations:^{
            self.toggleMusicButton.backgroundColor = self.userColor.colorZero;
        }];
        [self.backgroundMusicPlayer play];
    }
    if (!self.musicActivated) {
        [UIView animateWithDuration:1.0f animations:^{
            self.toggleMusicButton.backgroundColor = [UIColor blackColor];
        }];
        [self.backgroundMusicPlayer pause];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
