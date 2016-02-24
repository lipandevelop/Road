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

typedef NS_ENUM(NSInteger, SpeedAdjustmentSegmentSelected) {
    NormalSpeed,
    MaximumSpeed,
    MinimumSpeed,
    AccelerationSpeed,
    DecelerationSpeed,
};

typedef NS_ENUM(NSInteger, ModifyColorForTextActivated) {
    Vowels,
    Consonants,
    UserSelection,
};



@interface ViewController () <KFEpubControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, UITextFieldDelegate>
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
@property (nonatomic, strong) UILabel *previousWord;
@property (nonatomic, strong) UILabel *nextWord;
@property (nonatomic, strong) UILabel *assistantText;
@property (nonatomic, strong) CATextLayer *focusTextLayer;

//RunTime
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval timeIntervalBetweenIndex;
@property (nonatomic, assign) int wordIndex;

@property (nonatomic, assign) BOOL accelerationBegan;
@property (nonatomic, assign) BOOL breakingBegan;
@property (nonatomic, assign) BOOL highlightVowelsActivated;
@property (nonatomic, assign) BOOL highlightConsonantsActivated;
@property (nonatomic, assign) BOOL highlightUserSelectionActivated;
@property (nonatomic, assign) BOOL highlightColorSelected;

@property (nonatomic, assign) BOOL hideControlsActivated;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *accelerationtimer;
@property (nonatomic, strong) NSTimer *deccelerationtimer;
@property (nonatomic, strong) NSTimer *breaktimer;


//Speeds
@property (nonatomic, assign) float normalSpeed;
@property (nonatomic, assign) float maxSpeed;
@property (nonatomic, assign) float minSpeed;
@property (nonatomic, assign) float acceleration;
@property (nonatomic, assign) float deceleration;
@property (nonatomic, assign) float speedShown;

//SpeedLabels
@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UILabel *speedometerReadLabel;


//Interaction
@property (nonatomic, strong) UIView *breakPedal;
@property (nonatomic, strong) UILabel *dot;
@property (nonatomic, strong) UILongPressGestureRecognizer *breakPedalGesture;
@property (nonatomic, assign) CGRect breakPedalFrame;
@property (nonatomic, strong) UIButton *hideControlButton;
@property (nonatomic, strong) UIButton *toggleConsonates;
@property (nonatomic, strong) UIButton *toggleVowels;
@property (nonatomic, strong) UIButton *toggleUserSelections;
@property (nonatomic, strong) UILongPressGestureRecognizer *openColorOptionsGesture;

@property (nonatomic, strong) UISlider *speedAdjusterSlider;
@property (nonatomic, strong) UIView *pinView;

@property (nonatomic, strong) UISegmentedControl *speedPropertySelector;
@property (nonatomic, strong) UITextField *userSelectedTextTextField;


@property (nonatomic, assign) float colorAdjusterValue;

//Colors
@property (nonatomic, strong) UIColor *highlightVowelColor;
@property (nonatomic, strong) UIColor *highlightConsonantColor;
@property (nonatomic, strong) UIColor *highlightUserSelectedTextColor;
@property (nonatomic, strong) UIColor *highlightColorThree;
@property (nonatomic, strong) UIColor *highlightColorFour;
@property (nonatomic, strong) UIColor *highlightColorFive;


@property (nonatomic, strong) UIColor *defaultButtonColor;

//Frames
@property (nonatomic, assign) CGRect highlightButtonLocationFrames;

//Strings
@property (nonatomic, strong) NSString *userInputForHighlightedTextString;
@property (nonatomic, strong) NSString *selectedSpeedToAdjustIndicator;

//Arrays
@property (nonatomic, strong) NSArray *speedArray;

//Palette
@property (nonatomic, strong) UIButton *color1;
@property (nonatomic, strong) UIButton *color2;
@property (nonatomic, strong) UIButton *color3;
@property (nonatomic, strong) UIButton *color4;
@property (nonatomic, strong) UIButton *color5;

@property (nonatomic, assign) float colorPaletteXOrigin;
@property (nonatomic, assign) float colorPaletteYOrigin;

@property (nonatomic, assign) ModifyColorForTextActivated textColorBeingModified;





@end

@implementation ViewController

static const float kUpdateSpeed = 0.1f;
//static const CGSize kShadowSize = CGSizeMake(-1.0, 6.0);
static const float kShadowOpacity = 0.35f;
static const float kBoarderWidth = 1.5f;
static const float kMoney = 1000000000.00f;
static const float kGoldenRatio = 1.61803398875;
static const float kGoldenRatioMinusOne = 0.68903398875f;
static const float kOneMinusGoldenRatioMinusOne = 0.38196601125;
static const float kSmallFontSize = 10.0f;
static const float kHiddenControlRevealedAlhpa = 0.7f;
static const float kZero = 0.0f;
static const float kUINormaAlpha = 0.45f;

//PaletteConstants
static const float kColorPaletteheightMultiple = kGoldenRatioMinusOne;
static const float kColorPaletteXOrigin = -35.0f;
static const float kColorPaletteWidth = 23.0f;
static const float kColorPaletteHeight = 15.0f;

NSString *const kVowels = @"aeiouAEIOU";
NSString *const kConsonants = @"bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ";


- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidAppear:(BOOL)animated {
    self.displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrame)];
    [self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self.timer invalidate];
    self.timer = nil;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadBook];
    [self loadValues];
    [self loadUIContents];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark Loading Contents

- (void)loadValues {
    self.normalSpeed = 0.45;
    self.minSpeed = 1.0;
    self.maxSpeed = 0.15;
    self.acceleration = 0.002;
    self.deceleration = 0.0007;
    self.timeIntervalBetweenIndex = self.normalSpeed;
    self.accelerationBegan = NO;
    self.highlightVowelsActivated = NO;
    self.highlightConsonantsActivated = NO;
    self.hideControlsActivated = YES;
    self.colorAdjusterValue = 254.0;
    
    self.highlightConsonantColor = [UIColor colorWithRed:136.0f/255.0f green:14.0f/255.0f blue:79.0f/255.0f alpha:1.0f];
    self.highlightVowelColor = [UIColor colorWithRed:254.0f/255.0f green:82.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
    self.highlightUserSelectedTextColor = [UIColor colorWithRed:253.0f/255.0f green:196.0f/255.0f blue:2.0f/255.0f alpha:1.0f];
    self.defaultButtonColor = [UIColor colorWithRed:98.0f/255.0f green:91.0f/255.0f blue:77.0f/255.0f alpha:1.0f];
    self.highlightColorThree = [UIColor colorWithRed:11.0f/255.0f green:73.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
    self.highlightColorFour = [UIColor colorWithRed:243.0f/255.0f green:131.0f/255.0f blue:121.0f/255.0f alpha:1.0f];
    self.highlightColorFive = [UIColor colorWithRed:71.0f/255.0f green:215.0f/255.0f blue:193.0f/255.0f alpha:1.0f];
    
    self.speedArray = [NSArray arrayWithObjects: @"norm speed", @"max speed", @"min speed", @"accel", @"decel", nil];
    
}

- (void)loadUIContents {
    UIImage *paper = [UIImage imageNamed:@"ivoryPaper.png"];
    UIImage *breakPedal = [UIImage imageNamed:@"finger_clean.png"];
    UIImage *speedometerImage = [UIImage imageNamed:@"Speedometer.png"];
    UIImage *pinImage= [UIImage imageNamed:@"Pin.png"];
    
    UIImage *consonantImage = [UIImage imageNamed:@"Consonant.png"];
    UIImage *vowelImage = [UIImage imageNamed:@"Vowel.png"];
    UIImage *userSelectImage = [UIImage imageNamed:@"User.png"];
    
    self.view.layer.contents = (__bridge id)paper.CGImage;
    
    UIView *speedometerView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-70, 65, 140, 140)];
    speedometerView.layer.contents = (__bridge id)speedometerImage.CGImage;
    speedometerView.layer.contentsGravity = kCAGravityResizeAspect;
    speedometerView.alpha = 0.15f;
    
    UIImageView *pinImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 400, 400)];
    pinImageView.image = [UIImage imageNamed:@"Pin.png"];
    
    
    self.pinView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-5.1f, 100.0f, 15.0f, 70.0f)];
    self.pinView.layer.contents = (__bridge id)pinImage.CGImage;
    self.pinView.layer.contentsGravity = kCAGravityResizeAspect;
    self.pinView.layer.shadowOffset = CGSizeMake(-1.0, 4.0);
    self.pinView.layer.shadowOpacity = kShadowOpacity;
    
    self.speedometerReadLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-27, 149.0f, 60, 15)];
    //    self.speedometerReadLabel.layer.borderWidth = 0.75;
    self.speedometerReadLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    self.speedometerReadLabel.alpha = kUINormaAlpha;
    self.speedometerReadLabel.textAlignment = NSTextAlignmentCenter;
    
    
    
    self.dot = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*kGoldenRatioMinusOne, CGRectGetMaxY(self.view.frame)*(0.43), 8.0f, 8.0f)];
    self.dot.layer.cornerRadius = 4.0f;
    self.dot.layer.borderWidth = kBoarderWidth;
    self.dot.clipsToBounds = YES;
    self.dot.layer.borderColor = [UIColor colorWithRed:195.0f/255.0f green:25.0f/255.0f blue:25.0f/255.0f alpha:0.8f].CGColor;
    
    self.hideControlButton =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*kGoldenRatioMinusOne, CGRectGetMaxY(self.view.frame)/1.15203398875, 35.0f, 35.0f)];
    self.hideControlButton.layer.borderWidth = kBoarderWidth;
    self.hideControlButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.hideControlButton.titleLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    self.hideControlButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.hideControlButton.alpha = kUINormaAlpha;
    self.hideControlButton.layer.cornerRadius = self.hideControlButton.frame.size.width/2;
    [self.hideControlButton addTarget:self action:@selector(hideControls) forControlEvents:UIControlEventTouchUpInside];
    
    self.breakPedalGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(breaking)];
    self.breakPedalGesture.minimumPressDuration = 0.01;
    self.breakPedalFrame = CGRectMake(CGRectGetWidth(self.view.frame)*0.38196601125, CGRectGetMaxY(self.view.frame)/kGoldenRatio, 220.0f, 220.0f);
    CGAffineTransform pedalPosition = CGAffineTransformIdentity;
    pedalPosition = CGAffineTransformScale(pedalPosition, 0.50f, 0.50f);
    pedalPosition = CGAffineTransformRotate(pedalPosition, M_PI/180.0 * -37);
    pedalPosition = CGAffineTransformTranslate(pedalPosition, 50.0f, kZero);
    self.breakPedal = [[UIView alloc]initWithFrame:self.breakPedalFrame];
    self.breakPedal.layer.contents = (__bridge id)breakPedal.CGImage;
    self.breakPedal.layer.opacity = 0.2f;
    self.breakPedal.layer.affineTransform = pedalPosition;
    self.breakPedal.layer.shadowColor = [UIColor blackColor].CGColor;
    [self.breakPedal addGestureRecognizer:self.breakPedalGesture];
    
    self.openColorOptionsGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(openColorPalette:)];
    self.openColorOptionsGesture.minimumPressDuration = 0.50f;
    
    self.highlightButtonLocationFrames = CGRectMake(100, CGRectGetHeight(self.view.frame) - 95, 25, 25);
    self.toggleVowels = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.toggleVowels addTarget:self action:@selector(toggleVowelsSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.toggleVowels buttonLayer:self.toggleVowels.layer color: self.defaultButtonColor image:vowelImage];
    self.toggleVowels.layer.affineTransform = CGAffineTransformMakeTranslation(-45, -40);
    
    self.toggleConsonates = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.toggleConsonates addTarget:self action:@selector(toggleConsonantsSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.toggleConsonates buttonLayer:self.toggleConsonates.layer color:self.defaultButtonColor image:consonantImage];
    
    self.toggleUserSelections = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.toggleUserSelections addTarget:self action:@selector(toggleUserSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.toggleUserSelections buttonLayer:self.toggleUserSelections.layer color:self.defaultButtonColor image:userSelectImage];
    self.toggleUserSelections.layer.affineTransform = CGAffineTransformMakeTranslation(-65, -100);
    
    self.speedAdjusterSlider = [[UISlider alloc]initWithFrame:CGRectMake(160, 360, 120, 30)];
    [self.speedAdjusterSlider addTarget:self action:@selector(adjustSpeedUsingSlider:) forControlEvents:UIControlEventValueChanged];
    self.speedAdjusterSlider.layer.affineTransform = CGAffineTransformRotate(self.speedAdjusterSlider.layer.affineTransform, M_PI/180.0 * -40);
    self.speedAdjusterSlider.tintColor = self.defaultButtonColor;
    self.speedAdjusterSlider.alpha = kZero;
    self.speedAdjusterSlider.value = 1/self.normalSpeed;
    
    self.speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(164, 320, 220, 60)];
    self.speedLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    self.speedLabel.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.speedLabel.layer.shadowOpacity = kShadowOpacity;
    self.speedLabel.numberOfLines = kZero;
    self.speedLabel.alpha = kZero;
    
    self.speedPropertySelector = [[UISegmentedControl alloc]initWithItems:self.speedArray];
    self.speedPropertySelector.frame = CGRectMake(kZero, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 30);
    self.speedPropertySelector.selectedSegmentIndex = kZero;
    self.speedPropertySelector.layer.borderWidth = kBoarderWidth;
    self.speedPropertySelector.layer.borderColor = [UIColor blackColor].CGColor;
    self.speedPropertySelector.tintColor = [UIColor blackColor];
    self.speedPropertySelector.alpha = kUINormaAlpha;
    [self.speedPropertySelector addTarget:self action:@selector(speedPropertySelectorSwitch:) forControlEvents:UIControlEventValueChanged];
    UIFont *speedControlfont = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    NSDictionary *speedAttributes = [NSDictionary dictionaryWithObject:speedControlfont forKey:NSFontAttributeName];
    [self.speedPropertySelector setTitleTextAttributes:speedAttributes forState:UIControlStateNormal];
    
    self.userSelectedTextTextField = [[UITextField alloc]initWithFrame:CGRectMake(-145.0f, self.toggleUserSelections.frame.origin.y-30.0f, 145.0f, kColorPaletteHeight)];
    self.userSelectedTextTextField.layer.borderWidth = 0.75;
    self.userSelectedTextTextField.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:kUINormaAlpha].CGColor;
    self.userSelectedTextTextField.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.userSelectedTextTextField.layer.shadowOpacity = kShadowOpacity;
//    self.userSelectedTextTextField.alpha = kUINormaAlpha;
    self.userSelectedTextTextField.placeholder = @"Customize";
    self.userSelectedTextTextField.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    self.color1 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, CGRectGetHeight(self.view.frame)*kColorPaletteheightMultiple, kColorPaletteWidth, kColorPaletteHeight)];
    self.userSelectedTextTextField.delegate = self;
    self.color1.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color1.layer.shadowOpacity = kShadowOpacity;
    self.color1.backgroundColor = self.highlightColorFive;
    
    self.color2 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.color2.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color2.layer.shadowOpacity = kShadowOpacity;
    self.color2.backgroundColor = self.highlightColorThree;
    
    self.color3 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.color3.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color3.layer.shadowOpacity = kShadowOpacity;
    self.color3.backgroundColor = self.highlightConsonantColor;
    
    self.color4 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.color4.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color4.backgroundColor = self.highlightVowelColor;
    
    self.color5 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth*2, kColorPaletteHeight)];
    self.color5.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color5.layer.shadowOpacity = kShadowOpacity;
    self.color5.backgroundColor = self.highlightUserSelectedTextColor;
    self.color5.layer.cornerRadius = 4.0;
    
    [self.view addSubview:self.dot];
    [self.view addSubview:self.speedAdjusterSlider];
    [self.view addSubview:self.breakPedal];
    [self.view addSubview:self.hideControlButton];
    [self.view addSubview:self.pinView];
    [self.view addSubview:self.speedometerReadLabel];
    [self.view addSubview:speedometerView];
    
    [self.view setNeedsDisplay];
}

#pragma mark Modify Toggle Buttons

- (void)modifyToggleButtonWithButton: (UIButton *)button buttonLayer:(CALayer *)layer color: (UIColor*)color image: (UIImage *)image {
    layer.cornerRadius = button.frame.size.width/2;
    layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    layer.shadowOpacity = kShadowOpacity;
    layer.zPosition = 1.0f;
    layer.contents = (__bridge id)image.CGImage;
    button.alpha = kZero;
    button.backgroundColor = color;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:button];
    
}

- (void)loadBook {
    NSURL *epubURL = [[NSBundle mainBundle] URLForResource:@"thePrince" withExtension:@"epub"];
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    self.epubController = [[KFEpubController alloc] initWithEpubURL:epubURL andDestinationFolder:documentsURL];
    self.epubController.delegate = self;
    [self.epubController openAsynchronous:YES];
    self.bookContentView = [[UIWebView alloc]initWithFrame:CGRectMake(kZero, 50, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)/4)];
    self.bookContentView.delegate = self;
    //    [self.view addSubview:self.bookContentView];
    
    UISwipeGestureRecognizer *swipeRecognizer;
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRecognizer.delegate = self;
    [self.bookContentView addGestureRecognizer:swipeRecognizer];
    
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRecognizer.delegate = self;
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
    self.focusText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*kOneMinusGoldenRatioMinusOne, CGRectGetMaxY(self.view.frame)*kOneMinusGoldenRatioMinusOne, 200, 30.0f)];
    self.focusText.numberOfLines = kZero;
    self.focusText.text = self.bookTextString;
    self.focusText.font = [UIFont fontWithName:(@"AmericanTypewriter") size:24];
    self.focusText.textColor = [UIColor colorWithRed:110.0f/255.0f green:20.0f/255.0f blue:20.0f/255.0f alpha:1.0f];
    self.focusText.textColor = [UIColor blackColor];
    self.focusText.alpha = kGoldenRatioMinusOne;
    self.focusText.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.focusText];
    
    //Label Layer
    self.focusTextLayer.contents = self.bookTextString;
    self.focusTextLayer.zPosition = 1.0f;
    [self.focusText.layer addSublayer:self.focusTextLayer];
    
    NSArray *words = [self.bookTextString componentsSeparatedByString: @" "];
    self.wordsArray = [NSMutableArray arrayWithCapacity:[words count]];
    [self.wordsArray addObjectsFromArray:words];
    //    NSLog(@"%@", self.wordsArray);
    
//    self.previousWord = [[UILabel alloc]initWithFrame:CGRectMake(45, CGRectGetMaxY(self.view.frame)*kOneMinusGoldenRatioMinusOne, 200, 30.0f)];
//    self.previousWord.numberOfLines = kZero;
//    self.previousWord.text = self.bookTextString;
//    self.previousWord.font = [UIFont fontWithName:(@"AmericanTypewriter") size:24];
//    self.previousWord.textColor = [UIColor colorWithRed:110.0f/255.0f green:20.0f/255.0f blue:20.0f/255.0f alpha:1.0f];
//    self.previousWord.textColor = [UIColor blackColor];
//    self.previousWord.alpha = kGoldenRatioMinusOne;
//    self.previousWord.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:self.previousWord];
//    
}

- (void)update {
    float angle = -(self.timeIntervalBetweenIndex *4.5)+8.5f;
    angle = MAX(angle, 4.75);
    angle = MIN(angle, 8.0);
    //    NSLog(@"%f", angle);
    self.speedometerReadLabel.text = [NSString stringWithFormat:@"%0.1fwpm",1/self.timeIntervalBetweenIndex*60];
    self.pinView.layer.affineTransform = CGAffineTransformMakeRotation(angle);
    if (self.timeIntervalBetweenIndex == self.normalSpeed) {
        [self.deccelerationtimer invalidate];
        self.deccelerationtimer = nil;
    }
    if (self.timeIntervalBetweenIndex < self.minSpeed) {
        self.wordIndex ++;
    } else if (self.timeIntervalBetweenIndex >= self.minSpeed) {
        self.wordIndex --;
    }
    self.focusText.text = [self.wordsArray objectAtIndex:self.wordIndex];
    
    if (self.highlightVowelsActivated) {
        [self highlightVowels];
    }
    
    if (self.highlightConsonantsActivated) {
        [self highlightConsonants];
    }
    
    if (self.highlightUserSelectionActivated) {
        [self highlightUserSelected];
    }
    
    if (self.wordIndex == self.wordsArray.count) {
        self.displaylink.paused = YES;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:NO];
    //        NSLog(@"%d, %lu, %0.2f", self.wordIndex, (unsigned long)self.wordsArray.count, self.timeIntervalBetweenIndex);
    
    self.dot.alpha = 0.8;
    [UIView animateWithDuration:self.timeIntervalBetweenIndex delay:kZero options:UIViewKeyframeAnimationOptionRepeat animations:^{
        self.dot.alpha = kZero;
    } completion:nil];
    //insert if statement
}

- (void)modifyTimeInterval: (float)time {
    if (!self.breakingBegan) {
        self.timeIntervalBetweenIndex += time;
        self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, self.maxSpeed);
        self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, self.normalSpeed);
    } else if (self.breakingBegan) {
        self.timeIntervalBetweenIndex += time;
        self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, self.maxSpeed);
        self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, self.minSpeed + 0.10f);
    }
    //        NSLog(@"%f %d", self.timeIntervalBetweenIndex, self.wordIndex);
}

- (void)updateFrame {
    NSLog(@"%@,%@", self.userSelectedTextTextField.text, self.userInputForHighlightedTextString);
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
        self.breakPedal.layer.shadowOpacity = MIN(self.breakPedal.layer.shadowOpacity, kZero);
        self.breakPedal.layer.shadowRadius -= 0.5f;
        self.breakPedal.layer.shadowRadius = MIN(self.breakPedal.layer.shadowRadius, kZero);
    }
}


#pragma mark Focus Text Methods

- (void)modifySpeed {
    if (self.accelerationBegan) {
        //        NSLog(@"Accelerating!...");
        [self modifyTimeInterval:-self.acceleration];
    } else if (!self.accelerationBegan) {
        //        NSLog(@"Decelerating!... %f",self.timeIntervalBetweenIndex);
        [self modifyTimeInterval:+self.deceleration];
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.userSelectedTextTextField resignFirstResponder];
    [self.nextResponder touchesBegan:touches withEvent:event];
    if (self.timeIntervalBetweenIndex < 6.575) {
        [UIView animateWithDuration:0.5 animations:^{
            self.pinView.layer.affineTransform = CGAffineTransformMakeRotation(self.timeIntervalBetweenIndex);
        }];
    }
    self.accelerationBegan = YES;
    self.accelerationtimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Began %d", self.accelerationBegan);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.accelerationBegan = NO;
    [self.accelerationtimer invalidate];
    self.accelerationtimer = nil;
    self.deccelerationtimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Ended %d", self.accelerationBegan);
    
    [self retractColorPalette];
    [UIView animateWithDuration:1.5 animations:^{
        self.userSelectedTextTextField.frame = CGRectMake(-145.0f, self.toggleUserSelections.frame.origin.y-30.0f, 145.0f, kColorPaletteHeight);
        self.speedPropertySelector.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 30);
        self.speedLabel.alpha = kZero;
    }];
    
}

- (void)startBreaking {
    [self modifyTimeInterval:+0.020];
    NSLog(@"Breaking!...%f", self.timeIntervalBetweenIndex);
    
}

- (void)breaking {
    if (self.breakPedalGesture.state == UIControlEventTouchDown) {
        self.breakingBegan = YES;
        NSLog(@"break");
        self.accelerationBegan = NO;
        [self.accelerationtimer invalidate];
        self.accelerationtimer = nil;
        [self.deccelerationtimer invalidate];
        self.deccelerationtimer = nil;
        self.breaktimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(startBreaking) userInfo:nil repeats:YES];
        NSLog(@"%f", self.timeIntervalBetweenIndex);
        
    } if (self.breakPedalGesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^{
            self.pinView.layer.affineTransform = CGAffineTransformMakeRotation(self.timeIntervalBetweenIndex);
        }];
        self.breakingBegan = NO;
        NSLog(@"break ended");
        [self.breaktimer invalidate];
        self.breaktimer = nil;
    }
    [self.speedLabel removeFromSuperview];
    
}

- (void)modifyTextWithString: (NSString *)characterSetString color: (UIColor *)color {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:characterSetString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: self.focusText.attributedText];
    for (NSInteger charIdx = 0; charIdx < self.focusText.text.length; charIdx++){
        unichar currentCharacter = [self.focusText.text characterAtIndex:charIdx];
        BOOL isCharacterSet = [characterSet characterIsMember:currentCharacter];
        if (isCharacterSet) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(charIdx, 1)];
        }
        //            [UIView animateWithDuration:0.3 animations:^{
        //            [constText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(charIdx, 1)];
        //            }];
        //        }
        //        NSLog(@"%C is a %@", currentCharacter, isVowel ? @"vowel" : @"consonant");
    }
    [self.focusText setAttributedText: attributedString];
}

- (void)toggleVowelsSelected {
    self.highlightVowelsActivated = !self.highlightVowelsActivated;
    self.textColorBeingModified = Vowels;
    
    if (self.highlightVowelsActivated) {
        [self.toggleVowels addGestureRecognizer:self.openColorOptionsGesture];
        [UIView animateWithDuration:0.5 animations:^{
            self.toggleVowels.frame = CGRectMake(55, CGRectGetHeight(self.view.frame) - 140, 25, 25);
            self.toggleVowels.layer.shadowOpacity = 0.55f;
            self.toggleVowels.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.toggleVowels.backgroundColor = self.highlightVowelColor;
            self.toggleVowels.alpha = 1.0f;
            
        }];
    }
    if (!self.highlightVowelsActivated) {
        [self.toggleConsonates removeGestureRecognizer:self.openColorOptionsGesture];
        [self retractColorPalette];
        [UIView animateWithDuration:0.5 animations:^{
            self.toggleVowels.frame = CGRectMake(55, CGRectGetHeight(self.view.frame) - 138, 25, 25);
            self.toggleVowels.layer.shadowOpacity = 0.30f;
            self.toggleVowels.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.toggleVowels.backgroundColor = self.defaultButtonColor;
            self.toggleVowels.alpha = kHiddenControlRevealedAlhpa;
        }];
    }
    
}

- (void)highlightVowels {
    [self modifyTextWithString:kVowels color:self.highlightVowelColor];
}

- (void)toggleConsonantsSelected {
    self.highlightConsonantsActivated = !self.highlightConsonantsActivated;
    self.textColorBeingModified = Consonants;
    [self updatePaletteOrigin];
    if (self.highlightConsonantsActivated) {
        [self.toggleConsonates addGestureRecognizer:self.openColorOptionsGesture];
        [UIView animateWithDuration:0.5f animations:^{
            self.toggleConsonates.frame = CGRectMake(100, CGRectGetHeight(self.view.frame) - 95, 25, 25);
            self.toggleConsonates.layer.shadowOpacity = kUINormaAlpha;
            self.toggleConsonates.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.toggleConsonates.backgroundColor = self.highlightConsonantColor;
            self.toggleConsonates.alpha = 1.0f;
        }];
    }
    if (!self.highlightConsonantsActivated) {
        [self.toggleConsonates removeGestureRecognizer:self.openColorOptionsGesture];
        [self retractColorPalette];
        [UIView animateWithDuration:0.5f animations:^{
            self.toggleConsonates.frame = CGRectMake(100, CGRectGetHeight(self.view.frame) - 93, 25, 25);
            self.toggleConsonates.layer.shadowOpacity = 0.30f;
            self.toggleConsonates.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.toggleConsonates.backgroundColor = self.defaultButtonColor;
            self.toggleConsonates.alpha = kUINormaAlpha;
        }];
    }
}

- (void)highlightConsonants {
    [self modifyTextWithString:kConsonants color:self.highlightConsonantColor];
}

- (void)toggleUserSelected {
    self.highlightUserSelectionActivated = !self.highlightUserSelectionActivated;
    self.textColorBeingModified = UserSelection;
    [self updatePaletteOrigin];
    [self openUserInputTextField];
    
    if (self.highlightUserSelectionActivated) {
        [self.toggleUserSelections addGestureRecognizer:self.openColorOptionsGesture];
        [UIView animateWithDuration:0.5f animations:^{
            self.toggleUserSelections.frame = CGRectMake(35, CGRectGetHeight(self.view.frame) - 195, 25, 25);
            self.toggleUserSelections.layer.shadowOpacity = kUINormaAlpha;
            self.toggleUserSelections.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.toggleUserSelections.backgroundColor = self.highlightUserSelectedTextColor;
            self.toggleUserSelections.alpha = 1.0f;
        }];
    }
    if (!self.highlightUserSelectionActivated) {
        [self.toggleUserSelections removeGestureRecognizer:self.openColorOptionsGesture];
        [self retractColorPalette];
        [UIView animateWithDuration:0.5f animations:^{
            self.toggleUserSelections.frame = CGRectMake(35, CGRectGetHeight(self.view.frame) - 193, 25, 25);
            self.toggleUserSelections.layer.shadowOpacity = 0.30f;
            self.toggleUserSelections.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.toggleUserSelections.backgroundColor = self.defaultButtonColor;
            self.toggleUserSelections.alpha = kUINormaAlpha;
        }];
    }
}

- (void)highlightUserSelected {
//    [self modifyTextWithString:self.userInputForHighlightedTextString color:self.highlightUserSelectedTextColor];
    [self modifyTextWithString:self.userSelectedTextTextField.text color:[UIColor redColor]];

}

- (void)changeSelectedTextColor: (UIButton *)button {
    NSLog(@"buttonPressed %ld", (long)button.tag);
    
//    if (self.textColorBeingModified == Vowels) {
//        button.tag = 3;
//        button.alpha = 1.0f;
//        button.layer.affineTransform = CGAffineTransformScale(button.layer.affineTransform, 1.05f, 1.20f);
//        button.layer.shadowOpacity = 0.65f;
//        button.layer.zPosition = 1.0f;
//    }
    
    self.highlightColorSelected = !self.highlightColorSelected;
    if (self.highlightColorSelected) {
//        [UIView animateWithDuration:0.50f animations:^{
            button.alpha = 1.0f;
            button.layer.affineTransform = CGAffineTransformScale(button.layer.affineTransform, 1.05f, 1.20f);
            button.layer.shadowOpacity = 0.65f;
            button.layer.zPosition = 1.0f;
//        }];
    }
    
    if (!self.highlightColorSelected) {
//        [UIView animateWithDuration:0.10f animations:^{
            button.alpha = 1.0f;
            button.layer.affineTransform = CGAffineTransformScale(button.layer.affineTransform, 1/1.05f, 1/1.20f);
            button.layer.shadowOpacity = kShadowOpacity;
            button.layer.zPosition = 0.0f;
//        }];
    }
    ModifyColorForTextActivated modifyColorActivated;
    switch (button.tag) {
        case 1:
            switch (modifyColorActivated) {
                case Consonants:
                    self.toggleConsonates.backgroundColor = self.highlightColorFive;
                    [self modifyTextWithString:kConsonants color:self.highlightColorFive];
                    break;
                case Vowels:
                    self.toggleVowels.backgroundColor = self.highlightColorFive;
                    [self modifyTextWithString:kVowels color:self.highlightColorFive];
                    break;
                case UserSelection:
                    self.toggleConsonates.backgroundColor = self.highlightColorFive;
                    [self modifyTextWithString:self.userInputForHighlightedTextString color:self.highlightColorFive];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (modifyColorActivated) {
                case Consonants:
                    self.toggleConsonates.backgroundColor = self.self.highlightColorThree;
                    [self modifyTextWithString:kConsonants color:self.self.highlightColorThree];
                    break;
                case Vowels:
                    self.toggleVowels.backgroundColor = self.self.highlightColorThree;
                    [self modifyTextWithString:kVowels color:self.self.highlightColorThree];
                    break;
                case UserSelection:
                    self.toggleConsonates.backgroundColor = self.self.highlightColorThree;
                    [self modifyTextWithString:self.userInputForHighlightedTextString color:self.self.highlightColorThree];
                    break;
                default:
                    break;
            }
            
            break;
        case 3:
            switch (modifyColorActivated) {
                case Consonants:
                    self.toggleConsonates.backgroundColor = self.self.highlightConsonantColor;
                    [self modifyTextWithString:kConsonants color:self.self.highlightConsonantColor];
                    break;
                case Vowels:
                    self.toggleVowels.backgroundColor = self.self.highlightConsonantColor;
                    [self modifyTextWithString:kVowels color:self.self.highlightConsonantColor];
                    break;
                case UserSelection:
                    self.toggleUserSelections.backgroundColor = self.self.highlightConsonantColor;
                    [self modifyTextWithString:self.userInputForHighlightedTextString color:self.self.highlightConsonantColor];
                    break;
                default:
                    break;
            }
            break;
        case 4:
            switch (modifyColorActivated) {
                case Consonants:
                    self.toggleConsonates.backgroundColor = self.self.highlightVowelColor;
                    [self modifyTextWithString:kConsonants color:self.self.highlightVowelColor];
                    break;
                case Vowels:
                    self.toggleVowels.backgroundColor = self.self.highlightVowelColor;
                    [self modifyTextWithString:kVowels color:self.self.highlightVowelColor];
                    break;
                case UserSelection:
                    self.toggleUserSelections.backgroundColor = self.self.highlightVowelColor;
                    [self modifyTextWithString:self.userInputForHighlightedTextString color:self.self.highlightVowelColor];
                    break;
                default:
                    break;
            }
            break;
        case 5:
            switch (modifyColorActivated) {
                case Consonants:
                    self.toggleConsonates.backgroundColor = self.self.highlightUserSelectedTextColor;
                    [self modifyTextWithString:kConsonants color:self.self.highlightUserSelectedTextColor];
                    break;
                case Vowels:
                    self.toggleVowels.backgroundColor = self.self.highlightUserSelectedTextColor;
                    [self modifyTextWithString:kVowels color:self.self.highlightUserSelectedTextColor];
                    break;
                case UserSelection:
                    self.toggleUserSelections.backgroundColor = self.self.highlightUserSelectedTextColor;
                    [self modifyTextWithString:self.userInputForHighlightedTextString color:self.self.highlightUserSelectedTextColor];
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)highlightUserSelectedLetters {
    [self modifyTextWithString:self.userInputForHighlightedTextString color:self.highlightColorThree];
}

- (void)colorPropertySelectorSwitch: (UISegmentedControl *)segmentController {
    //    [self refresh];
}

- (void)speedPropertySelectorSwitch: (UISegmentedControl *)segmentController {
    [self refreshSpeedValues];
}

- (void)adjustSpeedUsingSlider: (UISlider *)slider {
    [self refreshSpeedValues];
}

- (void)refreshSpeedValues {
    SpeedAdjustmentSegmentSelected segmentSelected = self.speedPropertySelector.selectedSegmentIndex;
    
    switch (segmentSelected) {
        case NormalSpeed:
            self.speedShown = self.normalSpeed;
            self.normalSpeed = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = self.minSpeed;
            self.speedAdjusterSlider.minimumValue = self.maxSpeed;
            self.speedAdjusterSlider.maximumTrackTintColor = self.highlightVowelColor;
            self.selectedSpeedToAdjustIndicator = @"normal speed";
            break;
        case MaximumSpeed:
            self.speedShown = self.maxSpeed;
            self.maxSpeed = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 0.75f;
            self.speedAdjusterSlider.minimumValue = 0.01f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.highlightUserSelectedTextColor;
            self.selectedSpeedToAdjustIndicator = @"max speed";
            break;
        case MinimumSpeed:
            self.speedShown = self.minSpeed;
            self.minSpeed = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 1.0f;
            self.speedAdjusterSlider.minimumValue = 0.01f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.highlightConsonantColor;
            self.selectedSpeedToAdjustIndicator = @"min speed";
            break;
        case AccelerationSpeed:
            self.speedShown = self.acceleration;
            self.acceleration = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 0.1f;
            self.speedAdjusterSlider.minimumValue = 0.001f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.highlightColorThree;
            self.selectedSpeedToAdjustIndicator = @"acceleration";
            break;
        case DecelerationSpeed:
            self.speedShown = self.deceleration;
            self.deceleration = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 0.1f;
            self.speedAdjusterSlider.minimumValue = 0.0001f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.highlightColorFour;
            self.selectedSpeedToAdjustIndicator = @"deceleration";
            break;
        default:
            self.speedShown = self.maxSpeed;
            self.maxSpeed = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 0.75f;
            self.speedAdjusterSlider.minimumValue = 0.01f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.highlightColorFive;
            self.selectedSpeedToAdjustIndicator = @"normal speed";
            break;
    }
    [self.view addSubview:self.speedLabel];
    [self.view addSubview:self.speedPropertySelector];
    self.speedShown = self.speedAdjusterSlider.value;
    float wordsPerMinute = 1/self.speedShown * 60;
    self.speedLabel.text = [NSString stringWithFormat:@"%@\n%0.1f\nwords/min",self.selectedSpeedToAdjustIndicator, wordsPerMinute];
    [UIView animateWithDuration:1.0 animations:^{
        self.speedLabel.alpha = kUINormaAlpha;
        self.speedPropertySelector.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 30, CGRectGetWidth(self.view.frame), 30);
        
    }];
}

- (void)hideControls {
    self.hideControlsActivated = !self.hideControlsActivated;
    if (!self.hideControlsActivated) {
        [UIView animateWithDuration:1.0 animations:^{
            self.hideControlButton.backgroundColor = [UIColor blackColor];
            self.hideControlButton.alpha = 0.25f;
            self.toggleVowels.alpha = kHiddenControlRevealedAlhpa + 0.1;
            self.toggleConsonates.alpha = kHiddenControlRevealedAlhpa;
            self.toggleUserSelections.alpha = kHiddenControlRevealedAlhpa + 0.2;
            self.speedAdjusterSlider.alpha = kHiddenControlRevealedAlhpa;
        }];
    }
    if (self.hideControlsActivated) {
        [UIView animateWithDuration:1.0 animations:^{
            self.hideControlButton.backgroundColor = [UIColor colorWithWhite:1.0f alpha:kZero];
            self.hideControlButton.alpha = kUINormaAlpha;
            self.toggleVowels.alpha = kZero;
            self.toggleConsonates.alpha = kZero;
            self.toggleUserSelections.alpha = kZero;
            self.speedAdjusterSlider.alpha = kZero;
        }];
    }
}

- (void)updatePaletteOrigin {
    switch (self.textColorBeingModified) {
        case Vowels:
            self.colorPaletteXOrigin = self.toggleVowels.frame.origin.x+kColorPaletteWidth - 2;
            self.colorPaletteYOrigin = self.toggleVowels.frame.origin.y + 7;
            break;
        case Consonants:
            self.colorPaletteXOrigin = self.toggleConsonates.frame.origin.x+kColorPaletteWidth - 2;
            self.colorPaletteYOrigin = self.toggleConsonates.frame.origin.y + 7;
            break;
        case UserSelection:
            self.colorPaletteXOrigin = self.toggleUserSelections.frame.origin.x+kColorPaletteWidth - 2;
            self.colorPaletteYOrigin = self.toggleUserSelections.frame.origin.y + 7;
            break;
            
        default:
            break;
    }
}

- (void)openColorPalette: (UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state !=UIGestureRecognizerStateBegan) {
        return;
    }
    
    NSLog(@"PaletteOpening!...");
    [self.view addSubview:self.color5];
    [self.view addSubview:self.color4];
    [self.view addSubview:self.color3];
    [self.view addSubview:self.color2];
    [self.view addSubview:self.color1];
    self.color1.tag = 1;
    self.color2.tag = 2;
    self.color3.tag = 3;
    self.color4.tag = 4;
    self.color5.tag = 5;
    [self.color1 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.color2 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.color3 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.color4 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.color5 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    
    [UIView animateWithDuration:0.0 animations:^{
        [self updatePaletteOrigin];
        self.color1.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color2.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color3.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color4.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color5.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.color1.frame = CGRectMake(self.colorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.color2.frame = CGRectMake(self.colorPaletteXOrigin + kColorPaletteWidth, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.color3.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *2), self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.color4.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *3), self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.color5.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *3), self.colorPaletteYOrigin, kColorPaletteWidth*2, kColorPaletteHeight);
        }];
    }];
    
}
- (void)retractColorPalette {
    [UIView animateWithDuration:1.0 animations:^{
        self.color1.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color2.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color3.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color4.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color5.frame = CGRectMake(self.colorPaletteXOrigin+5, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
    }];
}

- (void)openUserInputTextField {
    [self.view addSubview:self.userSelectedTextTextField];
//    self.userSelectedTextTextField.text = self.userInputForHighlightedTextString;
//    self.userSelectedTextTextField.frame = CGRectMake(0, 0, 300, 300);
////    self.userSelectedTextTextField.backgroundColor = [UIColor redColor];

    [UIView animateWithDuration:1.20f animations:^{
        self.userSelectedTextTextField.frame = CGRectMake(kZero-1.0f, self.toggleUserSelections.frame.origin.y-30.0f, 90.0f, kColorPaletteHeight);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.userInputForHighlightedTextString = self.userSelectedTextTextField.text;
    [self.userSelectedTextTextField resignFirstResponder];
    return YES;
}

@end
