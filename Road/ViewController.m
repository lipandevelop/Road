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

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *accelerationtimer;
@property (nonatomic, strong) NSTimer *deccelerationtimer;


@property (nonatomic, strong) CADisplayLink *displaylink;

//Data

@property (nonatomic, strong) NSString *bookTextString;
@property (nonatomic, strong) NSMutableArray *wordsArray;

//UI
@property (nonatomic, strong) UILabel *focusText;
@property (nonatomic, strong) CATextLayer *focusTextLayer;

//RunTime
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) int wordIndex;

//Speed
@property (nonatomic, assign) float acceleration;
@property (nonatomic, assign) float baseSpeed;
@property (nonatomic, assign) float currentSpeed;
@property (nonatomic, assign) float maxSpeed;

@property (nonatomic, assign) NSTimeInterval timeIntervalBetweenIndex;

@property (nonatomic, assign) BOOL accelerationBegan;

//Interaction
@property (nonatomic, strong) UILongPressGestureRecognizer *gasPedal;


@end

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated {
    //    self.displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    //    [self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.timer invalidate];
    self.timer = nil;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBook];
    
    
    self.timeIntervalBetweenIndex = 0.5;
    
    self.acceleration = 0.0f;
    self.baseSpeed = 0.5f;
    self.maxSpeed = 0.3f;
    self.accelerationBegan = NO;
    UIImage *paper = [UIImage imageNamed:@"ivoryPaper.png"];
    self.view.layer.contents = (__bridge id)paper.CGImage;
    
    //    UILabel *dot = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.view.frame), CGRectGetMaxY(self.view.frame)*(1-0.61803398875f), CGRectGetWidth(self.view.frame)*1.38196601125, 30.0f)];
    
    UILabel *dot = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.68903398875f, CGRectGetMaxY(self.view.frame)*(1-0.57603398875f), 4.5f, 4.5f)];
    dot.layer.cornerRadius = 3.0f;
    dot.layer.borderWidth = 1.5f;
    dot.clipsToBounds = YES;
    dot.layer.borderColor = [UIColor colorWithRed:195.0f/255.0f green:25.0f/255.0f blue:25.0f/255.0f alpha:0.7f].CGColor;
    
    [UIView animateWithDuration:self.timeIntervalBetweenIndex delay:0.0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
        dot.alpha = 0.0;
    } completion:nil];
    
    [self.view addSubview:dot];
    
    
    
    
    
    //    self.view.backgroundColor = [UIColor colorWithRed:208.0f/255.0f green:178.0f/255.0f blue:118.0f/255.0f alpha:1.0f];
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
    
    //    self.wordIndex = ((self.displaylink.timestamp - self.startTime)/(self.baseSpeed + self.acceleration));
    //
    //    if (self.acceleration >= self.baseSpeed - 0.01) {
    //        self.acceleration = self.baseSpeed;
    //    } else if (self.currentSpeed >= self.baseSpeed) {
    //        self.acceleration = 0;
    //    }
    //
    //    if (self.accelerationBegan) {
    //        self.acceleration -= 0.001;
    //    } else if (!self.accelerationBegan) {
    //
    //        self.acceleration += 0.005;
    //    }
    
    
    self.wordIndex ++;
    self.focusText.text = [self.wordsArray objectAtIndex:self.wordIndex];
    if (self.wordIndex == self.wordsArray.count) {
        self.displaylink.paused = YES;
    }
    
    self.currentSpeed = self.baseSpeed + self.acceleration;
    
//    NSLog(@"%d, %0.2f, %0.3f", self.wordIndex, self.acceleration, self.currentSpeed);
    //    NSLog(@"%d", self.wordsArray.count);
}

- (void)modifyTimeInterval: (float)time {

    self.timeIntervalBetweenIndex += time;
    
    self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, 0.05f);
    self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, 0.49f);
    NSLog(@"%f", self.timeIntervalBetweenIndex);
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:YES];
}

-(void)modifySpeed {
    if (self.accelerationBegan) {
        [self modifyTimeInterval:-0.1];
    } else if (!self.accelerationBegan) {
            [self modifyTimeInterval:+0.01];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.accelerationBegan = YES;
    self.accelerationtimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Began %d", self.accelerationBegan);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.accelerationBegan = NO;
    [self.accelerationtimer invalidate];
    self.accelerationtimer = nil;
    self.accelerationtimer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    
    NSLog(@"Ended %d", self.accelerationBegan);
}

@end
