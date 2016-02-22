//
//  ViewController.m
//  Road
//
//  Created by Li Pan on 2016-02-19.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ViewController.h"
#import "KFEpubController.h"
#import "KFEpubContentModel.h"

@interface ViewController () <KFEpubControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate>
@property (nonatomic, strong) KFEpubController *epubController;
@property (nonatomic, strong) KFEpubContentModel *contentModel;
@property (nonatomic, strong) UIWebView *bookContentView;
@property (nonatomic, assign) NSUInteger spineIndex;

@property (nonatomic, strong) CADisplayLink *displaylink;

//Data

@property (nonatomic, strong) NSString *bookTextString;
@property (nonatomic, strong) NSMutableArray *wordsArray;

//UI
@property (nonatomic, strong) UILabel *focusText;
@property (nonatomic, strong) CATextLayer *focusTextLayer;

//RunTime
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval timeIntervalBetweenIndex;
@property (nonatomic, assign) int wordIndex;

@property (nonatomic, assign) BOOL accelerationBegan;
@property (nonatomic, assign) BOOL breakingBegan;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *accelerationtimer;
@property (nonatomic, strong) NSTimer *deccelerationtimer;

//Speeds
@property (nonatomic, assign) float maxSpeed;
@property (nonatomic, assign) float minSpeed;
@property (nonatomic, assign) float acceleration;
@property (nonatomic, assign) float deceleration;


//Interaction
@property (nonatomic, strong) UIView *breakPedal;
@property (nonatomic, strong) UILabel *dot;
@property (nonatomic, strong) UILongPressGestureRecognizer *breakPedalGesture;
@property (nonatomic, assign) CGRect breakPedalFrame;

@end

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated {
    self.displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrame)];
    [self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.timer invalidate];
    self.timer = nil;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.timer invalidate];
    self.timer = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBook];
    
    self.minSpeed = 0.5;
    self.maxSpeed = 0.1;
    self.acceleration = 0.05;
    self.deceleration = 0.005;
    self.timeIntervalBetweenIndex = self.minSpeed;
    self.accelerationBegan = NO;
    
    UIImage *paper = [UIImage imageNamed:@"ivoryPaper.png"];
    UIImage *breakPedal = [UIImage imageNamed:@"finger_noise.png"];
    
    self.view.layer.contents = (__bridge id)paper.CGImage;
    
    
    self.dot = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.68903398875f, CGRectGetMaxY(self.view.frame)*(1-0.57603398875f), 4.5f, 4.5f)];
    self.dot.layer.cornerRadius = 3.0f;
    self.dot.layer.borderWidth = 1.5f;
    self.dot.clipsToBounds = YES;
    self.dot.layer.borderColor = [UIColor colorWithRed:195.0f/255.0f green:25.0f/255.0f blue:25.0f/255.0f alpha:0.7f].CGColor;
    [self.view addSubview:self.dot];
    
    self.breakPedalGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(breaking)];
    self.breakPedalFrame = CGRectMake(CGRectGetWidth(self.view.frame)*0.38196601125, CGRectGetMaxY(self.view.frame)/1.61803398875, 220.0f, 220.0f);
    CGAffineTransform pedalPosition = CGAffineTransformIdentity;
    pedalPosition = CGAffineTransformScale(pedalPosition, 0.50f, 0.50f);
    pedalPosition = CGAffineTransformRotate(pedalPosition, M_PI/180.0 * -37);
    pedalPosition = CGAffineTransformTranslate(pedalPosition, 50.0f, 0.0f);
    self.breakPedal = [[UIView alloc]initWithFrame:self.breakPedalFrame];
    self.breakPedal.layer.contents = (__bridge id)breakPedal.CGImage;
    self.breakPedal.layer.opacity = 0.2f;
    self.breakPedal.layer.affineTransform = pedalPosition;
    self.breakPedal.layer.shadowColor = [UIColor blackColor].CGColor;
    
    [self.breakPedal addGestureRecognizer:self.breakPedalGesture];
    
    [self.view addSubview:self.breakPedal];
    
}

- (void)loadBook {
    NSURL *epubURL = [[NSBundle mainBundle] URLForResource:@"thePrince" withExtension:@"epub"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    self.epubController = [[KFEpubController alloc] initWithEpubURL:epubURL andDestinationFolder:documentsURL];
    self.epubController.delegate = self;
    [self.epubController openAsynchronous:YES];
    self.bookContentView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.bookContentView.delegate = self;
    
    UISwipeGestureRecognizer *swipeRecognizer;
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizer.delegate = self;
    [self.bookContentView addGestureRecognizer:swipeRecognizer];
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizer.delegate = self;
    //    [self.view addSubview:self.bookContentView];
    [self.bookContentView addGestureRecognizer:swipeRecognizer];
}

#pragma mark Changing Chapters
- (void)didSwipeRight:(UIGestureRecognizer *)recognizer {
    if (self.spineIndex > 1) {
        self.spineIndex--;
        [self updateContentForSpineIndex:self.spineIndex];
    }
}

- (void)didSwipeLeft:(UIGestureRecognizer *)recognizer {
    if (self.spineIndex < self.contentModel.spine.count) {
        self.spineIndex++;
        [self updateContentForSpineIndex:self.spineIndex];
    }
}

- (void)updateContentForSpineIndex:(NSUInteger)currentSpineIndex {
    NSString *contentFile = self.contentModel.manifest[self.contentModel.spine[currentSpineIndex]][@"href"];
    NSURL *contentURL = [self.epubController.epubContentBaseURL URLByAppendingPathComponent:contentFile];
    NSLog(@"content URL :%@", contentURL);
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:contentURL];
    [self.bookContentView loadRequest:request];
}

#pragma mark KFEpubControllerDelegate Methods


- (void)epubController:(KFEpubController *)controller willOpenEpub:(NSURL *)epubURL
{
    NSLog(@"will open epub");
}
- (void)epubController:(KFEpubController *)controller didOpenEpub:(KFEpubContentModel *)contentModel
{
    NSLog(@"opened: %@", contentModel.metaData[@"title"]);
    self.contentModel = contentModel;
    self.spineIndex = 4;
    [self updateContentForSpineIndex:self.spineIndex];
}

- (void)epubController:(KFEpubController *)controller didFailWithError:(NSError *)error {
    NSLog(@"epubController:didFailWithError: %@", error.description);
}

#pragma mark UIGestureRecognizerDelegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark WebViewDelegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self convertBookToString];
    [self loadText];
}

#pragma mark Converting To String

- (void)convertBookToString {
    NSString *txt = [self.bookContentView stringByEvaluatingJavaScriptFromString:@"document.body.textContent"];
    NSString *newString = [[txt componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    
    self.bookTextString = newString;
    //    NSLog(@"%@", self.bookTextString);
    
}

- (void)loadText {
    self.startTime = CACurrentMediaTime();
    
    
    //Label
    self.focusText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.38196601125, CGRectGetMaxY(self.view.frame)*(1-0.61803398875f), 200, 30.0f)];
    //    self.focusText.layer.shadowOffset = CGSizeMake(0, 1);
    //    self.focusText.layer.shadowRadius = 2.5f;
    //    self.focusText.layer.shadowOpacity = 0.3;
    self.focusText.numberOfLines = 0;
    self.focusText.text = self.bookTextString;
    self.focusText.font = [UIFont fontWithName:(@"AmericanTypewriter") size:16];
    self.focusText.textColor = [UIColor colorWithRed:110.0f/255.0f green:20.0f/255.0f blue:20.0f/255.0f alpha:1.0f];
    self.focusText.textColor = [UIColor blackColor];
    self.focusText.alpha = 0.61803398875;
    self.focusText.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.focusText];
    
    //Label Layer
    self.focusTextLayer.contents = self.bookTextString;
    self.focusTextLayer.zPosition = 1;
    [self.focusText.layer addSublayer:self.focusTextLayer];
    
    NSArray *words = [self.bookTextString componentsSeparatedByString: @" "];
    self.wordsArray = [NSMutableArray arrayWithCapacity:[words count]];
    [self.wordsArray addObjectsFromArray:words];
    
    
    
    //    NSLog(@"%@", self.wordsArray);
    
    //Modify string color
    
    //    NSMutableAttributedString *text =
    //    [[NSMutableAttributedString alloc]
    //     initWithAttributedString: label.attributedText];
    //
    //    [text addAttribute:NSForegroundColorAttributeName
    //                 value:[UIColor redColor]
    //                 range:NSMakeRange(10, 1)];
    //    [label setAttributedText: text];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)update {
    if (self.timeIntervalBetweenIndex < 1) {
        self.wordIndex ++;
    } else if (self.timeIntervalBetweenIndex >= 1) {
        self.wordIndex --;
    }
    self.focusText.text = [self.wordsArray objectAtIndex:self.wordIndex];
    if (self.wordIndex == self.wordsArray.count) {
        self.displaylink.paused = YES;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:NO];
    //    NSLog(@"%d, %lu, %0.2f", self.wordIndex, (unsigned long)self.wordsArray.count, self.timeIntervalBetweenIndex);
    
    self.dot.alpha = 0.8;
    [UIView animateWithDuration:self.timeIntervalBetweenIndex delay:0.0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
        self.dot.alpha = 0.0;
    } completion:nil];
}

- (void)modifyTimeInterval: (float)time {
    if (!self.breakingBegan) {
        self.timeIntervalBetweenIndex += time;
        self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, self.maxSpeed);
        self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, self.minSpeed);
    } else if (self.breakingBegan) {
        self.timeIntervalBetweenIndex += time;
        self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, self.maxSpeed);
        self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, 1.10f);
    }
        NSLog(@"%f %d", self.timeIntervalBetweenIndex, self.wordIndex);
    
//    if (self.timeIntervalBetweenIndex >= 0.50f) {
//        [self.deccelerationtimer invalidate];
//        self.deccelerationtimer = nil;
//    }
}

- (void)updateFrame {
    if (self.breakPedalGesture.state == UIControlEventTouchDown) {
        [UIView animateWithDuration:4.0f animations:^{
            self.breakPedal.alpha = 0.50f;
            self.breakPedal.layer.shadowOpacity = 2.60f;
            self.breakPedal.layer.shadowOffset = CGSizeMake(2.0f, 5.0f);
            self.breakPedal.layer.shadowRadius = 30.0f;
        }];
        
    } else if (!self.breakPedalGesture.state == UIControlEventTouchDown) {
        self.breakPedal.alpha = MAX(self.breakPedal.alpha, 0.2);
        self.breakPedal.alpha -= 0.01f;
        self.breakPedal.layer.shadowOpacity -= 0.1f;
        self.breakPedal.layer.shadowOpacity = MIN(self.breakPedal.layer.shadowOpacity, 0.0);
        self.breakPedal.layer.shadowRadius -= 0.5f;
        self.breakPedal.layer.shadowRadius = MIN(self.breakPedal.layer.shadowRadius, 0.0);
    }
}

- (void)modifySpeed {
    if (self.accelerationBegan) {
        [self modifyTimeInterval:-self.acceleration];
    } else if (!self.accelerationBegan) {
        [self modifyTimeInterval:+self.deceleration];
    }
}

- (void)startBreaking {
    [self modifyTimeInterval:+0.020];
    NSLog(@"%f", self.timeIntervalBetweenIndex);
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.accelerationBegan = YES;
    self.accelerationtimer = [NSTimer scheduledTimerWithTimeInterval: 0.10f target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Began %d", self.accelerationBegan);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.accelerationBegan = NO;
    [self.accelerationtimer invalidate];
    self.accelerationtimer = nil;
    self.deccelerationtimer = [NSTimer scheduledTimerWithTimeInterval: 0.10f target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Ended %d", self.accelerationBegan);
}

-(void)breaking {
    if (self.breakPedalGesture.state == UIControlEventTouchDown) {
        NSLog(@"break");
        self.accelerationBegan = NO;
        [self.accelerationtimer invalidate];
        self.accelerationtimer = nil;
        self.breakingBegan = YES;
        self.deccelerationtimer = [NSTimer scheduledTimerWithTimeInterval: 0.10f target:self selector:@selector(startBreaking) userInfo:nil repeats:YES];
        NSLog(@"%f", self.timeIntervalBetweenIndex);
        
    } if (self.breakPedalGesture.state == UIGestureRecognizerStateEnded) {
        NSLog(@"break ended");
        self.breakingBegan = NO;
        self.deccelerationtimer = [NSTimer scheduledTimerWithTimeInterval: 0.10f target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    }
    
    
}

@end
