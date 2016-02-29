//
//  ViewController.m
//  Road
//
//  Created by Li Pan on 2016-02-19.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ROADReadingInterface.h"
#import "KFEpubController.h"
#import "KFEpubContentModel.h"
#import "ROADCurrentReadingPosition.h"
#import "Utilities.h"
#import "ConfigureView.h"
#import "ROADUIUserInteractionTools.h"

#import "ROADReadInterfaceBOOLs.h"
#import "ROADDisplayReadingTextLabel.h"


#pragma mark ENUMs

typedef NS_ENUM(NSInteger, SpeedAdjustmentSegmentSelected) {
    NormalSpeed,
    MaximumSpeed,
    MinimumSpeed,
    AccelerationSpeed,
    Default,
};

typedef NS_ENUM(NSInteger, ModifyColorForTextActivated) {
    Vowels,
    Consonants,
    UserSelection,
};

typedef NS_ENUM(NSInteger, ColorPaletteColorSelected) {
    ColorOne,
    ColorTwo,
    ColorThree,
    ColorFour,
    ColorFive,
};

#pragma mark Properties

@interface ROADReadingInterface () <KFEpubControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) KFEpubController *epubController;
@property (nonatomic, strong) KFEpubContentModel *contentModel;
@property (nonatomic, strong) UIReferenceLibraryViewController *dictionaryViewController;
@property (nonatomic, strong) UIWebView *bookContentView;
@property (nonatomic, assign) NSUInteger spineIndex;
@property (nonatomic, strong) NSScanner *assistantTextRangeScanner;
@property (nonatomic, strong) ROADCurrentReadingPosition *currentReadingPosition;
@property (nonatomic, strong) ROADUIUserInteractionTools *userInteractionTools;
@property (nonatomic, strong) ROADReadInterfaceBOOLs *readingInterfaceBOOLs;
@property (nonatomic, strong) ROADDisplayReadingTextLabel *displayReadingTextLabe;

@property (nonatomic, strong) UIView *breakPedal;
@property (nonatomic, assign) CGRect breakPedalFrame;

#pragma mark DisplayData

@property (nonatomic, strong) NSMutableArray *chaptersArray;
@property (nonatomic, strong) NSMutableArray *wordsArray;
@property (nonatomic, strong) NSMutableArray *assistantTextRangeIndexArray;
@property (nonatomic, strong) NSMutableArray *assistantTextRangeLenghtArray;
@property (nonatomic, strong) NSString *bookTextRawString;
@property (nonatomic, strong) NSString *bookTextString;
@property (nonatomic, strong) NSString *currentChapter;

@property (nonatomic, strong) NSString *fontType;

#pragma mark UI Display Properties

@property (nonatomic, strong) UIView *labelView;
@property (nonatomic, strong) UIView *uiView;
@property (nonatomic, strong) UIView *lightsOffView;
@property (nonatomic, strong) UILabel *dot;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UIView *progress;
@property (nonatomic, strong) UIView *speedometerView;
@property (nonatomic, strong) UIView *pinView;

@property (nonatomic, strong) UILabel *chapterLabel;
@property (nonatomic, strong) UILabel *focusText;
@property (nonatomic, strong) UILabel *previousWord3;
@property (nonatomic, strong) UILabel *previousWord2;
@property (nonatomic, strong) UILabel *previousWord;
@property (nonatomic, strong) UILabel *nextWord;
@property (nonatomic, strong) UILabel *nextWord2;
@property (nonatomic, strong) UILabel *nextWord3;
@property (nonatomic, strong) UILabel *nextWord4;
@property (nonatomic, strong) UILabel *dividerLabel;

@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UILabel *speedometerReadLabel;
@property (nonatomic, strong) UILabel *focusFontSizeLabel;

#pragma mark Runtime Properties

@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval timeIntervalBetweenIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *accelerationtimer;
@property (nonatomic, strong) NSTimer *deccelerationtimer;
@property (nonatomic, strong) NSTimer *breaktimer;

#pragma mark Speed Properties

@property (nonatomic, assign) float normalSpeed;
@property (nonatomic, assign) float maxSpeed;
@property (nonatomic, assign) float minSpeed;
@property (nonatomic, assign) float acceleration;
@property (nonatomic, assign) float deceleration;
@property (nonatomic, assign) float speedShown;

#pragma mark Color Properties
@property (nonatomic, assign) float colorAdjusterValue;

@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, strong) UIColor *colorOne;
@property (nonatomic, strong) UIColor *colorTwo;
@property (nonatomic, strong) UIColor *colorThree;
@property (nonatomic, strong) UIColor *colorFour;
@property (nonatomic, strong) UIColor *colorFive;
@property (nonatomic, strong) UIColor *defaultButtonColor;

//Frames
@property (nonatomic, assign) CGRect highlightButtonLocationFrames;

//Strings
@property (nonatomic, strong) NSString *userInputForHighlightedTextString;
@property (nonatomic, strong) NSString *selectedSpeedToAdjustIndicator;

//Arrays
@property (nonatomic, strong) NSArray *speedArray;

#pragma Mark Palette Properties

@property (nonatomic, strong) UIButton *color1;
@property (nonatomic, strong) UIButton *color2;
@property (nonatomic, strong) UIButton *color3;
@property (nonatomic, strong) UIButton *color4;
@property (nonatomic, strong) UIButton *color5;

@property (nonatomic, assign) float colorPaletteXOrigin;
@property (nonatomic, assign) float colorPaletteYOrigin;

@property (nonatomic, assign) ModifyColorForTextActivated textColorBeingModified;

@end

@implementation ROADReadingInterface

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

static const float kAccessButtonWidth = 50.0f;
static const float kAccessButtonHeight = 45.0f;

//PaletteConstants
static const float kColorPaletteheightMultiple = kGoldenRatioMinusOne;
static const float kColorPaletteXOrigin = 0.0f;
static const float kColorPaletteWidth = 35.0f;
static const float kColorPaletteHeight = 25.0f;

static const float kToggleButtonDimension = 35.0f;
static const float kToggleButtonOffsetX = 200.0f;

static const float kControlButtonXOrigin = 17.5f;
static const float kControlButtonXOffset = 50.0f;
static const float kControlButtonMidYOffset = 40.0f;
static const float kControlButtonYOffset = 65.0f;
static const float kControlButtonDimension = 45.0f;
static const float kAssistantTextViewWidth = 120.0f;

static const float k180Rotation = 180;

static const float kLabelViewWidth = 200.0f;
static const float kLabelViewHeight = 150.0f;
static const float kLabelHeight = 30.0f;
static const float kLabelHeightOffset = 15.0;


NSString *const kVowels = @"aeiouAEIOU";
NSString *const kConsonants = @"bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ";

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadValues];
    [self loadBook];
    [self loadText];
    [self loadUIContents];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopTimer];
    [self saveData];
}

#pragma mark Data Managment

- (void)saveData {
    NSLog(@"saveing to %@", [Utilities getSavedProfilePath]);
    [Utilities archiveFile:self.currentReadingPosition toFile:[Utilities getSavedProfilePath]];
}

- (void)loadData {
    NSLog(@"attempting to load %@", [Utilities getSavedProfilePath]);
    self.currentReadingPosition = [Utilities unarchiveFile:[Utilities getSavedProfilePath]];
    if (!self.currentReadingPosition) {
        NSLog(@"failed to load, loading%@", [Utilities getSavedProfilePath]);
        self.currentReadingPosition = [[ROADCurrentReadingPosition alloc]init];
        [self initCurrentDefaultPostionValues];
        
    }
}

- (void) initCurrentDefaultPostionValues {
    self.currentReadingPosition.highlightVowelColor = self.colorOne;
    self.currentReadingPosition.highlightConsonantColor = self.colorTwo;
    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorThree;
    self.currentReadingPosition.highlightMovingTextColor = [UIColor blackColor];
    self.currentReadingPosition.mainFontSize = 24.0f;
}

#pragma mark Loading Contents

- (void)loadValues {
    [self loadData];
    [self updateFontSize];
    self.readingInterfaceBOOLs  = [[ROADReadInterfaceBOOLs alloc]init];
    
    self.normalSpeed = 0.45;
    self.minSpeed = 1.0;
    self.maxSpeed = 0.15;
    self.acceleration = 0.002;
    self.deceleration = 0.0007;
    self.timeIntervalBetweenIndex = self.normalSpeed;
    self.readingInterfaceBOOLs.accelerationBegan = NO;
    self.readingInterfaceBOOLs.highlightVowelsActivated = NO;
    self.readingInterfaceBOOLs.highlightConsonantsActivated = NO;
    self.readingInterfaceBOOLs.hideControlsActivated = YES;
    self.colorAdjusterValue = 254.0;
    
    self.dotColor = [UIColor colorWithRed:195.0f/255.0f green:25.0f/255.0f blue:25.0f/255.0f alpha:1.0f];
    
    self.colorOne = [UIColor colorWithRed:254.0f/255.0f green:82.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
    self.colorTwo = [UIColor colorWithRed:136.0f/255.0f green:14.0f/255.0f blue:79.0f/255.0f alpha:1.0f];
    self.colorThree = [UIColor colorWithRed:11.0f/255.0f green:73.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
    self.colorFour = [UIColor colorWithRed:71.0f/255.0f green:215.0f/255.0f blue:193.0f/255.0f alpha:1.0f];
    self.colorFive = [UIColor colorWithRed:253.0f/255.0f green:196.0f/255.0f blue:2.0f/255.0f alpha:1.0f];
    self.defaultButtonColor = [UIColor colorWithRed:98.0f/255.0f green:91.0f/255.0f blue:77.0f/255.0f alpha:0.8f];
    
    self.fontType = @"AmericanTypewriter";
    
    
    
    self.speedArray = [NSArray arrayWithObjects: @"norm speed", @"max speed", @"min speed", @"accel", @"default", nil];
}

#pragma mark Load UIContents
- (void)loadUIContents {
    //    self.exitReadView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    //    self.exitReadView.backgroundColor = [UIColor redColor];
    //    [self.exitReadView addTarget:self action:@selector(saveData) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    self.uiView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.uiView];
    //    [self.uiView addSubview:self.exitReadView];
    
    self.labelView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*kGoldenRatioMinusOne-kLabelViewWidth/2, CGRectGetMaxY(self.view.frame)*kOneMinusGoldenRatioMinusOne-kLabelViewHeight/2, kLabelViewWidth, kLabelViewHeight)];
    self.labelView.userInteractionEnabled = NO;
    [self.view addSubview:self.labelView];
    
    self.userInteractionTools = [[ROADUIUserInteractionTools alloc]init];
    
    
    UIImage *paper = [UIImage imageNamed:@"ivoryPaper.png"];
    UIImage *breakPedal = [UIImage imageNamed:@"finger_clean.png"];
    UIImage *speedometerImage = [UIImage imageNamed:@"Speedometer.png"];
    UIImage *pinImage= [UIImage imageNamed:@"Pin.png"];
    UIImage *leftHandImage = [UIImage imageNamed:@"leftHand"];
    
    static const float kSpeedometerDimension = 140.0f;
    static const float kProgressOffSetFromProgressBar = 2.0f;
    static const float kProgressBarWidth = 90.0f;
    static const float kProgressBarHeight = 14.0f;
    
    self.uiView.layer.contents = (__bridge id)paper.CGImage;
    self.speedometerView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.uiView.frame)-kSpeedometerDimension, 35.0f, kSpeedometerDimension, kSpeedometerDimension)];
    self.speedometerView.layer.contents = (__bridge id)speedometerImage.CGImage;
    self.speedometerView.layer.contentsGravity = kCAGravityResizeAspect;
    self.speedometerView.alpha = 0.20f;
    
    //84 is max
    self.progress = [[UIView alloc]initWithFrame:CGRectMake(self.speedometerView.frame.size.width + kSpeedometerDimension/2 + kProgressOffSetFromProgressBar, CGRectGetMidY(self.speedometerView.frame)+kProgressOffSetFromProgressBar, kProgressBarHeight, kProgressBarHeight/2 + 0.5)];
    self.progress.layer.borderWidth = kBoarderWidth/2;
    self.progress.layer.cornerRadius = 3.0f;
    self.progress.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.progress.layer.shadowOpacity = kShadowOpacity;
    self.progress.alpha = kUINormaAlpha;
    self.progress.backgroundColor = self.dotColor;
    
    self.progressBar = [[UIView alloc]initWithFrame:CGRectMake(self.speedometerView.frame.size.width + kSpeedometerDimension/2, CGRectGetMidY(self.speedometerView.frame), kProgressBarWidth, kProgressBarHeight - kProgressOffSetFromProgressBar)];
    self.progressBar.layer.borderWidth = 0.75f;
    self.progressBar.layer.cornerRadius = 5.0f;
    self.progressBar.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.progressBar.layer.shadowOpacity = kShadowOpacity;
    self.progressBar.alpha = kUINormaAlpha;
    
//    UILabel *averageSpeedLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.speedometerView.frame.size.width + kSpeedometerDimension/2, CGRectGetMidY(self.speedometerView.frame)-kProgressBarHeight, kProgressBarWidth, kProgressBarHeight - kProgressOffSetFromProgressBar)];
//    
//    UIBezierPath *path = [[UIBezierPath alloc]init];
//    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc]init];
//    [path moveToPoint:CGPointMake(kZero, kZero)];
//    [path moveToPoint:CGPointMake(averageSpeedLabel.frame.size.width, kZero)];
//    [path moveToPoint:CGPointMake(averageSpeedLabel.frame.size.width - 4.0f, averageSpeedLabel.frame.size.height)];
//    [path moveToPoint:CGPointMake(kZero, averageSpeedLabel.frame.size.height)];
//    shapeLayer.path = (__bridge CGPathRef _Nullable)(path);
//    [averageSpeedLabel.layer addSublayer:shapeLayer];
//    averageSpeedLabel.backgroundColor = [UIColor blackColor];
//    averageSpeedLabel.layer.borderWidth = kBoarderWidth;
//    averageSpeedLabel.clipsToBounds = YES;
//    [self.uiView addSubview:averageSpeedLabel];

    
    UIImageView *pinImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15.0f, 70.0f)];
    pinImageView.image = [UIImage imageNamed:@"Pin.png"];
    
    self.pinView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-75.1f, 65.0f, 15.0f, 70.0f)];
    self.pinView.layer.contents = (__bridge id)pinImage.CGImage;
    self.pinView.layer.contentsGravity = kCAGravityResizeAspect;
    self.pinView.layer.shadowOffset = CGSizeMake(-1.0, 4.0);
    self.pinView.layer.shadowOpacity = kShadowOpacity;
    
    self.speedometerReadLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.uiView.frame)-97.0f, 114.0f, 60.0f, 15.0f)];
    self.speedometerReadLabel.font = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    self.speedometerReadLabel.alpha = kUINormaAlpha;
    self.speedometerReadLabel.textAlignment = NSTextAlignmentCenter;
    
    self.userInteractionTools.toggleFocusTextModification = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)-kAccessButtonHeight, CGRectGetMidY(self.uiView.frame)-kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight)];
    [self configureRoundButton:self.userInteractionTools.toggleFocusTextModification dimension:kAccessButtonHeight];
    [ConfigureView configureTrapezoidButton:self.userInteractionTools.toggleFocusTextModificatio title:@"A" font:self.fontType];
    [self.userInteractionTools.toggleFocusTextModification addTarget:self action:@selector(expandModifyFocusTextView:) forControlEvents:UIControlEventTouchUpInside];
    
    self.userInteractionTools.modifyFocusTextFontSizeSlider = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, CGRectGetHeight(self.uiView.frame)/5 + 30.0f, 120.0f, 30.0f)];
    [self rotationTransformation:self.userInteractionTools.modifyFocusTextFontSizeSlider.layer degrees:180.0f];
    self.userInteractionTools.modifyFocusTextFontSizeSlider.tintColor = self.colorFive;
    self.userInteractionTools.modifyFocusTextFontSizeSlider.layer.shadowOffset = CGSizeMake(-1.0f, 6.0);
    self.userInteractionTools.modifyFocusTextFontSizeSlider.layer.shadowOpacity = 0.10f;
    self.userInteractionTools.modifyFocusTextFontSizeSlider.value = self.currentReadingPosition.mainFontSize;
    self.userInteractionTools.modifyFocusTextFontSizeSlider.maximumValue = 32.0f;
    self.userInteractionTools.modifyFocusTextFontSizeSlider.minimumValue = 22.0f;
    [self.userInteractionTools.modifyFocusTextFontSizeSlider addTarget:self action:@selector(adjustFontSize:) forControlEvents:UIControlEventValueChanged];
    
    self.focusFontSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, CGRectGetMidY(self.uiView.frame)-kToggleButtonOffsetX + 30.0, 30.0f, 30.0f)];
    self.focusFontSizeLabel.text = @"+A";
    self.focusFontSizeLabel.textColor = self.defaultButtonColor;
    //    self.focusFontSizeLabel.alpha = kUINormaAlpha;
    
    self.userInteractionTools.hideControlButton =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*kGoldenRatioMinusOne, CGRectGetMaxY(self.uiView.frame)/1.15203398875, 35.0f, 35.0f)];
    self.userInteractionTools.hideControlButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.hideControlButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.userInteractionTools.hideControlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.userInteractionTools.hideControlButton setTitle:@"show" forState:UIControlStateNormal];
    self.userInteractionTools.hideControlButton.titleLabel.font = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    self.userInteractionTools.hideControlButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.userInteractionTools.hideControlButton.alpha = kUINormaAlpha;
    self.userInteractionTools.hideControlButton.layer.cornerRadius = self.userInteractionTools.hideControlButton.frame.size.width/2;
    [self.userInteractionTools.hideControlButton addTarget:self action:@selector(toggleHideControls:) forControlEvents:UIControlEventTouchUpInside];
    
    self.userInteractionTools.breakPedalGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(breaking)];
    self.userInteractionTools.breakPedalGesture.minimumPressDuration = 0.01;
    self.breakPedalFrame = CGRectMake(CGRectGetWidth(self.uiView.frame)*0.38196601125, CGRectGetMaxY(self.uiView.frame)/kGoldenRatio, 220.0f, 220.0f);
    CGAffineTransform pedalPosition = CGAffineTransformIdentity;
    pedalPosition = CGAffineTransformScale(pedalPosition, 0.50f, 0.50f);
    pedalPosition = CGAffineTransformRotate(pedalPosition, M_PI/180.0 * -37);
    pedalPosition = CGAffineTransformTranslate(pedalPosition, 50.0f, kZero);
    self.breakPedal = [[UIView alloc]initWithFrame:self.breakPedalFrame];
    self.breakPedal.layer.contents = (__bridge id)breakPedal.CGImage;
    self.breakPedal.layer.opacity = 0.2f;
    self.breakPedal.layer.affineTransform = pedalPosition;
    self.breakPedal.layer.shadowColor = [UIColor blackColor].CGColor;
    [self.breakPedal addGestureRecognizer:self.userInteractionTools.breakPedalGesture];
    
    self.userInteractionTools.openColorOptionsGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(openColorPalette:)];
    self.userInteractionTools.openColorOptionsGesture.minimumPressDuration = 0.30f;
    
    self.highlightButtonLocationFrames = CGRectMake(100, CGRectGetHeight(self.uiView.frame) - 95, kToggleButtonDimension, kToggleButtonDimension);
    self.userInteractionTools.toggleVowels = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.userInteractionTools.toggleVowels addTarget:self action:@selector(toggleVowelsSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.userInteractionTools.toggleVowels buttonLayer:self.userInteractionTools.toggleVowels.layer color: self.defaultButtonColor string:@"æ"];
    self.userInteractionTools.toggleVowels.layer.affineTransform = CGAffineTransformMakeTranslation(-45, -40);
    
    self.userInteractionTools.toggleConsonates = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.userInteractionTools.toggleConsonates addTarget:self action:@selector(toggleConsonantsSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.userInteractionTools.toggleConsonates buttonLayer:self.userInteractionTools.toggleConsonates.layer color:self.defaultButtonColor string:@"ɳ"];
    
    self.userInteractionTools.toggleUserSelections = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.userInteractionTools.toggleUserSelections addTarget:self action:@selector(toggleUserSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.userInteractionTools.toggleUserSelections buttonLayer:self.userInteractionTools.toggleUserSelections.layer color:self.defaultButtonColor string:@"u"];
    self.userInteractionTools.toggleUserSelections.layer.affineTransform = CGAffineTransformMakeTranslation(-65, -100);
    
    self.userInteractionTools.presentDictionaryButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)-kAccessButtonHeight, CGRectGetMidY(self.uiView.frame)-2*kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight)];
    [self configureRoundButton:self.userInteractionTools.presentDictionaryButton dimension:kAccessButtonHeight];
    self.userInteractionTools.presentDictionaryButton.layer.cornerRadius = kAccessButtonHeight;
    [self.userInteractionTools.presentDictionaryButton setTitle:@"D" forState:UIControlStateNormal];
    [self.userInteractionTools.presentDictionaryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.userInteractionTools.presentDictionaryButton.titleLabel.font = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    [self.userInteractionTools.presentDictionaryButton addTarget:self action:@selector(presentDictionary:) forControlEvents:UIControlEventTouchUpInside];
    
    self.userInteractionTools.flipXAxisButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.uiView.frame)+25.0f, CGRectGetHeight(self.uiView.frame)-80.0f, kAccessButtonHeight, kAccessButtonHeight)];
    [self.userInteractionTools.flipXAxisButton addTarget:self action:@selector(flipXAxis:) forControlEvents:UIControlEventTouchUpInside];
    self.userInteractionTools.flipXAxisButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.flipXAxisButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.flipXAxisButton.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.flipXAxisButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.userInteractionTools.flipXAxisButton.layer.contents = (__bridge id)leftHandImage.CGImage;
    self.userInteractionTools.flipXAxisButton.layer.contentsGravity = kCAGravityResizeAspect;
    self.userInteractionTools.flipXAxisButton.layer.transform = CATransform3DRotate(self.userInteractionTools.flipXAxisButton.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
    
    self.userInteractionTools.flipXAxisButton.alpha = kUINormaAlpha;
    
    self.userInteractionTools.speedAdjusterSlider = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*kOneMinusGoldenRatioMinusOne, CGRectGetMaxY(self.uiView.frame)/kGoldenRatio, 120, 30)];
    [self.userInteractionTools.speedAdjusterSlider addTarget:self action:@selector(adjustSpeedUsingSlider:) forControlEvents:UIControlEventValueChanged];
    [self rotationTransformation:self.userInteractionTools.speedAdjusterSlider.layer degrees:-40.0f];
    self.userInteractionTools.speedAdjusterSlider.layer.affineTransform = CGAffineTransformTranslate(self.userInteractionTools.speedAdjusterSlider.layer.affineTransform, 30.0f, 40.0f);
    self.userInteractionTools.speedAdjusterSlider.tintColor = self.defaultButtonColor;
    self.userInteractionTools.speedAdjusterSlider.alpha = kZero;
    self.userInteractionTools.speedAdjusterSlider.value = 1/self.normalSpeed;
    
    self.speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*kOneMinusGoldenRatioMinusOne, CGRectGetMaxY(self.uiView.frame)/kGoldenRatio, 220, 60)];
    self.speedLabel.font = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    self.speedLabel.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.speedLabel.layer.shadowOpacity = kShadowOpacity;
    self.speedLabel.numberOfLines = kZero;
    self.speedLabel.alpha = kZero;
    
    self.userInteractionTools.speedPropertySelector = [[UISegmentedControl alloc]initWithItems:self.speedArray];
    self.userInteractionTools.speedPropertySelector.frame = CGRectMake(kZero, CGRectGetHeight(self.uiView.frame), CGRectGetWidth(self.uiView.frame), 30);
    self.userInteractionTools.speedPropertySelector.selectedSegmentIndex = kZero;
    self.userInteractionTools.speedPropertySelector.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.speedPropertySelector.layer.borderColor = [UIColor blackColor].CGColor;
    self.userInteractionTools.speedPropertySelector.tintColor = [UIColor blackColor];
    self.userInteractionTools.speedPropertySelector.alpha = kUINormaAlpha;
    [self.userInteractionTools.speedPropertySelector addTarget:self action:@selector(speedPropertySelectorSwitch:) forControlEvents:UIControlEventValueChanged];
    UIFont *speedControlfont = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    NSDictionary *speedAttributes = [NSDictionary dictionaryWithObject:speedControlfont forKey:NSFontAttributeName];
    [self.userInteractionTools.speedPropertySelector setTitleTextAttributes:speedAttributes forState:UIControlStateNormal];
    
    self.userInteractionTools.userSelectedTextTextField = [[UITextField alloc]initWithFrame:CGRectMake(-145.0f, self.userInteractionTools.toggleUserSelections.frame.origin.y-155.0f, 145.0f, 30.0f)];
    self.userInteractionTools.userSelectedTextTextField.layer.borderWidth = 0.75;
    self.userInteractionTools.userSelectedTextTextField.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:kUINormaAlpha].CGColor;
    self.userInteractionTools.userSelectedTextTextField.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.userInteractionTools.userSelectedTextTextField.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.userSelectedTextTextField.placeholder = @"Customize";
    self.userInteractionTools.userSelectedTextTextField.textAlignment = NSTextAlignmentCenter;
    self.userInteractionTools.userSelectedTextTextField.autocorrectionType = NO;
    self.userInteractionTools.userSelectedTextTextField.autocapitalizationType = NO;
    self.userInteractionTools.userSelectedTextTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.userInteractionTools.userSelectedTextTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userInteractionTools.userSelectedTextTextField.font = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    
    self.userInteractionTools.accessTextViewButton = [[UIButton alloc]initWithFrame:CGRectMake(-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame), kAccessButtonWidth, kAccessButtonHeight)];
    self.userInteractionTools.accessTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.accessTextViewButton.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.accessTextViewButton.layer.cornerRadius = kAccessButtonHeight;
    self.userInteractionTools.accessTextViewButton.backgroundColor = self.colorThree;
    [self.userInteractionTools.accessTextViewButton addTarget:self action:@selector(revealAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.expandTextViewButton = [[UIButton alloc]init];
    self.userInteractionTools.expandTextViewButton.alpha = 0.1;
    [self.userInteractionTools.expandTextViewButton setTitle:@"+" forState:UIControlStateNormal];
    [self.userInteractionTools.expandTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    self.userInteractionTools.expandTextViewButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.expandTextViewButton.layer.borderColor = self.defaultButtonColor.CGColor;
    self.userInteractionTools.expandTextViewButton.layer.cornerRadius = 22.5f;
    self.userInteractionTools.expandTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.expandTextViewButton.layer.shadowOpacity = kShadowOpacity;
    [self.userInteractionTools.expandTextViewButton addTarget:self action:@selector(expandAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.fullScreenTextViewButton = [[UIButton alloc]init];
    self.userInteractionTools.fullScreenTextViewButton.alpha = 0.1;
    [self.userInteractionTools.fullScreenTextViewButton setTitle:@">" forState:UIControlStateNormal];
    [self.userInteractionTools.fullScreenTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    self.userInteractionTools.fullScreenTextViewButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.fullScreenTextViewButton.layer.borderColor = self.defaultButtonColor.CGColor;
    self.userInteractionTools.fullScreenTextViewButton.layer.cornerRadius = 22.5f;
    self.userInteractionTools.fullScreenTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.fullScreenTextViewButton.layer.shadowOpacity = kShadowOpacity;
    [self.userInteractionTools.fullScreenTextViewButton addTarget:self action:@selector(fullScreenTextView:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.retractTextViewButton = [[UIButton alloc]init];
    self.userInteractionTools.retractTextViewButton.alpha = 0.1;
    [self.userInteractionTools.retractTextViewButton setTitle:@"<" forState:UIControlStateNormal];
    [self.userInteractionTools.retractTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    self.userInteractionTools.retractTextViewButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.retractTextViewButton.layer.borderColor = self.defaultButtonColor.CGColor;
    self.userInteractionTools.retractTextViewButton.layer.cornerRadius = 22.5f;
    self.userInteractionTools.retractTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.retractTextViewButton.layer.shadowOpacity = kShadowOpacity;
    [self.userInteractionTools.retractTextViewButton addTarget:self action:@selector(retractAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.assistantTextView = [[UITextView alloc]initWithFrame:CGRectMake(-120.0f, CGRectGetMidY(self.uiView.frame)-40, 120.0f, 120.0f)];
    self.userInteractionTools.assistantTextView.layer.zPosition = 0.9;
    self.userInteractionTools.assistantTextView.text = self.bookTextRawString;
    self.userInteractionTools.assistantTextView.textColor = self.defaultButtonColor;
    self.userInteractionTools.assistantTextView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0];
    self.userInteractionTools.assistantTextView.alpha = 1.0f;
    self.userInteractionTools.assistantTextView.editable = NO;
    
    self.dividerLabel = [[UILabel alloc]init];
    self.dividerLabel.backgroundColor = self.defaultButtonColor;
    self.dividerLabel.alpha = 0.20f;
    
    self.color1 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, CGRectGetHeight(self.uiView.frame)*kColorPaletteheightMultiple, kColorPaletteWidth, kColorPaletteHeight)];
    self.userInteractionTools.userSelectedTextTextField.delegate = self;
    self.color1.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color1.layer.shadowOpacity = kShadowOpacity;
    self.color1.backgroundColor = self.colorOne;
    
    self.color2 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.color2.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color2.layer.shadowOpacity = kShadowOpacity;
    self.color2.backgroundColor = self.colorTwo;
    
    self.color3 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.color3.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color3.layer.shadowOpacity = kShadowOpacity;
    self.color3.backgroundColor = self.colorThree;
    
    self.color4 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.color4.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color4.layer.shadowOpacity = kShadowOpacity;
    self.color4.backgroundColor = self.colorFour;
    
    self.color5 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.color5.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.color5.layer.shadowOpacity = kShadowOpacity;
    self.color5.backgroundColor = self.colorFive;
    //    self.color5.layer.cornerRadius = 4.0;
    
    [self.uiView addSubview:self.progress];
    [self.uiView addSubview:self.progressBar];
    [self.uiView addSubview:self.userInteractionTools.speedAdjusterSlider];
    [self.uiView addSubview:self.breakPedal];
    [self.uiView addSubview:self.userInteractionTools.hideControlButton];
    [self.uiView addSubview:self.pinView];
    [self.uiView addSubview:self.speedometerReadLabel];
    [self.uiView addSubview:self.userInteractionTools.accessTextViewButton];
    [self.uiView addSubview:self.speedometerView];
    [self.uiView addSubview:self.userInteractionTools.toggleFocusTextModification];
    [self.uiView  addSubview:self.userInteractionTools.flipXAxisButton];
    [self.uiView setNeedsDisplay];
}

#pragma mark Modify Toggle Buttons

- (void)modifyToggleButtonWithButton: (UIButton *)button buttonLayer:(CALayer *)layer color: (UIColor*)color string: (NSString *)string {
    layer.cornerRadius = button.frame.size.width/2;
    layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    layer.shadowOpacity = kShadowOpacity;
    layer.zPosition = 1.0f;
    [button setTitle:string forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:(self.fontType) size:12];
    button.alpha = kZero;
    button.backgroundColor = color;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.uiView addSubview:button];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark WebViewDelegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self convertBookToString];
    [self loadText];
}

#pragma mark Converting To String


- (void)convertBookToString {
    NSNumber *rangeIndex;
    NSNumber *rangeLength;
    NSInteger counterValue = 0;
    
    //    self.bookTextRawString = @"Speech is the vocalized form of human communication. It is based upon the syntactic combination of lexicals and names that are drawn from very large (usually about 1,000 different words) vocabularies. Each spoken word is created out of the phonetic combination of a limited set of vowel and consonant speech sound units. These vocabularies, the syntax which structures them, and their set of speech sound units differ, creating the existence of many thousands of different types of mutually unintelligible human languages. Most human speakers are able to communicate in two or more of them,[1] hence being polyglots. The vocal abilities that enable humans to produce speech also provide humans with the ability to sing. A gestural form of human communication exists for the deaf in the form of sign language. Speech in some cultures has become the basis of a written language, often one that differs in its vocabulary, syntax and phonetics from its associated spoken one, a situation called diglossia.";
    
    self.bookTextRawString = [self.bookContentView stringByEvaluatingJavaScriptFromString:@"document.body.textContent"];
    self.bookTextString = [[self.bookTextRawString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    //    NSLog(@"%@", self.bookTextString);
    
    self.assistantTextRangeScanner = [[NSScanner alloc]initWithString:self.bookTextRawString];
    self.assistantTextRangeScanner.scanLocation = kZero;
    self.assistantTextRangeScanner.caseSensitive = YES;
    
    NSScanner *chapterScanner = [[NSScanner alloc]initWithString:self.bookTextRawString];
    chapterScanner.scanLocation = kZero;
    chapterScanner.caseSensitive = YES;
    
    
    NSString *chapterString = [[NSString alloc]init];
    self.chaptersArray = [NSMutableArray array];
    [chapterScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&chapterString];
    self.currentChapter = chapterString;
    //    NSLog(@"%@", self.currentChapter);
    
    //    while (!self.assistantTextRangeScanner.isAtEnd) {
    //    [self.assistantTextRangeScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&chapterString];
    //        [self.chaptersArray addObject:chapterString];
    //    }
    //    NSLog(@"%lu", (unsigned long)self.chaptersArray.count);
    
    NSString *textString = [[NSString alloc]init];
    self.assistantTextRangeIndexArray = [NSMutableArray array];
    self.assistantTextRangeLenghtArray = [NSMutableArray array];
    self.wordsArray = [NSMutableArray array];
    while (!self.assistantTextRangeScanner.isAtEnd) {
        [self.assistantTextRangeScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&textString];
        rangeLength = @(textString.length);
        rangeIndex = @(self.assistantTextRangeScanner.scanLocation);
        counterValue++;
        [self.assistantTextRangeIndexArray addObject:rangeIndex];
        [self.assistantTextRangeLenghtArray addObject:rangeLength];
        [self.wordsArray addObject:textString];
        //                 NSLog(@"%@, %@, %@, %lu", textString, rangeLength, rangeIndex, counterValue);
    }
    //    NSLog(@"%lu", (unsigned long)self.assistantTextRangeIndexArray.count);
    //    NSLog(@"%lu", (unsigned long)self.assistantTextRangeLenghtArray.count);
    NSLog(@"%lu", (unsigned long)self.wordsArray.count);
    
}

- (void)loadText {
    
    self.startTime = CACurrentMediaTime();
    
    self.chapterLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)-175.0f, 50.0f, 150.0f, 130.0f)];
    self.chapterLabel.numberOfLines = kZero;
    self.chapterLabel.textColor = [UIColor blackColor];
    self.chapterLabel.alpha = kZero;
    self.chapterLabel.textAlignment = NSTextAlignmentCenter;
    self.chapterLabel.text = self.currentChapter;
    self.chapterLabel.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.chapterLabel.layer.shadowOpacity = kShadowOpacity;
    [self.labelView addSubview:self.chapterLabel];
    
    self.dot = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.labelView.bounds)/2-4.0f, CGRectGetHeight(self.labelView.bounds)/2+kLabelHeightOffset, 8.0f, 8.0f)];
    self.dot.layer.cornerRadius = 4.0f;
    self.dot.layer.borderWidth = kBoarderWidth;
    self.dot.clipsToBounds = YES;
    self.dot.layer.borderColor = self.dotColor.CGColor;
    [self.labelView addSubview:self.dot];
    
    self.focusText = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2, kLabelViewWidth, kLabelHeight)];
    [ConfigureView configureReadingTextLabel:self.focusText alpha:kGoldenRatioMinusOne];
    [self.labelView addSubview:self.focusText];

    self.previousWord3 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-3*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [ConfigureView configureReadingTextLabel:self.previousWord3 alpha:kHiddenControlRevealedAlhpa];
   [self.labelView addSubview:self.previousWord3];
    
    self.previousWord2 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-2*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [ConfigureView configureReadingTextLabel:self.previousWord2 alpha:kUINormaAlpha - 0.1];
  [self.labelView addSubview:self.previousWord2];
    
    self.previousWord = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [ConfigureView configureReadingTextLabel:self.previousWord alpha:kUINormaAlpha];
    [self.labelView addSubview:self.previousWord];
    
    self.nextWord = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight, kLabelViewWidth, kLabelHeight)];
    [ConfigureView configureReadingTextLabel:self.nextWord alpha:kUINormaAlpha];
    [self.labelView addSubview:self.nextWord];
    
    self.nextWord2 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [ConfigureView configureReadingTextLabel:self.nextWord2 alpha:kUINormaAlpha-0.1f];
    [self.labelView addSubview:self.nextWord2];
    
    self.nextWord3 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+2*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [ConfigureView configureReadingTextLabel:self.nextWord3 alpha:kUINormaAlpha-0.15f];
    [self.labelView addSubview:self.nextWord3];
    
    self.nextWord4 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+3*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [ConfigureView configureReadingTextLabel:self.nextWord4 alpha:kUINormaAlpha-0.175f];
    [self.labelView addSubview:self.nextWord4];
    [self updateFontSize];
}

- (void)updateFontSize {
    self.focusText.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize];
    self.chapterLabel.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-11];
    self.userInteractionTools.assistantTextView.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-8];
    self.previousWord3.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-11];
    self.previousWord2.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-11];
    self.previousWord.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-10];
    self.nextWord.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-10];
    self.nextWord2.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-11];
    self.nextWord3.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-12];
    self.nextWord4.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-13];
}

# pragma mark Update

- (void)update {
    self.userInteractionTools.assistantTextView.textColor = self.defaultButtonColor;
    if (self.readingInterfaceBOOLs.lightsOffActivated) {
        [self turnOffLight];
    }
    
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
        self.currentReadingPosition.wordIndex ++;
    } else if (self.timeIntervalBetweenIndex >= self.minSpeed) {
        self.currentReadingPosition.wordIndex --;
    }
    
    self.previousWord3.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+7];
    self.previousWord2.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+6];
    self.previousWord.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+5];
    self.focusText.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+4];
    self.nextWord.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+3];
    self.nextWord2.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+2];
    self.nextWord3.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+1];
    self.nextWord4.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex];
    
    
    if (self.readingInterfaceBOOLs.highlightVowelsActivated) {
        [self highlightVowels];
    }
    
    if (self.readingInterfaceBOOLs.highlightConsonantsActivated) {
        [self highlightConsonants];
    }
    
    if (self.readingInterfaceBOOLs.highlightUserSelectionActivated) {
        [self highlightUserSelected];
    }
    [self highlightPunctuationWithColor:[UIColor redColor]];
    if (self.readingInterfaceBOOLs.highlightAssistantTextActivated) {
        [self highlightAssistantTextWithColor:self.currentReadingPosition.highlightMovingTextColor];
    }
    
    if (self.currentReadingPosition.wordIndex >= self.wordsArray.count - 3) {
        [self stopTimer];
    }
    
    else {
        [self beginTimer];
        
    }
    
    self.dot.alpha = 0.8;
    [UIView animateWithDuration:self.timeIntervalBetweenIndex delay:kZero options:UIViewKeyframeAnimationOptionRepeat animations:^{
        self.dot.alpha = kZero;
    } completion:nil];
    
    float index = self.currentReadingPosition.wordIndex;
    float wordArray = self.wordsArray.count;
    float textFieldContentOffsetY = index/wordArray * self.userInteractionTools.assistantTextView.contentSize.height+50.0f;
    self.userInteractionTools.assistantTextView.contentOffset = CGPointMake(kZero, textFieldContentOffsetY);
    
}

- (void)beginTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)modifyTimeInterval: (float)time {
    if (!self.readingInterfaceBOOLs.breakingBegan) {
        self.timeIntervalBetweenIndex += time;
        self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, self.maxSpeed);
        self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, self.normalSpeed);
    } else if (self.readingInterfaceBOOLs.breakingBegan) {
        self.timeIntervalBetweenIndex += time;
        self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, self.maxSpeed);
        self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, self.minSpeed + 0.10f);
    }
    //        NSLog(@"%f %d", self.timeIntervalBetweenIndex, self.wordIndex);
}

#pragma mark Focus Text Methods

- (void)modifySpeed {
    if (self.readingInterfaceBOOLs.accelerationBegan) {
        //        NSLog(@"Accelerating!...");
        [self modifyTimeInterval:-self.acceleration];
    } else if (!self.readingInterfaceBOOLs.accelerationBegan) {
        //        NSLog(@"Decelerating!... %f",self.timeIntervalBetweenIndex);
        [self modifyTimeInterval:+self.deceleration];
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.userInteractionTools.userSelectedTextTextField resignFirstResponder];
    [self.nextResponder touchesBegan:touches withEvent:event];
    if (self.timeIntervalBetweenIndex < 6.575) {
        [UIView animateWithDuration:0.5 animations:^{
            self.pinView.layer.affineTransform = CGAffineTransformMakeRotation(self.timeIntervalBetweenIndex);
        }];
    }
    self.readingInterfaceBOOLs.accelerationBegan = YES;
    self.accelerationtimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Began %d", self.readingInterfaceBOOLs.accelerationBegan);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.readingInterfaceBOOLs.accelerationBegan = NO;
    [self.accelerationtimer invalidate];
    self.accelerationtimer = nil;
    self.deccelerationtimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Ended %d", self.readingInterfaceBOOLs.accelerationBegan);
    
    [UIView animateWithDuration:1.5 animations:^{
        self.userInteractionTools.speedPropertySelector.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 30);
        self.speedLabel.alpha = kZero;
    }];
    
    [self retractColorPalette];
    [self retractUserInputTextField];
    [self retractModifyFocusTextView];
    float index = self.currentReadingPosition.wordIndex;
    float wordArray = self.wordsArray.count;
    float textFieldContentOffsetY = index/wordArray * self.userInteractionTools.assistantTextView.contentSize.height;
    self.userInteractionTools.assistantTextView.contentOffset = CGPointMake(kZero, textFieldContentOffsetY);
    
}

- (void)pauseforPunctuation {
    [self modifyTimeInterval:+0.3];
}

- (void)startBreaking {
    [self modifyTimeInterval:+0.03f];
    [UIView animateWithDuration:4.0f animations:^{
        self.breakPedal.alpha = 0.50f;
        self.breakPedal.layer.shadowOpacity = 2.60f;
        self.breakPedal.layer.shadowOffset = CGSizeMake(2.0f, 5.0f);
        self.breakPedal.layer.shadowRadius = 30.0f;
    }];
    NSLog(@"Breaking!...%f", self.timeIntervalBetweenIndex);
    
}

- (void)breaking {
    if (self.userInteractionTools.breakPedalGesture.state == UIControlEventTouchDown) {
        self.readingInterfaceBOOLs.breakingBegan = YES;
        NSLog(@"break");
        self.readingInterfaceBOOLs.accelerationBegan = NO;
        [self.accelerationtimer invalidate];
        self.accelerationtimer = nil;
        [self.deccelerationtimer invalidate];
        self.deccelerationtimer = nil;
        self.breaktimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(startBreaking) userInfo:nil repeats:YES];
        NSLog(@"%f", self.timeIntervalBetweenIndex);
        
    } if (self.userInteractionTools.breakPedalGesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:4.0f animations:^{
            self.breakPedal.alpha = kUINormaAlpha;
            self.breakPedal.layer.shadowOpacity = kZero;
            self.breakPedal.layer.shadowRadius = kZero;
        }];
        [UIView animateWithDuration:1.5 animations:^{
            self.pinView.layer.affineTransform = CGAffineTransformMakeRotation(self.timeIntervalBetweenIndex);
            self.breakPedal.alpha = 0.25;
            
        }];
        self.readingInterfaceBOOLs.breakingBegan = NO;
        NSLog(@"break ended");
        [self.breaktimer invalidate];
        self.breaktimer = nil;
    }
    [self.speedLabel removeFromSuperview];
    
}

#pragma mark Modify Text Methods

- (void)highlightPunctuationWithColor: (UIColor *)color {
    NSCharacterSet *characterSet = [NSCharacterSet punctuationCharacterSet];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: self.focusText.attributedText];
    for (NSInteger charIdx = 0; charIdx < self.focusText.text.length; charIdx++){
        unichar currentCharacter = [self.focusText.text characterAtIndex:charIdx];
        BOOL isCharacterSet = [characterSet characterIsMember:currentCharacter];
        if (isCharacterSet) {
            //            [self pauseforPunctuation];
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(charIdx, 1)];
            [self.focusText setAttributedText: attributedString];
        }
    }
}

- (void)modifyTextWithString: (NSString *)characterSetString color: (UIColor *)color {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:characterSetString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: self.focusText.attributedText];
    for (NSInteger charIdx = 0; charIdx < self.focusText.text.length; charIdx++){
        unichar currentCharacter = [self.focusText.text characterAtIndex:charIdx];
        BOOL isCharacterSet = [characterSet characterIsMember:currentCharacter];
        if (isCharacterSet) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(charIdx, 1)];
            //            NSLog(@"%C is a %@", currentCharacter, isCharacterSet ? @"vowel" : @"consonant");
            [self.focusText setAttributedText: attributedString];
        }
    }
}

- (void)highlightAssistantTextWithColor: (UIColor *)color {
    NSCharacterSet *characterSet = [NSCharacterSet alphanumericCharacterSet];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: self.userInteractionTools.assistantTextView.attributedText];
    for (NSInteger charIdx = 0; charIdx < self.focusText.text.length; charIdx++){
        unichar currentWord = [self.focusText.text characterAtIndex:charIdx];
        BOOL isWord = [characterSet characterIsMember:currentWord];
        if (isWord) {
            
            self.currentReadingPosition.assistantTextRangeIndex = [([self.assistantTextRangeIndexArray objectAtIndex:self.currentReadingPosition.wordIndex+3])integerValue];
            self.currentReadingPosition.assistantTextRangeLength = [([self.assistantTextRangeLenghtArray objectAtIndex:self.currentReadingPosition.wordIndex+4])integerValue];
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(self.currentReadingPosition.assistantTextRangeIndex, self.currentReadingPosition.assistantTextRangeLength+1)];
            //                        NSLog(@"%lu, %lu, %d, %@", range, length, isWord, self.focusText.text);
            [self.userInteractionTools.assistantTextView setAttributedText: attributedString];
        }
    }
}

#pragma mark Vowels

- (void)toggleVowelsSelected {
    [self retractModifyFocusTextView];
    self.readingInterfaceBOOLs.highlightVowelsActivated = !self.readingInterfaceBOOLs.highlightVowelsActivated;
    self.textColorBeingModified = Vowels;
    
    if (self.readingInterfaceBOOLs.highlightVowelsActivated) {
        [self.userInteractionTools.toggleVowels addGestureRecognizer:self.userInteractionTools.openColorOptionsGesture];
        [UIView animateWithDuration:0.5 animations:^{
            self.userInteractionTools.toggleVowels.frame = CGRectMake(55, CGRectGetHeight(self.uiView.frame) - 140, kToggleButtonDimension, kToggleButtonDimension);
            self.userInteractionTools.toggleVowels.layer.shadowOpacity = 0.55f;
            self.userInteractionTools.toggleVowels.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.userInteractionTools.toggleVowels.backgroundColor = self.colorOne;
            self.userInteractionTools.toggleVowels.alpha = 1.0f;
        }];
    }
    if (!self.readingInterfaceBOOLs.highlightVowelsActivated) {
        [self.userInteractionTools.toggleConsonates removeGestureRecognizer:self.userInteractionTools.openColorOptionsGesture];
        [self retractColorPalette];
        [UIView animateWithDuration:0.5 animations:^{
            self.userInteractionTools.toggleVowels.frame = CGRectMake(55, CGRectGetHeight(self.uiView.frame) - 138, kToggleButtonDimension, kToggleButtonDimension);
            self.userInteractionTools.toggleVowels.layer.shadowOpacity = 0.30f;
            self.userInteractionTools.toggleVowels.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.userInteractionTools.toggleVowels.backgroundColor = self.defaultButtonColor;
            self.userInteractionTools.toggleVowels.alpha = kHiddenControlRevealedAlhpa;
        }];
    }
    
}

- (void)highlightVowels {
    [self modifyTextWithString:kVowels color:self.currentReadingPosition.highlightVowelColor];
}

#pragma mark Consonants

- (void)toggleConsonantsSelected {
    [self retractModifyFocusTextView];
    self.readingInterfaceBOOLs.highlightConsonantsActivated = !self.readingInterfaceBOOLs.highlightConsonantsActivated;
    self.textColorBeingModified = Consonants;
    [self updatePaletteOrigin];
    if (self.readingInterfaceBOOLs.highlightConsonantsActivated) {
        [self.userInteractionTools.toggleConsonates addGestureRecognizer:self.userInteractionTools.openColorOptionsGesture];
        [UIView animateWithDuration:0.5f animations:^{
            self.userInteractionTools.toggleConsonates.frame = CGRectMake(100, CGRectGetHeight(self.view.frame) - 95, kToggleButtonDimension, kToggleButtonDimension);
            self.userInteractionTools.toggleConsonates.layer.shadowOpacity = kUINormaAlpha;
            self.userInteractionTools.toggleConsonates.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.userInteractionTools.toggleConsonates.backgroundColor = self.currentReadingPosition.highlightConsonantColor;
            self.userInteractionTools.toggleConsonates.alpha = 1.0f;
        }];
    }
    if (!self.readingInterfaceBOOLs.highlightConsonantsActivated) {
        [self.userInteractionTools.toggleConsonates removeGestureRecognizer:self.userInteractionTools.openColorOptionsGesture];
        [self retractColorPalette];
        [UIView animateWithDuration:0.5f animations:^{
            self.userInteractionTools.toggleConsonates.frame = CGRectMake(100, CGRectGetHeight(self.view.frame) - 93, kToggleButtonDimension, kToggleButtonDimension);
            self.userInteractionTools.toggleConsonates.layer.shadowOpacity = 0.30f;
            self.userInteractionTools.toggleConsonates.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.userInteractionTools.toggleConsonates.backgroundColor = self.defaultButtonColor;
            self.userInteractionTools.toggleConsonates.alpha = kUINormaAlpha;
        }];
    }
}

- (void)highlightConsonants {
    [self modifyTextWithString:kConsonants color:self.currentReadingPosition.highlightConsonantColor];
}

#pragma mark UserSelected

- (void)toggleUserSelected {
    [self retractModifyFocusTextView];
    self.readingInterfaceBOOLs.highlightUserSelectionActivated = !self.readingInterfaceBOOLs.highlightUserSelectionActivated;
    self.textColorBeingModified = UserSelection;
    [self updatePaletteOrigin];
    [self openUserInputTextField];
    
    if (self.readingInterfaceBOOLs.highlightUserSelectionActivated) {
        [self.userInteractionTools.toggleUserSelections addGestureRecognizer:self.userInteractionTools.openColorOptionsGesture];
        [UIView animateWithDuration:0.5f animations:^{
            self.userInteractionTools.toggleUserSelections.frame = CGRectMake(35, CGRectGetHeight(self.view.frame) - 195, kToggleButtonDimension, kToggleButtonDimension);
            self.userInteractionTools.toggleUserSelections.layer.shadowOpacity = kUINormaAlpha;
            self.userInteractionTools.toggleUserSelections.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.userInteractionTools.toggleUserSelections.backgroundColor = self.currentReadingPosition.highlightUserSelectedTextColor;
            self.userInteractionTools.toggleUserSelections.alpha = 1.0f;
        }];
    }
    if (!self.readingInterfaceBOOLs.highlightUserSelectionActivated) {
        [self.userInteractionTools.toggleUserSelections removeGestureRecognizer:self.userInteractionTools.openColorOptionsGesture];
        [self retractColorPalette];
        [self retractUserInputTextField];
        [UIView animateWithDuration:0.5f animations:^{
            self.userInteractionTools.toggleUserSelections.frame = CGRectMake(35, CGRectGetHeight(self.view.frame) - 193, kToggleButtonDimension, kToggleButtonDimension);
            self.userInteractionTools.toggleUserSelections.layer.shadowOpacity = 0.30f;
            self.userInteractionTools.toggleUserSelections.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.userInteractionTools.toggleUserSelections.backgroundColor = self.defaultButtonColor;
            self.userInteractionTools.toggleUserSelections.alpha = kUINormaAlpha;
        }];
    }
}

- (void)highlightUserSelected {
    [self modifyTextWithString:self.userInteractionTools.userSelectedTextTextField.text color:self.currentReadingPosition.highlightUserSelectedTextColor];
    
}

#pragma mark Modify Colors

- (void)changeSelectedTextColor: (UIButton *)button {
    NSLog(@"buttonPressed %ld", (long)button.tag);
    
    UIButton *selectedButton = [self.view viewWithTag:button.tag];
    [UIView animateWithDuration:0.50f animations:^{
        selectedButton.alpha = 1.0f;
        selectedButton.layer.affineTransform = CGAffineTransformScale(button.layer.affineTransform, 1.05f, 1.20f);
        selectedButton.layer.shadowOpacity = 0.65f;
        selectedButton.layer.zPosition = 1.0f;
    } completion:^(BOOL finished) {
        selectedButton.tag = -1;
    }];
    switch (button.tag) {
        case 1:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorOne;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.colorOne;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorOne;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.colorOne;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorOne;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.colorOne;
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorTwo;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.colorTwo;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorTwo;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.colorTwo;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorTwo;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.colorTwo;
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorThree;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.colorThree;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorThree;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.colorThree;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorThree;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.colorThree;
                    break;
                default:
                    break;
            }
            break;
        case 4:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorFour;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.colorFour;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorFour;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.colorFour;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorFour;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.colorFour;
                    break;
                default:
                    break;
            }
            break;
        case 5:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorFive;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.colorFive;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorFive;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.colorFive;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorFive;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.colorFive;
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma Modify Speed Methods

- (void)speedPropertySelectorSwitch: (UISegmentedControl *)segmentController {
    [self refreshSpeedValues];
}

- (void)adjustSpeedUsingSlider: (UISlider *)slider {
    self.userInteractionTools.speedAdjusterSlider.alpha = kHiddenControlRevealedAlhpa;
    [self refreshSpeedValues];
}

- (void)refreshSpeedValues {
    SpeedAdjustmentSegmentSelected segmentSelected = self.userInteractionTools.speedPropertySelector.selectedSegmentIndex;
    
    switch (segmentSelected) {
        case NormalSpeed:
            self.speedShown = self.normalSpeed;
            self.normalSpeed = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = self.minSpeed;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = self.maxSpeed;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.colorOne;
            self.selectedSpeedToAdjustIndicator = @"normal speed";
            break;
        case MaximumSpeed:
            self.speedShown = self.maxSpeed;
            self.maxSpeed = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = 0.75f;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = 0.01f;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.currentReadingPosition.highlightUserSelectedTextColor;
            self.selectedSpeedToAdjustIndicator = @"max speed";
            break;
        case MinimumSpeed:
            self.speedShown = self.minSpeed;
            self.minSpeed = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = 1.0f;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = 0.01f;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.colorTwo;
            self.selectedSpeedToAdjustIndicator = @"min speed";
            break;
        case AccelerationSpeed:
            self.speedShown = self.acceleration;
            self.acceleration = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = 0.1f;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = 0.001f;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.colorThree;
            self.selectedSpeedToAdjustIndicator = @"acceleration";
            break;
        case Default:
            self.normalSpeed = 0.45;
            self.minSpeed = 1.0;
            self.maxSpeed = 0.15;
            self.acceleration = 0.002;
            self.deceleration = 0.0007;
            self.speedLabel.text = @"Default\nrestored";
            
            break;
        default:
            self.speedShown = self.maxSpeed;
            self.maxSpeed = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = 0.75f;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = 0.01f;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.colorFive;
            self.selectedSpeedToAdjustIndicator = @"normal speed";
            break;
    }
    [self.uiView addSubview:self.speedLabel];
    [self.uiView addSubview:self.userInteractionTools.speedPropertySelector];
    self.speedShown = self.userInteractionTools.speedAdjusterSlider.value;
    float wordsPerMinute = 1/self.speedShown * 60;
    if (segmentSelected == Default) {
        self.speedLabel.text = @"Default\nrestored";
    } else {
        self.speedLabel.text = [NSString stringWithFormat:@"%@\n%0.1f\nwords/min",self.selectedSpeedToAdjustIndicator, wordsPerMinute];
        [UIView animateWithDuration:1.0 animations:^{
            self.speedLabel.alpha = kUINormaAlpha;
            self.userInteractionTools.speedPropertySelector.frame = CGRectMake(0, CGRectGetHeight(self.uiView.frame) - 30, CGRectGetWidth(self.uiView.frame), 30);
            self.userInteractionTools.speedPropertySelector.alpha = kHiddenControlRevealedAlhpa;
            
        }];
    }
}

#pragma mark Modify UITransition Methods

- (void)toggleHideControls: (UIButton *)sender {
    self.readingInterfaceBOOLs.hideControlsActivated = !self.readingInterfaceBOOLs.hideControlsActivated;
    [self hideControls];
}

- (void)hideControls {
    if (!self.readingInterfaceBOOLs.hideControlsActivated) {
        [UIView animateWithDuration:1.0f animations:^{
            self.chapterLabel.alpha = kHiddenControlRevealedAlhpa;
            [self.userInteractionTools.hideControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.userInteractionTools.hideControlButton setTitle:@"hide" forState:UIControlStateNormal];
            self.userInteractionTools.hideControlButton.backgroundColor = [UIColor blackColor];
            self.userInteractionTools.hideControlButton.alpha = 0.25f;
            self.userInteractionTools.toggleVowels.alpha = kHiddenControlRevealedAlhpa + 0.1f;
            self.userInteractionTools.toggleConsonates.alpha = kHiddenControlRevealedAlhpa;
            self.userInteractionTools.toggleUserSelections.alpha = kHiddenControlRevealedAlhpa + 0.2f;
            self.userInteractionTools.speedAdjusterSlider.alpha = kUINormaAlpha;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:5.0f animations:^{
                self.chapterLabel.alpha = 0.25;
                self.chapterLabel.layer.shadowOpacity = kZero;
            }];
        }];
    }
    if (self.readingInterfaceBOOLs.hideControlsActivated) {
        [UIView animateWithDuration:1.0 animations:^{
            [self.userInteractionTools.hideControlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.userInteractionTools.hideControlButton setTitle:@"show" forState:UIControlStateNormal];
            self.userInteractionTools.hideControlButton.backgroundColor = [UIColor colorWithWhite:1.0f alpha:kZero];
            self.userInteractionTools.hideControlButton.alpha = kUINormaAlpha;
            self.userInteractionTools.toggleVowels.alpha = kZero;
            self.userInteractionTools.toggleConsonates.alpha = kZero;
            self.userInteractionTools.toggleUserSelections.alpha = kZero;
            self.userInteractionTools.speedAdjusterSlider.alpha = kZero;
            self.chapterLabel.alpha = kZero;
            
        }];
    }
}

- (void)revealHiddenUI {
    
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.hideControlButton.alpha = kUINormaAlpha;
        self.userInteractionTools.toggleFocusTextModification.alpha = kUINormaAlpha;
        self.labelView.alpha = 1.0f;
        self.userInteractionTools.hideControlButton.alpha = 0.25f;
        self.breakPedal.alpha = kUINormaAlpha;
        self.userInteractionTools.expandTextViewButton.alpha = 1.0f;
        self.userInteractionTools.fullScreenTextViewButton.alpha = 1.0f;
        self.userInteractionTools.flipXAxisButton.alpha = kUINormaAlpha;
        self.userInteractionTools.retractTextViewButton.alpha = 1.0f;
    }];
    
}

- (void)hideUI {
    self.dividerLabel.alpha = kZero;
    self.labelView.alpha = kZero;
    self.userInteractionTools.toggleFocusTextModification.alpha = kZero;
    self.userInteractionTools.hideControlButton.alpha = kZero;
    self.userInteractionTools.toggleVowels.alpha = kZero;
    self.userInteractionTools.toggleConsonates.alpha = kZero;
    self.userInteractionTools.toggleUserSelections.alpha = kZero;
    self.userInteractionTools.speedAdjusterSlider.alpha = kZero;
    self.chapterLabel.alpha = kZero;
    self.breakPedal.alpha = kZero;
    self.userInteractionTools.expandTextViewButton.alpha = kZero;
    self.userInteractionTools.fullScreenTextViewButton.alpha = kZero;
    self.userInteractionTools.flipXAxisButton.alpha = kZero;
    self.userInteractionTools.retractTextViewButton.alpha = kZero;
}

- (void)revealSpeedometer {
    [UIView animateWithDuration:1.50f animations:^{
        self.pinView.alpha = 1.0f;
        self.speedometerView.alpha = 0.15;
        self.speedometerReadLabel.alpha = kUINormaAlpha;
        self.progress.alpha = kUINormaAlpha;
        self.progressBar.alpha = kUINormaAlpha;
    }];
    
}

- (void)hideSpeedometer {
    [UIView animateWithDuration:0.50f animations:^{
        self.pinView.alpha = kZero;
        self.speedometerView.alpha = kZero;
        self.speedometerReadLabel.alpha = kZero;
        self.progress.alpha = kZero;
        self.progressBar.alpha = kZero;
    }];
    
}

- (void)updatePaletteOrigin {
    switch (self.textColorBeingModified) {
        case Vowels:
            self.colorPaletteXOrigin = self.userInteractionTools.toggleVowels.frame.origin.x+kColorPaletteWidth - 2;
            self.colorPaletteYOrigin = self.userInteractionTools.toggleVowels.frame.origin.y + 7;
            break;
        case Consonants:
            self.colorPaletteXOrigin = self.userInteractionTools.toggleConsonates.frame.origin.x+kColorPaletteWidth - 2;
            self.colorPaletteYOrigin = self.userInteractionTools.toggleConsonates.frame.origin.y + 7;
            break;
        case UserSelection:
            self.colorPaletteXOrigin = self.userInteractionTools.toggleUserSelections.frame.origin.x+kColorPaletteWidth - 2;
            self.colorPaletteYOrigin = self.userInteractionTools.toggleUserSelections.frame.origin.y + 7;
            break;
            
        default:
            break;
    }
}

- (void)openColorPalette: (UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state !=UIGestureRecognizerStateBegan) {
        return;
    }
    [self.uiView addSubview:self.color5];
    [self.uiView addSubview:self.color4];
    [self.uiView addSubview:self.color3];
    [self.uiView addSubview:self.color2];
    [self.uiView addSubview:self.color1];
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
    self.color1.alpha = 1.0f;
    self.color2.alpha = 1.0f;
    self.color3.alpha = 1.0f;
    self.color4.alpha = 1.0f;
    self.color5.alpha = 1.0f;
    [UIView animateWithDuration:0.0 animations:^{
        [self updatePaletteOrigin];
        self.color1.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color2.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color3.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color4.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color5.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.color1.frame = CGRectMake(self.colorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.color2.frame = CGRectMake(self.colorPaletteXOrigin + kColorPaletteWidth, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.color3.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *2), self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.color4.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *3), self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.color5.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *4), self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
        }];
    }];
    
}
- (void)retractColorPalette {
    [UIView animateWithDuration:0.25 animations:^{
        self.color1.alpha = kZero;
        self.color2.alpha = kZero;
        self.color3.alpha = kZero;
        self.color4.alpha = kZero;
        self.color5.alpha = kZero;
        
        self.color1.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color2.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color3.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color4.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.color5.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
    }completion:^(BOOL finished) {
        [self.color1 removeFromSuperview];
        [self.color2 removeFromSuperview];
        [self.color3 removeFromSuperview];
        [self.color4 removeFromSuperview];
        [self.color5 removeFromSuperview];
    }];
}

- (void)openUserInputTextField {
    [self.uiView addSubview:self.userInteractionTools.userSelectedTextTextField];
    [UIView animateWithDuration:1.20f animations:^{
        self.userInteractionTools.userSelectedTextTextField.frame = CGRectMake(kZero-1.0f, self.userInteractionTools.toggleUserSelections.frame.origin.y-155.0f, 90.0f, 30.0f);
    }];
}

- (void)retractUserInputTextField {
    [UIView animateWithDuration:1.0 animations:^{
        self.userInteractionTools.userSelectedTextTextField.frame = CGRectMake(-145.0f, self.userInteractionTools.toggleUserSelections.frame.origin.y-155.0f, 145.0f, 30.0f);
    }];
    
}

- (void)revealAssistantText: (UIButton *)sender {
    [self revealHiddenUI];
    self.readingInterfaceBOOLs.highlightAssistantTextActivated = YES;
    self.readingInterfaceBOOLs.textFieldRevealed = YES;
    [self.uiView addSubview:self.userInteractionTools.assistantTextView];
    [self.uiView addSubview:self.userInteractionTools.expandTextViewButton];
    [self.uiView addSubview:self.userInteractionTools.retractTextViewButton];
    [self.uiView addSubview:self.userInteractionTools.fullScreenTextViewButton];
    self.userInteractionTools.assistantTextView.text = self.bookTextRawString;
    self.userInteractionTools.fullScreenTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kAccessButtonHeight, kAccessButtonHeight);
    self.userInteractionTools.fullScreenTextViewButton.alpha = kZero;
    self.userInteractionTools.lightsOffButton.alpha = kZero;
    
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.flipXAxisButton.alpha = kUINormaAlpha;
        [self rotationTransformation:self.userInteractionTools.expandTextViewButton.layer degrees:k180Rotation];
        [self rotationTransformation:self.userInteractionTools.accessTextViewButton.layer degrees:k180Rotation];
        self.userInteractionTools.accessTextViewButton.alpha = kZero;
        self.userInteractionTools.assistantTextView.frame = CGRectMake(kZero, CGRectGetMidY(self.uiView.frame)-kControlButtonMidYOffset, CGRectGetWidth(self.uiView.frame)/2, kAssistantTextViewWidth);
        self.userInteractionTools.expandTextViewButton.alpha = 1.0f;
        self.userInteractionTools.retractTextViewButton.alpha = 1.0f;
        self.userInteractionTools.fullScreenTextViewButton.alpha =1.0f;
        self.userInteractionTools.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.retractTextViewButton.frame = CGRectMake(kControlButtonXOrigin, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.fullScreenTextViewButton.frame = CGRectMake(kControlButtonXOrigin+2*kControlButtonXOffset, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        
    }completion:^(BOOL finished) {
        self.userInteractionTools.accessTextViewButton.backgroundColor = [UIColor colorWithWhite:kZero alpha:kZero];
        self.userInteractionTools.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.accessTextViewButton.layer.borderWidth = kBoarderWidth;
        self.userInteractionTools.accessTextViewButton.layer.borderColor = self.defaultButtonColor.CGColor;
        [self.userInteractionTools.accessTextViewButton setTitle:@"+" forState:UIControlStateNormal];
        [self.userInteractionTools.accessTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
        self.userInteractionTools.accessTextViewButton.layer.cornerRadius = kAccessButtonHeight/2;
        self.userInteractionTools.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight);
        
    }];
}

- (void)retractAssistantText: (UIButton *)sender {
    self.readingInterfaceBOOLs.highlightAssistantTextActivated = NO;
    self.readingInterfaceBOOLs.textFieldRevealed = NO;
    [self.userInteractionTools.accessTextViewButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:kZero] forState:UIControlStateNormal];
    self.userInteractionTools.assistantTextView.frame = CGRectMake(-kAssistantTextViewWidth, CGRectGetMidY(self.uiView.frame)-kControlButtonMidYOffset, kAssistantTextViewWidth, kAssistantTextViewWidth);
    self.userInteractionTools.accessTextViewButton.backgroundColor = self.colorThree;
    self.userInteractionTools.accessTextViewButton.frame = CGRectMake(-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame), kAccessButtonWidth, kAccessButtonHeight);
    self.userInteractionTools.accessTextViewButton.layer.borderWidth = kZero;
    self.userInteractionTools.accessTextViewButton.layer.cornerRadius = kAccessButtonHeight;
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.expandTextViewButton.alpha = kZero;
        self.userInteractionTools.expandTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.userInteractionTools.expandTextViewButton.layer.affineTransform, M_PI/180.0 * 180);
        self.userInteractionTools.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.uiView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.accessTextViewButton.alpha = 1.0f;
        self.userInteractionTools.retractTextViewButton.alpha = kZero;
        self.userInteractionTools.fullScreenTextViewButton.alpha= kZero;
        
    } completion:^(BOOL finished) {
        [self.userInteractionTools.retractTextViewButton removeFromSuperview];
        [self.userInteractionTools.expandTextViewButton removeFromSuperview];
        [self.dividerLabel removeFromSuperview];
        [self.userInteractionTools.fullScreenTextViewButton removeFromSuperview];
        [self revealSpeedometer];
    }];
}

- (void)expandAssistantText: (UIButton *)sender {
    self.readingInterfaceBOOLs.textFieldRevealed = NO;
    self.readingInterfaceBOOLs.hideControlsActivated = YES;
    [self hideSpeedometer];
    [self.uiView addSubview:self.dividerLabel];
    [self.userInteractionTools.accessTextViewButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.65f] forState:UIControlStateNormal];
    [self.userInteractionTools.accessTextViewButton setTitle:@"-" forState:UIControlStateNormal];
    [self.userInteractionTools.accessTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    self.dividerLabel.frame = CGRectMake(CGRectGetMidX(self.uiView.frame), CGRectGetMidY(self.uiView.frame)+90.0f, 1.0f, 1.0f);
    self.userInteractionTools.fullScreenTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+140.0f, kAccessButtonHeight, kAccessButtonHeight);
    self.userInteractionTools.fullScreenTextViewButton.alpha = kZero;
    
    [UIView animateWithDuration:1.0f animations:^{
        self.dividerLabel.frame = CGRectMake(CGRectGetMidX(self.uiView.frame), kZero, 1.0f, CGRectGetHeight(self.uiView.frame));
        self.userInteractionTools.flipXAxisButton.alpha = kZero;
        self.userInteractionTools.expandTextViewButton.alpha = kZero;
        self.userInteractionTools.retractTextViewButton.alpha = kZero;
        self.userInteractionTools.expandTextViewButton.frame = CGRectMake(87.5f, self.uiView.frame.origin.y-65, 45, 45);
        self.userInteractionTools.retractTextViewButton.frame = CGRectMake(37.5f, self.uiView.frame.origin.y-65, 45, 45);
        self.userInteractionTools.assistantTextView.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, CGRectGetMidX(self.uiView.frame)-4.0f, CGRectGetHeight(self.uiView.frame)-70.0f);
        self.userInteractionTools.accessTextViewButton.alpha = 1.0f;
        self.userInteractionTools.fullScreenTextViewButton.alpha = 1.0f;
        self.dividerLabel.alpha = 0.2f;
        self.userInteractionTools.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+90.0f, kAccessButtonHeight, kAccessButtonHeight);
        self.userInteractionTools.expandTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.userInteractionTools.expandTextViewButton.layer.affineTransform, M_PI/180.0 * 180);
        self.userInteractionTools.accessTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.userInteractionTools.expandTextViewButton.layer.affineTransform, M_PI/180.0 * 180);
        
    }];
}

- (void)fullScreenTextView: (UIButton *)sender {
    [self hideSpeedometer];
    self.userInteractionTools.lightsOffButton = [[UIButton alloc]initWithFrame: CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2 + kAccessButtonHeight +5, CGRectGetMaxY(self.uiView.frame)-kControlButtonDimension, kAccessButtonHeight, kAccessButtonHeight)];
    [self configureRoundButton:self.userInteractionTools.lightsOffButton dimension:kAccessButtonHeight];
    self.userInteractionTools.lightsOffButton.alpha = kZero;
    [self.uiView addSubview:self.userInteractionTools.lightsOffButton];
    [self.userInteractionTools.lightsOffButton addTarget:self action:@selector(lightsOff:) forControlEvents:UIControlEventTouchUpInside];
    self.userInteractionTools.accessTextViewButton.alpha = 1.0f;
    
    [UIView animateWithDuration:0.75f animations:^{
        [self hideUI];
        self.userInteractionTools.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+90.0f, kAccessButtonHeight, kAccessButtonHeight);
        self.userInteractionTools.assistantTextView.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, CGRectGetMidX(self.uiView.frame)-4.0f, CGRectGetHeight(self.uiView.frame)-70.0f);
        self.userInteractionTools.accessTextViewButton.alpha = kZero;
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.75f animations:^{
            self.userInteractionTools.accessTextViewButton.titleLabel.text = @"-";
            self.userInteractionTools.assistantTextView.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, CGRectGetMaxX(self.uiView.frame), CGRectGetHeight(self.uiView.frame)-70.0f);
            self.userInteractionTools.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMaxY(self.uiView.frame)-kControlButtonDimension, kAccessButtonHeight, kAccessButtonHeight);
            self.userInteractionTools.accessTextViewButton.alpha = 1.0f;
            self.userInteractionTools.lightsOffButton.alpha = 1.0f;
            
        }];
    }
     ];
}

- (void)turnOnLight {
    [UIView animateWithDuration:0.5f animations:^{
        UIImage *paper = [UIImage imageNamed:@"ivoryPaper.png"];
        self.uiView.layer.contents = (__bridge id)paper.CGImage;
        self.uiView.backgroundColor = [UIColor colorWithRed:45.0f/255.0f green:55.0f/255.0f blue:64.0f/255.0f alpha:kZero];
        self.userInteractionTools.lightsOffButton.layer.borderColor = [UIColor blackColor].CGColor;
        self.currentReadingPosition.highlightMovingTextColor = [UIColor blackColor];
        self.userInteractionTools.assistantTextView.textColor = self.defaultButtonColor;
        self.userInteractionTools.accessTextViewButton.layer.borderColor = [UIColor blackColor].CGColor;
        self.userInteractionTools.lightsOffButton.layer.borderColor = [UIColor blackColor].CGColor;
        [self.userInteractionTools.accessTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    }];
}

- (void)turnOffLight {
    self.currentReadingPosition.highlightMovingTextColor = [UIColor colorWithRed:242.0f/255.0f green:203.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
    self.userInteractionTools.assistantTextView.textColor = [UIColor colorWithRed:242.0f/255.0f green:203.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
    self.userInteractionTools.accessTextViewButton.layer.borderColor = [UIColor colorWithRed:94.0f/255.0f green:85.0f/255.0f blue:82.0f/255.0f alpha:1.0f].CGColor;
    self.userInteractionTools.lightsOffButton.layer.borderColor = [UIColor colorWithRed:142.0f/255.0f green:168.0f/255.0f blue:178.0f/255.0f alpha:1.0f].CGColor;
    [self.userInteractionTools.accessTextViewButton setTitleColor:[UIColor colorWithRed:142.0f/255.0f green:168.0f/255.0f blue:178.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
}

- (void)lightsOff: (UIButton *)sender {
    self.readingInterfaceBOOLs.lightsOffActivated = !self.readingInterfaceBOOLs.lightsOffActivated;
    NSLog(@"pressed, %d", self.readingInterfaceBOOLs.lightsOffActivated);
}

- (void)expandModifyFocusTextView: (UIButton *)sender {
    [self.uiView addSubview:self.userInteractionTools.modifyFocusTextFontSizeSlider];
    [self.uiView addSubview:self.focusFontSizeLabel];
    
    [UIView animateWithDuration:1.50f animations:^{
        self.focusFontSizeLabel.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)-145.0f, CGRectGetMidY(self.uiView.frame)-kToggleButtonOffsetX + 30.0f, 30.0f, 30.0f);
        self.userInteractionTools.modifyFocusTextFontSizeSlider.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)-120.0f, CGRectGetMidY(self.uiView.frame)/5, 120.0f, 30.0f);
        self.userInteractionTools.toggleFocusTextModification.alpha = kZero;
    }];
}

- (void)retractModifyFocusTextView {
    static const float kEdgeOffset = 5.0f;
    static const float kHeightOffset = -14.0f;
    [UIView animateWithDuration:0.75f animations:^{
        self.focusFontSizeLabel.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, CGRectGetMidY(self.uiView.frame)-kToggleButtonOffsetX + 30.0f, 30.0f, 30.0f);
        self.userInteractionTools.modifyFocusTextFontSizeSlider.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, CGRectGetMidY(self.uiView.frame)/5, 120.0f, 30.0f);
        self.userInteractionTools.toggleFocusTextModification.alpha = 1.0f;
        self.color1.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
        self.color2.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
        self.color3.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
        self.color4.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
        self.color5.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
    }completion:^(BOOL finished) {
        [self.focusFontSizeLabel removeFromSuperview];
        [self.userInteractionTools.modifyFocusTextFontSizeSlider removeFromSuperview];
    }];
    
}

- (void)adjustFontSize: (UISlider *)sender {
    self.currentReadingPosition.mainFontSize = self.userInteractionTools.modifyFocusTextFontSizeSlider.value;
    self.focusFontSizeLabel.text = [NSString stringWithFormat:@"%0.1f",self.currentReadingPosition.mainFontSize];
    self.focusFontSizeLabel.font = [UIFont fontWithName:(self.fontType) size:12.0f];
    [self updateFontSize];
}

- (void)flipXAxis: (UIButton *)sender {
    self.uiView.layer.transform = CATransform3DRotate(self.uiView.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
    [self flipUI];
    
}
- (void)flipUI {
    self.currentReadingPosition.xAxisFlipped = !self.currentReadingPosition.xAxisFlipped;
    //    self.uiView.layer.borderWidth = kBoarderWidth;
    //    self.labelView.layer.borderWidth = kBoarderWidth;
    
    UIView *transitionView = [[UIView alloc]initWithFrame:self.uiView.frame];
    [self.uiView addSubview:transitionView];
    transitionView.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:0.5f animations:^{
        transitionView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            transitionView.alpha = kZero;
        }];
        if (self.currentReadingPosition.xAxisFlipped) {
            self.labelView.frame = CGRectMake(CGRectGetWidth(self.view.frame)*kOneMinusGoldenRatioMinusOne-150, CGRectGetMaxY(self.view.frame)*kOneMinusGoldenRatioMinusOne-15.0f, 200.0f, 150.0f);
        }
        if (!self.currentReadingPosition.xAxisFlipped) {
            self.labelView.frame = CGRectMake(CGRectGetWidth(self.view.frame)*kGoldenRatioMinusOne-100.0f, CGRectGetMaxY(self.view.frame)*kOneMinusGoldenRatioMinusOne-15.0f, 200.0f, 150.0f);
        }
        [transitionView removeFromSuperview];
        self.userInteractionTools.assistantTextView.layer.transform = CATransform3DRotate(self.userInteractionTools.assistantTextView.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.speedLabel.layer.transform = CATransform3DRotate(self.speedLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.speedometerReadLabel.layer.transform = CATransform3DRotate(self.speedometerReadLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.focusFontSizeLabel.layer.transform = CATransform3DRotate(self.focusFontSizeLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.hideControlButton.layer.transform = CATransform3DRotate(self.userInteractionTools.hideControlButton.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.toggleConsonates.layer.transform = CATransform3DRotate(self.userInteractionTools.toggleConsonates.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.toggleUserSelections.layer.transform = CATransform3DRotate(self.userInteractionTools.toggleUserSelections.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.speedPropertySelector.layer.transform = CATransform3DRotate(self.userInteractionTools.speedPropertySelector.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.userSelectedTextTextField.layer.transform = CATransform3DRotate(self.userInteractionTools.userSelectedTextTextField.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
    }];
}

- (void)configureRoundButton: (UIButton *)button dimension: (float)dimension{
    button.layer.borderWidth = kBoarderWidth;
    button.layer.borderColor = self.defaultButtonColor.CGColor;
    button.layer.cornerRadius = dimension/2;
    button.layer.shadowOffset = CGSizeMake(-1, 6.0f);
    button.layer.shadowOpacity = kShadowOpacity;
    [button setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithWhite:kZero alpha:kZero];
    [self.uiView addSubview:button];
}

- (void)rotationTransformation: (CALayer *)layer degrees: (float)degrees{
    layer.affineTransform = CGAffineTransformRotate(layer.affineTransform, M_PI/k180Rotation * degrees);
}

- (void)presentDictionary: (UIButton *)sender {
    [self stopTimer];
    self.readingInterfaceBOOLs.hideControlsActivated = YES;
    [self hideControls];
    //    [self dictionaryHasDefinitionForTerm];
    NSString *focusTextNoPunctuation = [self.focusText.text stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
    self.dictionaryViewController = [[UIReferenceLibraryViewController alloc]initWithTerm:focusTextNoPunctuation];
    self.dictionaryViewController.view.layer.borderWidth = kBoarderWidth;
    self.dictionaryViewController.view.layer.borderColor = self.defaultButtonColor.CGColor;
    self.dictionaryViewController.view.alpha = 0.67;
    self.dictionaryViewController.navigationController.navigationBar.tintColor = [UIColor redColor];
    self.dictionaryViewController.view.frame = CGRectMake(kZero, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.uiView.frame), CGRectGetHeight(self.uiView.frame)/2);
    [self.uiView addSubview:self.dictionaryViewController.view];
    
    self.userInteractionTools.retractDictionaryButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)/2-kAccessButtonHeight/2, CGRectGetHeight(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight)];
    [self.userInteractionTools.retractDictionaryButton setTitle:@"<" forState:UIControlStateNormal];
    [self rotationTransformation:self.userInteractionTools.retractDictionaryButton.layer degrees:-k180Rotation/2];
    self.userInteractionTools.retractDictionaryButton.layer.zPosition = 1.50f;
    [self.userInteractionTools.retractDictionaryButton addTarget:self action:@selector(retractDictionary:) forControlEvents:UIControlEventTouchUpInside];
    [self configureRoundButton:self.userInteractionTools.retractDictionaryButton dimension:kAccessButtonHeight];
    [UIView animateWithDuration:0.5f animations:^{
        self.userInteractionTools.retractDictionaryButton.frame = CGRectMake(CGRectGetWidth(self.uiView.frame)/2-kAccessButtonHeight/2, CGRectGetHeight(self.uiView.frame)/2-kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight);
        self.dictionaryViewController.view.frame = CGRectMake(kZero, CGRectGetHeight(self.uiView.frame)/2, CGRectGetWidth(self.uiView.frame), CGRectGetHeight(self.uiView.frame)/2);
        [self rotationTransformation:self.userInteractionTools.presentDictionaryButton.layer degrees:k180Rotation];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            self.userInteractionTools.presentDictionaryButton.alpha = kZero;
        }];
    }];
}

- (void)retractDictionary: (UIButton *)sender {
    [self beginTimer];
    [UIView animateWithDuration:0.5f animations:^{
        self.userInteractionTools.presentDictionaryButton.alpha = 1.0f;
        self.userInteractionTools.retractDictionaryButton.frame = CGRectMake(CGRectGetWidth(self.uiView.frame)/2-kAccessButtonHeight/2, CGRectGetHeight(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight);
        self.dictionaryViewController.view.frame = CGRectMake(kZero, CGRectGetHeight(self.uiView.frame), CGRectGetWidth(self.uiView.frame), CGRectGetHeight(self.uiView.frame)/2);
        [self rotationTransformation:self.userInteractionTools.presentDictionaryButton.layer degrees:k180Rotation];
    }completion:^(BOOL finished) {
        [self.userInteractionTools.retractDictionaryButton removeFromSuperview];
        [self.dictionaryViewController.view removeFromSuperview];
    }];
}

- (void)toggleSpeedometerDetails: (UIButton *)sender {
    
}

#pragma TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.userInteractionTools.userSelectedTextTextField resignFirstResponder];
    return YES;
}


@end
