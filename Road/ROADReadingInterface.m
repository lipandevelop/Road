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
#import "UIUserInteractionTools.h"

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


#pragma mark DisplayData

@property (nonatomic, strong) NSMutableArray *chaptersArray;
@property (nonatomic, strong) NSMutableArray *wordsArray;
@property (nonatomic, strong) NSMutableArray *assistantTextRangeIndexArray;
@property (nonatomic, strong) NSMutableArray *assistantTextRangeLenghtArray;
@property (nonatomic, strong) NSString *bookTextRawString;
@property (nonatomic, strong) NSString *bookTextString;
@property (nonatomic, strong) NSString *currentChapter;

#pragma mark UI Display Properties
@property (nonatomic, strong) UIView *labelView;
@property (nonatomic, strong) UIView *uiView;
@property (nonatomic, strong) UIView *lightsOffView;
@property (nonatomic, strong) UILabel *dot;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UIView *progress;

@property (nonatomic, strong) UILabel *chapterLabel;
@property (nonatomic, strong) UILabel *focusText;
@property (nonatomic, strong) UILabel *previousWord3;
@property (nonatomic, strong) UILabel *previousWord2;
@property (nonatomic, strong) UILabel *previousWord;
@property (nonatomic, strong) UILabel *nextWord;
@property (nonatomic, strong) UILabel *nextWord2;
@property (nonatomic, strong) UILabel *nextWord3;
@property (nonatomic, strong) UILabel *nextWord4;
@property (nonatomic, strong) UITextView *assistantTextView;
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

#pragma mark BOOL Properties

@property (nonatomic, assign) BOOL accelerationBegan;
@property (nonatomic, assign) BOOL breakingBegan;
@property (nonatomic, assign) BOOL highlightVowelsActivated;
@property (nonatomic, assign) BOOL highlightConsonantsActivated;
@property (nonatomic, assign) BOOL highlightUserSelectionActivated;
@property (nonatomic, assign) BOOL highlightColorSelected;
@property (nonatomic, assign) BOOL hideControlsActivated;
@property (nonatomic, assign) BOOL textFieldRevealed;
@property (nonatomic, assign) BOOL highlightAssistantTextActivated;
@property (nonatomic, assign) BOOL lightsOffActivated;

#pragma mark Speed Properties

@property (nonatomic, assign) float normalSpeed;
@property (nonatomic, assign) float maxSpeed;
@property (nonatomic, assign) float minSpeed;
@property (nonatomic, assign) float acceleration;
@property (nonatomic, assign) float deceleration;
@property (nonatomic, assign) float speedShown;

#pragma mark Interaction Properties

@property (nonatomic, strong) UIView *breakPedal;
@property (nonatomic, strong) UILongPressGestureRecognizer *breakPedalGesture;
@property (nonatomic, assign) CGRect breakPedalFrame;
@property (nonatomic, strong) UIButton *toggleFocusTextModification;
@property (nonatomic, strong) UIButton *hideControlButton;
@property (nonatomic, strong) UIButton *toggleConsonates;
@property (nonatomic, strong) UIButton *toggleVowels;
@property (nonatomic, strong) UIButton *toggleUserSelections;
@property (nonatomic, strong) UIButton *presentDictionaryButton;
@property (nonatomic, strong) UIButton *retractDictionaryButton;
@property (nonatomic, strong) UIButton *restoreDefaultButton;
@property (nonatomic, strong) UIButton *accessTextViewButton;
@property (nonatomic, strong) UIButton *expandTextViewButton;
@property (nonatomic, strong) UIButton *fullScreenTextViewButton;
@property (nonatomic, strong) UIButton *lightsOffButton;
@property (nonatomic, strong) UIButton *exitReadView;
@property (nonatomic, strong) UIButton *retractTextViewButton;
@property (nonatomic, strong) UIButton *flipXAxisButton;
@property (nonatomic, strong) UILongPressGestureRecognizer *openColorOptionsGesture;
@property (nonatomic, strong) UISlider *speedAdjusterSlider;
@property (nonatomic, strong) UISlider *modifyFocusTextFontSizeSlider;
@property (nonatomic, strong) UIView *speedometerView;
@property (nonatomic, strong) UIView *pinView;
@property (nonatomic, strong) UISegmentedControl *speedPropertySelector;
@property (nonatomic, strong) UITextField *userSelectedTextTextField;

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
    
    self.dotColor = [UIColor colorWithRed:195.0f/255.0f green:25.0f/255.0f blue:25.0f/255.0f alpha:1.0f];
    
    self.colorOne = [UIColor colorWithRed:254.0f/255.0f green:82.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
    self.colorTwo = [UIColor colorWithRed:136.0f/255.0f green:14.0f/255.0f blue:79.0f/255.0f alpha:1.0f];
    self.colorThree = [UIColor colorWithRed:11.0f/255.0f green:73.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
    self.colorFour = [UIColor colorWithRed:71.0f/255.0f green:215.0f/255.0f blue:193.0f/255.0f alpha:1.0f];
    self.colorFive = [UIColor colorWithRed:253.0f/255.0f green:196.0f/255.0f blue:2.0f/255.0f alpha:1.0f];
    self.defaultButtonColor = [UIColor colorWithRed:98.0f/255.0f green:91.0f/255.0f blue:77.0f/255.0f alpha:0.8f];
    
    
    
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
    self.speedometerReadLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    self.speedometerReadLabel.alpha = kUINormaAlpha;
    self.speedometerReadLabel.textAlignment = NSTextAlignmentCenter;
    
    self.toggleFocusTextModification = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)-kAccessButtonHeight, CGRectGetMidY(self.uiView.frame)-kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight)];
    [self configureRoundButton:self.toggleFocusTextModification dimension:kAccessButtonHeight];
    self.toggleFocusTextModification.layer.cornerRadius = kAccessButtonHeight;
    [self.toggleFocusTextModification setTitle:@"+A" forState:UIControlStateNormal];
    [self.toggleFocusTextModification setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.toggleFocusTextModification.titleLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    [self.toggleFocusTextModification addTarget:self action:@selector(expandModifyFocusTextView:) forControlEvents:UIControlEventTouchUpInside];
    
    self.modifyFocusTextFontSizeSlider = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, CGRectGetHeight(self.uiView.frame)/5 + 30.0f, 120.0f, 30.0f)];
    [self rotationTransformation:self.modifyFocusTextFontSizeSlider.layer degrees:180.0f];
    self.modifyFocusTextFontSizeSlider.tintColor = self.colorFive;
    self.modifyFocusTextFontSizeSlider.layer.shadowOffset = CGSizeMake(-1.0f, 6.0);
    self.modifyFocusTextFontSizeSlider.layer.shadowOpacity = 0.10f;
    self.modifyFocusTextFontSizeSlider.value = self.currentReadingPosition.mainFontSize;
    self.modifyFocusTextFontSizeSlider.maximumValue = 32.0f;
    self.modifyFocusTextFontSizeSlider.minimumValue = 22.0f;
    [self.modifyFocusTextFontSizeSlider addTarget:self action:@selector(adjustFontSize:) forControlEvents:UIControlEventValueChanged];
    
    self.focusFontSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, CGRectGetMidY(self.uiView.frame)-kToggleButtonOffsetX + 30.0, 30.0f, 30.0f)];
    self.focusFontSizeLabel.text = @"+A";
    self.focusFontSizeLabel.textColor = self.defaultButtonColor;
    //    self.focusFontSizeLabel.alpha = kUINormaAlpha;
    
    self.hideControlButton =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*kGoldenRatioMinusOne, CGRectGetMaxY(self.uiView.frame)/1.15203398875, 35.0f, 35.0f)];
    self.hideControlButton.layer.borderWidth = kBoarderWidth;
    self.hideControlButton.layer.borderColor = [UIColor blackColor].CGColor;
    [self.hideControlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.hideControlButton setTitle:@"show" forState:UIControlStateNormal];
    self.hideControlButton.titleLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    self.hideControlButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.hideControlButton.alpha = kUINormaAlpha;
    self.hideControlButton.layer.cornerRadius = self.hideControlButton.frame.size.width/2;
    [self.hideControlButton addTarget:self action:@selector(toggleHideControls:) forControlEvents:UIControlEventTouchUpInside];
    
    self.breakPedalGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(breaking)];
    self.breakPedalGesture.minimumPressDuration = 0.01;
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
    [self.breakPedal addGestureRecognizer:self.breakPedalGesture];
    
    self.openColorOptionsGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(openColorPalette:)];
    self.openColorOptionsGesture.minimumPressDuration = 0.30f;
    
    self.highlightButtonLocationFrames = CGRectMake(100, CGRectGetHeight(self.uiView.frame) - 95, kToggleButtonDimension, kToggleButtonDimension);
    self.toggleVowels = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.toggleVowels addTarget:self action:@selector(toggleVowelsSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.toggleVowels buttonLayer:self.toggleVowels.layer color: self.defaultButtonColor string:@"æ"];
    self.toggleVowels.layer.affineTransform = CGAffineTransformMakeTranslation(-45, -40);
    
    self.toggleConsonates = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.toggleConsonates addTarget:self action:@selector(toggleConsonantsSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.toggleConsonates buttonLayer:self.toggleConsonates.layer color:self.defaultButtonColor string:@"ɳ"];
    
    self.toggleUserSelections = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.toggleUserSelections addTarget:self action:@selector(toggleUserSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.toggleUserSelections buttonLayer:self.toggleUserSelections.layer color:self.defaultButtonColor string:@"u"];
    self.toggleUserSelections.layer.affineTransform = CGAffineTransformMakeTranslation(-65, -100);
    
    self.presentDictionaryButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)-kAccessButtonHeight, CGRectGetMidY(self.uiView.frame)-2*kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight)];
    [self configureRoundButton:self.presentDictionaryButton dimension:kAccessButtonHeight];
    self.presentDictionaryButton.layer.cornerRadius = kAccessButtonHeight;
    [self.presentDictionaryButton setTitle:@"D" forState:UIControlStateNormal];
    [self.presentDictionaryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.presentDictionaryButton.titleLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    [self.presentDictionaryButton addTarget:self action:@selector(presentDictionary:) forControlEvents:UIControlEventTouchUpInside];
    
    self.flipXAxisButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.uiView.frame)+25.0f, CGRectGetHeight(self.uiView.frame)-80.0f, kAccessButtonHeight, kAccessButtonHeight)];
    [self.flipXAxisButton addTarget:self action:@selector(flipXAxis:) forControlEvents:UIControlEventTouchUpInside];
    self.flipXAxisButton.layer.borderWidth = kBoarderWidth;
    self.flipXAxisButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.flipXAxisButton.layer.shadowOpacity = kShadowOpacity;
    self.flipXAxisButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.flipXAxisButton.layer.contents = (__bridge id)leftHandImage.CGImage;
    self.flipXAxisButton.layer.contentsGravity = kCAGravityResizeAspect;
    self.flipXAxisButton.layer.transform = CATransform3DRotate(self.flipXAxisButton.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
    
    self.flipXAxisButton.alpha = kUINormaAlpha;
    
    self.speedAdjusterSlider = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*kOneMinusGoldenRatioMinusOne, CGRectGetMaxY(self.uiView.frame)/kGoldenRatio, 120, 30)];
    [self.speedAdjusterSlider addTarget:self action:@selector(adjustSpeedUsingSlider:) forControlEvents:UIControlEventValueChanged];
    [self rotationTransformation:self.speedAdjusterSlider.layer degrees:-40.0f];
    self.speedAdjusterSlider.layer.affineTransform = CGAffineTransformTranslate(self.speedAdjusterSlider.layer.affineTransform, 30.0f, 40.0f);
    self.speedAdjusterSlider.tintColor = self.defaultButtonColor;
    self.speedAdjusterSlider.alpha = kZero;
    self.speedAdjusterSlider.value = 1/self.normalSpeed;
    
    self.speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*kOneMinusGoldenRatioMinusOne, CGRectGetMaxY(self.uiView.frame)/kGoldenRatio, 220, 60)];
    self.speedLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    self.speedLabel.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.speedLabel.layer.shadowOpacity = kShadowOpacity;
    self.speedLabel.numberOfLines = kZero;
    self.speedLabel.alpha = kZero;
    
    self.speedPropertySelector = [[UISegmentedControl alloc]initWithItems:self.speedArray];
    self.speedPropertySelector.frame = CGRectMake(kZero, CGRectGetHeight(self.uiView.frame), CGRectGetWidth(self.uiView.frame), 30);
    self.speedPropertySelector.selectedSegmentIndex = kZero;
    self.speedPropertySelector.layer.borderWidth = kBoarderWidth;
    self.speedPropertySelector.layer.borderColor = [UIColor blackColor].CGColor;
    self.speedPropertySelector.tintColor = [UIColor blackColor];
    self.speedPropertySelector.alpha = kUINormaAlpha;
    [self.speedPropertySelector addTarget:self action:@selector(speedPropertySelectorSwitch:) forControlEvents:UIControlEventValueChanged];
    UIFont *speedControlfont = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    NSDictionary *speedAttributes = [NSDictionary dictionaryWithObject:speedControlfont forKey:NSFontAttributeName];
    [self.speedPropertySelector setTitleTextAttributes:speedAttributes forState:UIControlStateNormal];
    
    self.userSelectedTextTextField = [[UITextField alloc]initWithFrame:CGRectMake(-145.0f, self.toggleUserSelections.frame.origin.y-155.0f, 145.0f, 30.0f)];
    self.userSelectedTextTextField.layer.borderWidth = 0.75;
    self.userSelectedTextTextField.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:kUINormaAlpha].CGColor;
    self.userSelectedTextTextField.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.userSelectedTextTextField.layer.shadowOpacity = kShadowOpacity;
    self.userSelectedTextTextField.placeholder = @"Customize";
    self.userSelectedTextTextField.textAlignment = NSTextAlignmentCenter;
    self.userSelectedTextTextField.autocorrectionType = NO;
    self.userSelectedTextTextField.autocapitalizationType = NO;
    self.userSelectedTextTextField.keyboardType = UIKeyboardTypeAlphabet;
    self.userSelectedTextTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userSelectedTextTextField.font = [UIFont fontWithName:(@"AmericanTypewriter") size:kSmallFontSize];
    
    self.accessTextViewButton = [[UIButton alloc]initWithFrame:CGRectMake(-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame), kAccessButtonWidth, kAccessButtonHeight)];
    self.accessTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.accessTextViewButton.layer.shadowOpacity = kShadowOpacity;
    self.accessTextViewButton.layer.cornerRadius = kAccessButtonHeight;
    self.accessTextViewButton.backgroundColor = self.colorThree;
    [self.accessTextViewButton addTarget:self action:@selector(revealAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.expandTextViewButton = [[UIButton alloc]init];
    self.expandTextViewButton.alpha = 0.1;
    [self.expandTextViewButton setTitle:@"+" forState:UIControlStateNormal];
    [self.expandTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    self.expandTextViewButton.layer.borderWidth = kBoarderWidth;
    self.expandTextViewButton.layer.borderColor = self.defaultButtonColor.CGColor;
    self.expandTextViewButton.layer.cornerRadius = 22.5f;
    self.expandTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.expandTextViewButton.layer.shadowOpacity = kShadowOpacity;
    [self.expandTextViewButton addTarget:self action:@selector(expandAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.fullScreenTextViewButton = [[UIButton alloc]init];
    self.fullScreenTextViewButton.alpha = 0.1;
    [self.fullScreenTextViewButton setTitle:@">" forState:UIControlStateNormal];
    [self.fullScreenTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    self.fullScreenTextViewButton.layer.borderWidth = kBoarderWidth;
    self.fullScreenTextViewButton.layer.borderColor = self.defaultButtonColor.CGColor;
    self.fullScreenTextViewButton.layer.cornerRadius = 22.5f;
    self.fullScreenTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.fullScreenTextViewButton.layer.shadowOpacity = kShadowOpacity;
    [self.fullScreenTextViewButton addTarget:self action:@selector(fullScreenTextView:) forControlEvents:UIControlEventTouchDown];
    
    self.retractTextViewButton = [[UIButton alloc]init];
    self.retractTextViewButton.alpha = 0.1;
    [self.retractTextViewButton setTitle:@"<" forState:UIControlStateNormal];
    [self.retractTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    self.retractTextViewButton.layer.borderWidth = kBoarderWidth;
    self.retractTextViewButton.layer.borderColor = self.defaultButtonColor.CGColor;
    self.retractTextViewButton.layer.cornerRadius = 22.5f;
    self.retractTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.retractTextViewButton.layer.shadowOpacity = kShadowOpacity;
    [self.retractTextViewButton addTarget:self action:@selector(retractAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.assistantTextView = [[UITextView alloc]initWithFrame:CGRectMake(-120.0f, CGRectGetMidY(self.uiView.frame)-40, 120.0f, 120.0f)];
    self.assistantTextView.layer.zPosition = 0.9;
    self.assistantTextView.text = self.bookTextRawString;
    self.assistantTextView.textColor = self.defaultButtonColor;
    self.assistantTextView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0];
    self.assistantTextView.alpha = 1.0f;
    self.assistantTextView.editable = NO;
    
    self.dividerLabel = [[UILabel alloc]init];
    self.dividerLabel.backgroundColor = self.defaultButtonColor;
    self.dividerLabel.alpha = 0.20f;
    
    self.color1 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, CGRectGetHeight(self.uiView.frame)*kColorPaletteheightMultiple, kColorPaletteWidth, kColorPaletteHeight)];
    self.userSelectedTextTextField.delegate = self;
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
    [self.uiView addSubview:self.speedAdjusterSlider];
    [self.uiView addSubview:self.breakPedal];
    [self.uiView addSubview:self.hideControlButton];
    [self.uiView addSubview:self.pinView];
    [self.uiView addSubview:self.speedometerReadLabel];
    [self.uiView addSubview:self.accessTextViewButton];
    [self.uiView addSubview:self.speedometerView];
    [self.uiView addSubview:self.toggleFocusTextModification];
    [self.uiView  addSubview:self.flipXAxisButton];
    [self.uiView setNeedsDisplay];
}

#pragma mark Modify Toggle Buttons

- (void)modifyToggleButtonWithButton: (UIButton *)button buttonLayer:(CALayer *)layer color: (UIColor*)color string: (NSString *)string {
    layer.cornerRadius = button.frame.size.width/2;
    layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    layer.shadowOpacity = kShadowOpacity;
    layer.zPosition = 1.0f;
    [button setTitle:string forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:12];
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
    
    self.focusText = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2, kLabelViewWidth, kLabelHeight)];
    self.focusText.numberOfLines = kZero;
    self.focusText.textColor = [UIColor blackColor];
    self.focusText.alpha = kGoldenRatioMinusOne;
    self.focusText.textAlignment = NSTextAlignmentCenter;
    [self.labelView addSubview:self.focusText];
    
    self.dot = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.labelView.bounds)/2-4.0f, CGRectGetHeight(self.labelView.bounds)/2+kLabelHeightOffset, 8.0f, 8.0f)];
    self.dot.layer.cornerRadius = 4.0f;
    self.dot.layer.borderWidth = kBoarderWidth;
    self.dot.clipsToBounds = YES;
    self.dot.layer.borderColor = self.dotColor.CGColor;
    [self.labelView addSubview:self.dot];
    
    self.previousWord3 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-3*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    self.previousWord3.numberOfLines = kZero;
    self.previousWord3.textColor = self.dotColor;
    self.previousWord3.alpha = kHiddenControlRevealedAlhpa;
    self.previousWord3.textAlignment = NSTextAlignmentCenter;
    [self.labelView addSubview:self.previousWord3];
    
    self.previousWord2 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-2*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    self.previousWord2.numberOfLines = kZero;
    self.previousWord2.textColor = [UIColor blackColor];
    self.previousWord2.alpha = kUINormaAlpha - 0.1;
    self.previousWord2.textAlignment = NSTextAlignmentCenter;
    [self.labelView addSubview:self.previousWord2];
    
    self.previousWord = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    self.previousWord.numberOfLines = kZero;
    self.previousWord.textColor = [UIColor blackColor];
    self.previousWord.alpha = kUINormaAlpha;
    self.previousWord.textAlignment = NSTextAlignmentCenter;
    [self.labelView addSubview:self.previousWord];
    
    self.nextWord = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight, kLabelViewWidth, kLabelHeight)];
    self.nextWord.numberOfLines = kZero;
    self.nextWord.textColor = [UIColor blackColor];
    self.nextWord.alpha = kUINormaAlpha;
    self.nextWord.textAlignment = NSTextAlignmentCenter;
    [self.labelView addSubview:self.nextWord];
    
    self.nextWord2 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    self.nextWord2.numberOfLines = kZero;
    self.nextWord2.textColor = [UIColor blackColor];
    self.nextWord2.alpha = kUINormaAlpha-0.1f;
    self.nextWord2.textAlignment = NSTextAlignmentCenter;
    [self.labelView addSubview:self.nextWord2];
    
    self.nextWord3 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+2*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    self.nextWord3.numberOfLines = kZero;
    self.nextWord3.textColor = [UIColor blackColor];
    self.nextWord3.alpha = kUINormaAlpha-0.15f;
    self.nextWord3.textAlignment = NSTextAlignmentCenter;
    [self.labelView addSubview:self.nextWord3];
    
    self.nextWord4 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+3*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    self.nextWord4.numberOfLines = kZero;
    self.nextWord4.textColor = [UIColor blackColor];
    self.nextWord4.alpha = kUINormaAlpha-0.175;
    self.nextWord4.textAlignment = NSTextAlignmentCenter;
    [self.labelView addSubview:self.nextWord4];
    [self updateFontSize];
}

- (void)updateFontSize {
    self.focusText.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize];
    self.chapterLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-11];
    self.assistantTextView.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-8];
    self.previousWord3.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-11];
    self.previousWord2.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-11];
    self.previousWord.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-10];
    self.nextWord.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-10];
    self.nextWord2.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-11];
    self.nextWord3.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-12];
    self.nextWord4.font = [UIFont fontWithName:(@"AmericanTypewriter") size:self.currentReadingPosition.mainFontSize-13];
}

# pragma mark Update

- (void)update {
    self.assistantTextView.textColor = self.defaultButtonColor;
    if (self.lightsOffActivated) {
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
    
    
    if (self.highlightVowelsActivated) {
        [self highlightVowels];
    }
    
    if (self.highlightConsonantsActivated) {
        [self highlightConsonants];
    }
    
    if (self.highlightUserSelectionActivated) {
        [self highlightUserSelected];
    }
    [self highlightPunctuationWithColor:[UIColor redColor]];
    if (self.highlightAssistantTextActivated) {
        [self highlightAssistantTextWithColor:self.currentReadingPosition.highlightMovingTextColor];
    }
    
    if (self.currentReadingPosition.wordIndex >= self.wordsArray.count - 3) {
        [self stopTimer];
    }
    
    else {
        [self beginTimer];
        
    }
    //        NSLog(@"%d, %lu, %0.2f", self.wordIndex, (unsigned long)self.wordsArray.count, self.timeIntervalBetweenIndex);
    
    self.dot.alpha = 0.8;
    [UIView animateWithDuration:self.timeIntervalBetweenIndex delay:kZero options:UIViewKeyframeAnimationOptionRepeat animations:^{
        self.dot.alpha = kZero;
    } completion:nil];
    
    float index = self.currentReadingPosition.wordIndex;
    float wordArray = self.wordsArray.count;
    float textFieldContentOffsetY = index/wordArray * self.assistantTextView.contentSize.height;
    //    NSLog(@"%f", textFieldContentOffsetY);
    self.assistantTextView.contentOffset = CGPointMake(kZero, textFieldContentOffsetY);
    
    
    NSInteger range = [([self.assistantTextRangeIndexArray objectAtIndex:self.currentReadingPosition.wordIndex+3])integerValue];
    NSInteger length = [([self.assistantTextRangeLenghtArray objectAtIndex:self.currentReadingPosition.wordIndex+4])integerValue];
    
    NSLog(@"%d %d %d", range, length, self.currentReadingPosition.wordIndex);
    
}

- (void)beginTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:NO];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
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
    
    [UIView animateWithDuration:1.5 animations:^{
        self.speedPropertySelector.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 30);
        self.speedLabel.alpha = kZero;
    }];
    
    [self retractColorPalette];
    [self retractUserInputTextField];
    [self retractModifyFocusTextView];
    float index = self.currentReadingPosition.wordIndex;
    float wordArray = self.wordsArray.count;
    float textFieldContentOffsetY = index/wordArray * self.assistantTextView.contentSize.height;
    self.assistantTextView.contentOffset = CGPointMake(kZero, textFieldContentOffsetY);
    
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
        [UIView animateWithDuration:4.0f animations:^{
            self.breakPedal.alpha = kUINormaAlpha;
            self.breakPedal.layer.shadowOpacity = kZero;
            self.breakPedal.layer.shadowRadius = kZero;
        }];
        [UIView animateWithDuration:1.5 animations:^{
            self.pinView.layer.affineTransform = CGAffineTransformMakeRotation(self.timeIntervalBetweenIndex);
            self.breakPedal.alpha = 0.25;
            
        }];
        self.breakingBegan = NO;
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
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: self.assistantTextView.attributedText];
    for (NSInteger charIdx = 0; charIdx < self.focusText.text.length; charIdx++){
        unichar currentWord = [self.focusText.text characterAtIndex:charIdx];
        BOOL isWord = [characterSet characterIsMember:currentWord];
        if (isWord) {
            
            self.currentReadingPosition.assistantTextRangeIndex = [([self.assistantTextRangeIndexArray objectAtIndex:self.currentReadingPosition.wordIndex+3])integerValue];
            self.currentReadingPosition.assistantTextRangeLength = [([self.assistantTextRangeLenghtArray objectAtIndex:self.currentReadingPosition.wordIndex+4])integerValue];
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(self.currentReadingPosition.assistantTextRangeIndex, self.currentReadingPosition.assistantTextRangeLength+1)];
            //                        NSLog(@"%lu, %lu, %d, %@", range, length, isWord, self.focusText.text);
            [self.assistantTextView setAttributedText: attributedString];
        }
    }
}

#pragma mark Vowels

- (void)toggleVowelsSelected {
    [self retractModifyFocusTextView];
    self.highlightVowelsActivated = !self.highlightVowelsActivated;
    self.textColorBeingModified = Vowels;
    
    if (self.highlightVowelsActivated) {
        [self.toggleVowels addGestureRecognizer:self.openColorOptionsGesture];
        [UIView animateWithDuration:0.5 animations:^{
            self.toggleVowels.frame = CGRectMake(55, CGRectGetHeight(self.uiView.frame) - 140, kToggleButtonDimension, kToggleButtonDimension);
            self.toggleVowels.layer.shadowOpacity = 0.55f;
            self.toggleVowels.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.toggleVowels.backgroundColor = self.colorOne;
            self.toggleVowels.alpha = 1.0f;
        }];
    }
    if (!self.highlightVowelsActivated) {
        [self.toggleConsonates removeGestureRecognizer:self.openColorOptionsGesture];
        [self retractColorPalette];
        [UIView animateWithDuration:0.5 animations:^{
            self.toggleVowels.frame = CGRectMake(55, CGRectGetHeight(self.uiView.frame) - 138, kToggleButtonDimension, kToggleButtonDimension);
            self.toggleVowels.layer.shadowOpacity = 0.30f;
            self.toggleVowels.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.toggleVowels.backgroundColor = self.defaultButtonColor;
            self.toggleVowels.alpha = kHiddenControlRevealedAlhpa;
        }];
    }
    
}

- (void)highlightVowels {
    [self modifyTextWithString:kVowels color:self.currentReadingPosition.highlightVowelColor];
}

#pragma mark Consonants

- (void)toggleConsonantsSelected {
    [self retractModifyFocusTextView];
    self.highlightConsonantsActivated = !self.highlightConsonantsActivated;
    self.textColorBeingModified = Consonants;
    [self updatePaletteOrigin];
    if (self.highlightConsonantsActivated) {
        [self.toggleConsonates addGestureRecognizer:self.openColorOptionsGesture];
        [UIView animateWithDuration:0.5f animations:^{
            self.toggleConsonates.frame = CGRectMake(100, CGRectGetHeight(self.view.frame) - 95, kToggleButtonDimension, kToggleButtonDimension);
            self.toggleConsonates.layer.shadowOpacity = kUINormaAlpha;
            self.toggleConsonates.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.toggleConsonates.backgroundColor = self.currentReadingPosition.highlightConsonantColor;
            self.toggleConsonates.alpha = 1.0f;
        }];
    }
    if (!self.highlightConsonantsActivated) {
        [self.toggleConsonates removeGestureRecognizer:self.openColorOptionsGesture];
        [self retractColorPalette];
        [UIView animateWithDuration:0.5f animations:^{
            self.toggleConsonates.frame = CGRectMake(100, CGRectGetHeight(self.view.frame) - 93, kToggleButtonDimension, kToggleButtonDimension);
            self.toggleConsonates.layer.shadowOpacity = 0.30f;
            self.toggleConsonates.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.toggleConsonates.backgroundColor = self.defaultButtonColor;
            self.toggleConsonates.alpha = kUINormaAlpha;
        }];
    }
}

- (void)highlightConsonants {
    [self modifyTextWithString:kConsonants color:self.currentReadingPosition.highlightConsonantColor];
}

#pragma mark UserSelected

- (void)toggleUserSelected {
    [self retractModifyFocusTextView];
    self.highlightUserSelectionActivated = !self.highlightUserSelectionActivated;
    self.textColorBeingModified = UserSelection;
    [self updatePaletteOrigin];
    [self openUserInputTextField];
    
    if (self.highlightUserSelectionActivated) {
        [self.toggleUserSelections addGestureRecognizer:self.openColorOptionsGesture];
        [UIView animateWithDuration:0.5f animations:^{
            self.toggleUserSelections.frame = CGRectMake(35, CGRectGetHeight(self.view.frame) - 195, kToggleButtonDimension, kToggleButtonDimension);
            self.toggleUserSelections.layer.shadowOpacity = kUINormaAlpha;
            self.toggleUserSelections.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.toggleUserSelections.backgroundColor = self.currentReadingPosition.highlightUserSelectedTextColor;
            self.toggleUserSelections.alpha = 1.0f;
        }];
    }
    if (!self.highlightUserSelectionActivated) {
        [self.toggleUserSelections removeGestureRecognizer:self.openColorOptionsGesture];
        [self retractColorPalette];
        [self retractUserInputTextField];
        [UIView animateWithDuration:0.5f animations:^{
            self.toggleUserSelections.frame = CGRectMake(35, CGRectGetHeight(self.view.frame) - 193, kToggleButtonDimension, kToggleButtonDimension);
            self.toggleUserSelections.layer.shadowOpacity = 0.30f;
            self.toggleUserSelections.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
            self.toggleUserSelections.backgroundColor = self.defaultButtonColor;
            self.toggleUserSelections.alpha = kUINormaAlpha;
        }];
    }
}

- (void)highlightUserSelected {
    [self modifyTextWithString:self.userSelectedTextTextField.text color:self.currentReadingPosition.highlightUserSelectedTextColor];
    
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
    //    button.alpha = 1.0f;
    //    button.layer.affineTransform = CGAffineTransformScale(button.layer.affineTransform, 1/1.05f, 1/1.20f);
    //    button.layer.shadowOpacity = kShadowOpacity;
    //    button.layer.zPosition = 0.0f;
    switch (button.tag) {
        case 1:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorOne;
                    self.toggleConsonates.backgroundColor = self.colorOne;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorOne;
                    self.toggleVowels.backgroundColor = self.colorOne;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorOne;
                    self.toggleUserSelections.backgroundColor = self.colorOne;
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorTwo;
                    self.toggleConsonates.backgroundColor = self.colorTwo;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorTwo;
                    self.toggleVowels.backgroundColor = self.colorTwo;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorTwo;
                    self.toggleUserSelections.backgroundColor = self.colorTwo;
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorThree;
                    self.toggleConsonates.backgroundColor = self.colorThree;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorThree;
                    self.toggleVowels.backgroundColor = self.colorThree;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorThree;
                    self.toggleUserSelections.backgroundColor = self.colorThree;
                    break;
                default:
                    break;
            }
            break;
        case 4:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorFour;
                    self.toggleConsonates.backgroundColor = self.colorFour;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorFour;
                    self.toggleVowels.backgroundColor = self.colorFour;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorFour;
                    self.toggleUserSelections.backgroundColor = self.colorFour;
                    break;
                default:
                    break;
            }
            break;
        case 5:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.colorFive;
                    self.toggleConsonates.backgroundColor = self.colorFive;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.colorFive;
                    self.toggleVowels.backgroundColor = self.colorFive;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.colorFive;
                    self.toggleUserSelections.backgroundColor = self.colorFive;
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
    self.speedAdjusterSlider.alpha = kHiddenControlRevealedAlhpa;
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
            self.speedAdjusterSlider.maximumTrackTintColor = self.colorOne;
            self.selectedSpeedToAdjustIndicator = @"normal speed";
            break;
        case MaximumSpeed:
            self.speedShown = self.maxSpeed;
            self.maxSpeed = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 0.75f;
            self.speedAdjusterSlider.minimumValue = 0.01f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.currentReadingPosition.highlightUserSelectedTextColor;
            self.selectedSpeedToAdjustIndicator = @"max speed";
            break;
        case MinimumSpeed:
            self.speedShown = self.minSpeed;
            self.minSpeed = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 1.0f;
            self.speedAdjusterSlider.minimumValue = 0.01f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.colorTwo;
            self.selectedSpeedToAdjustIndicator = @"min speed";
            break;
        case AccelerationSpeed:
            self.speedShown = self.acceleration;
            self.acceleration = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 0.1f;
            self.speedAdjusterSlider.minimumValue = 0.001f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.colorThree;
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
            self.maxSpeed = self.speedAdjusterSlider.value;
            self.speedAdjusterSlider.maximumValue = 0.75f;
            self.speedAdjusterSlider.minimumValue = 0.01f;
            self.speedAdjusterSlider.maximumTrackTintColor = self.colorFive;
            self.selectedSpeedToAdjustIndicator = @"normal speed";
            break;
    }
    [self.uiView addSubview:self.speedLabel];
    [self.uiView addSubview:self.speedPropertySelector];
    self.speedShown = self.speedAdjusterSlider.value;
    float wordsPerMinute = 1/self.speedShown * 60;
    if (segmentSelected == Default) {
        self.speedLabel.text = @"Default\nrestored";
    } else {
        self.speedLabel.text = [NSString stringWithFormat:@"%@\n%0.1f\nwords/min",self.selectedSpeedToAdjustIndicator, wordsPerMinute];
        [UIView animateWithDuration:1.0 animations:^{
            self.speedLabel.alpha = kUINormaAlpha;
            self.speedPropertySelector.frame = CGRectMake(0, CGRectGetHeight(self.uiView.frame) - 30, CGRectGetWidth(self.uiView.frame), 30);
            self.speedPropertySelector.alpha = kHiddenControlRevealedAlhpa;
            
        }];
    }
}

#pragma mark Modify UITransition Methods

- (void)toggleHideControls: (UIButton *)sender {
    self.hideControlsActivated = !self.hideControlsActivated;
    [self hideControls];
}

- (void)hideControls {
    if (!self.hideControlsActivated) {
        [UIView animateWithDuration:1.0f animations:^{
            self.chapterLabel.alpha = kHiddenControlRevealedAlhpa;
            [self.hideControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.hideControlButton setTitle:@"hide" forState:UIControlStateNormal];
            self.hideControlButton.backgroundColor = [UIColor blackColor];
            self.hideControlButton.alpha = 0.25f;
            self.toggleVowels.alpha = kHiddenControlRevealedAlhpa + 0.1f;
            self.toggleConsonates.alpha = kHiddenControlRevealedAlhpa;
            self.toggleUserSelections.alpha = kHiddenControlRevealedAlhpa + 0.2f;
            self.speedAdjusterSlider.alpha = kUINormaAlpha;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:5.0f animations:^{
                self.chapterLabel.alpha = 0.25;
                self.chapterLabel.layer.shadowOpacity = kZero;
            }];
        }];
    }
    if (self.hideControlsActivated) {
        [UIView animateWithDuration:1.0 animations:^{
            [self.hideControlButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.hideControlButton setTitle:@"show" forState:UIControlStateNormal];
            self.hideControlButton.backgroundColor = [UIColor colorWithWhite:1.0f alpha:kZero];
            self.hideControlButton.alpha = kUINormaAlpha;
            self.toggleVowels.alpha = kZero;
            self.toggleConsonates.alpha = kZero;
            self.toggleUserSelections.alpha = kZero;
            self.speedAdjusterSlider.alpha = kZero;
            self.chapterLabel.alpha = kZero;
            
        }];
    }
}

- (void)revealHiddenUI {
    
    [UIView animateWithDuration:1.0f animations:^{
        self.hideControlButton.alpha = kUINormaAlpha;
        self.toggleFocusTextModification.alpha = kUINormaAlpha;
        self.labelView.alpha = 1.0f;
        self.hideControlButton.alpha = 0.25f;
        self.breakPedal.alpha = kUINormaAlpha;
        self.expandTextViewButton.alpha = 1.0f;
        self.fullScreenTextViewButton.alpha = 1.0f;
        self.flipXAxisButton.alpha = kUINormaAlpha;
        self.retractTextViewButton.alpha = 1.0f;
    }];
    
}

- (void)hideUI {
    self.dividerLabel.alpha = kZero;
    self.labelView.alpha = kZero;
    self.toggleFocusTextModification.alpha = kZero;
    self.hideControlButton.alpha = kZero;
    self.toggleVowels.alpha = kZero;
    self.toggleConsonates.alpha = kZero;
    self.toggleUserSelections.alpha = kZero;
    self.speedAdjusterSlider.alpha = kZero;
    self.chapterLabel.alpha = kZero;
    self.breakPedal.alpha = kZero;
    self.expandTextViewButton.alpha = kZero;
    self.fullScreenTextViewButton.alpha = kZero;
    self.flipXAxisButton.alpha = kZero;
    self.retractTextViewButton.alpha = kZero;
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
    [self.uiView addSubview:self.userSelectedTextTextField];
    [UIView animateWithDuration:1.20f animations:^{
        self.userSelectedTextTextField.frame = CGRectMake(kZero-1.0f, self.toggleUserSelections.frame.origin.y-155.0f, 90.0f, 30.0f);
    }];
}

- (void)retractUserInputTextField {
    [UIView animateWithDuration:1.0 animations:^{
        self.userSelectedTextTextField.frame = CGRectMake(-145.0f, self.toggleUserSelections.frame.origin.y-155.0f, 145.0f, 30.0f);
    }];
    
}

- (void)revealAssistantText: (UIButton *)sender {
    [self revealHiddenUI];
    self.highlightAssistantTextActivated = YES;
    self.textFieldRevealed = YES;
    [self.uiView addSubview:self.assistantTextView];
    [self.uiView addSubview:self.expandTextViewButton];
    [self.uiView addSubview:self.retractTextViewButton];
    [self.uiView addSubview:self.fullScreenTextViewButton];
    self.assistantTextView.text = self.bookTextRawString;
    self.fullScreenTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, self.assistantTextView.frame.origin.y-kControlButtonYOffset, kAccessButtonHeight, kAccessButtonHeight);
    self.fullScreenTextViewButton.alpha = kZero;
    self.lightsOffButton.alpha = kZero;
    
    [UIView animateWithDuration:1.0f animations:^{
        self.flipXAxisButton.alpha = kUINormaAlpha;
        [self rotationTransformation:self.expandTextViewButton.layer degrees:k180Rotation];
        [self rotationTransformation:self.accessTextViewButton.layer degrees:k180Rotation];
        self.accessTextViewButton.alpha = kZero;
        self.assistantTextView.frame = CGRectMake(kZero, CGRectGetMidY(self.uiView.frame)-kControlButtonMidYOffset, CGRectGetWidth(self.uiView.frame)/2, kAssistantTextViewWidth);
        self.expandTextViewButton.alpha = 1.0f;
        self.retractTextViewButton.alpha = 1.0f;
        self.fullScreenTextViewButton.alpha =1.0f;
        self.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.retractTextViewButton.frame = CGRectMake(kControlButtonXOrigin, self.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.fullScreenTextViewButton.frame = CGRectMake(kControlButtonXOrigin+2*kControlButtonXOffset, self.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        
    }completion:^(BOOL finished) {
        self.accessTextViewButton.backgroundColor = [UIColor colorWithWhite:kZero alpha:kZero];
        self.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.accessTextViewButton.layer.borderWidth = kBoarderWidth;
        self.accessTextViewButton.layer.borderColor = self.defaultButtonColor.CGColor;
        [self.accessTextViewButton setTitle:@"+" forState:UIControlStateNormal];
        [self.accessTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
        self.accessTextViewButton.layer.cornerRadius = kAccessButtonHeight/2;
        self.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight);
        
    }];
}

- (void)retractAssistantText: (UIButton *)sender {
    self.highlightAssistantTextActivated = NO;
    self.textFieldRevealed = NO;
    [self.accessTextViewButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:kZero] forState:UIControlStateNormal];
    self.assistantTextView.frame = CGRectMake(-kAssistantTextViewWidth, CGRectGetMidY(self.uiView.frame)-kControlButtonMidYOffset, kAssistantTextViewWidth, kAssistantTextViewWidth);
    self.accessTextViewButton.backgroundColor = self.colorThree;
    self.accessTextViewButton.frame = CGRectMake(-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame), kAccessButtonWidth, kAccessButtonHeight);
    self.accessTextViewButton.layer.borderWidth = kZero;
    self.accessTextViewButton.layer.cornerRadius = kAccessButtonHeight;
    [UIView animateWithDuration:1.0f animations:^{
        self.expandTextViewButton.alpha = kZero;
        self.expandTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.expandTextViewButton.layer.affineTransform, M_PI/180.0 * 180);
        self.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.uiView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.accessTextViewButton.alpha = 1.0f;
        self.retractTextViewButton.alpha = kZero;
        self.fullScreenTextViewButton.alpha= kZero;
        
    } completion:^(BOOL finished) {
        [self.retractTextViewButton removeFromSuperview];
        [self.expandTextViewButton removeFromSuperview];
        [self.dividerLabel removeFromSuperview];
        [self.fullScreenTextViewButton removeFromSuperview];
        [self revealSpeedometer];
    }];
}

- (void)expandAssistantText: (UIButton *)sender {
    self.textFieldRevealed = NO;
    self.hideControlsActivated = YES;
    [self hideControlButton];
    [self hideSpeedometer];
    [self.uiView addSubview:self.dividerLabel];
    [self.accessTextViewButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.65f] forState:UIControlStateNormal];
    [self.accessTextViewButton setTitle:@"-" forState:UIControlStateNormal];
    [self.accessTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    self.dividerLabel.frame = CGRectMake(CGRectGetMidX(self.uiView.frame), CGRectGetMidY(self.uiView.frame)+90.0f, 1.0f, 1.0f);
    self.fullScreenTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+140.0f, kAccessButtonHeight, kAccessButtonHeight);
    self.fullScreenTextViewButton.alpha = kZero;
    
    [UIView animateWithDuration:1.0f animations:^{
        self.dividerLabel.frame = CGRectMake(CGRectGetMidX(self.uiView.frame), kZero, 1.0f, CGRectGetHeight(self.uiView.frame));
        self.flipXAxisButton.alpha = kZero;
        self.expandTextViewButton.alpha = kZero;
        self.retractTextViewButton.alpha = kZero;
        self.expandTextViewButton.frame = CGRectMake(87.5f, self.uiView.frame.origin.y-65, 45, 45);
        self.retractTextViewButton.frame = CGRectMake(37.5f, self.uiView.frame.origin.y-65, 45, 45);
        self.assistantTextView.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, CGRectGetMidX(self.uiView.frame)-4.0f, CGRectGetHeight(self.uiView.frame)-70.0f);
        self.accessTextViewButton.alpha = 1.0f;
        self.fullScreenTextViewButton.alpha = 1.0f;
        self.dividerLabel.alpha = 0.2f;
        self.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+90.0f, kAccessButtonHeight, kAccessButtonHeight);
        self.expandTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.expandTextViewButton.layer.affineTransform, M_PI/180.0 * 180);
        self.accessTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.expandTextViewButton.layer.affineTransform, M_PI/180.0 * 180);
        
    }];
}

- (void)fullScreenTextView: (UIButton *)sender {
    [self hideSpeedometer];
    self.lightsOffButton = [[UIButton alloc]initWithFrame: CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2 + kAccessButtonHeight +5, CGRectGetMaxY(self.uiView.frame)-kControlButtonDimension, kAccessButtonHeight, kAccessButtonHeight)];
    [self configureRoundButton:self.lightsOffButton dimension:kAccessButtonHeight];
    self.lightsOffButton.alpha = kZero;
    [self.uiView addSubview:self.lightsOffButton];
    [self.lightsOffButton addTarget:self action:@selector(lightsOff:) forControlEvents:UIControlEventTouchUpInside];
    self.accessTextViewButton.alpha = 1.0f;
    
    [UIView animateWithDuration:0.75f animations:^{
        [self hideUI];
        self.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+90.0f, kAccessButtonHeight, kAccessButtonHeight);
        self.assistantTextView.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, CGRectGetMidX(self.uiView.frame)-4.0f, CGRectGetHeight(self.uiView.frame)-70.0f);
        self.accessTextViewButton.alpha = kZero;
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.75f animations:^{
            self.accessTextViewButton.titleLabel.text = @"-";
            self.assistantTextView.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, CGRectGetMaxX(self.uiView.frame), CGRectGetHeight(self.uiView.frame)-70.0f);
            self.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMaxY(self.uiView.frame)-kControlButtonDimension, kAccessButtonHeight, kAccessButtonHeight);
            self.accessTextViewButton.alpha = 1.0f;
            self.lightsOffButton.alpha = 1.0f;
            
        }];
    }
     ];
}

- (void)turnOnLight {
    [UIView animateWithDuration:0.5f animations:^{
        UIImage *paper = [UIImage imageNamed:@"ivoryPaper.png"];
        self.uiView.layer.contents = (__bridge id)paper.CGImage;
        self.uiView.backgroundColor = [UIColor colorWithRed:45.0f/255.0f green:55.0f/255.0f blue:64.0f/255.0f alpha:kZero];
        self.lightsOffButton.layer.borderColor = [UIColor blackColor].CGColor;
        self.currentReadingPosition.highlightMovingTextColor = [UIColor blackColor];
        self.assistantTextView.textColor = self.defaultButtonColor;
        self.accessTextViewButton.layer.borderColor = [UIColor blackColor].CGColor;
        self.lightsOffButton.layer.borderColor = [UIColor blackColor].CGColor;
        [self.accessTextViewButton setTitleColor:self.defaultButtonColor forState:UIControlStateNormal];
    }];
}

- (void)turnOffLight {
    self.currentReadingPosition.highlightMovingTextColor = [UIColor colorWithRed:242.0f/255.0f green:203.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
    self.assistantTextView.textColor = [UIColor colorWithRed:242.0f/255.0f green:203.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
    self.accessTextViewButton.layer.borderColor = [UIColor colorWithRed:94.0f/255.0f green:85.0f/255.0f blue:82.0f/255.0f alpha:1.0f].CGColor;
    self.lightsOffButton.layer.borderColor = [UIColor colorWithRed:142.0f/255.0f green:168.0f/255.0f blue:178.0f/255.0f alpha:1.0f].CGColor;
    [self.accessTextViewButton setTitleColor:[UIColor colorWithRed:142.0f/255.0f green:168.0f/255.0f blue:178.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
}

- (void)lightsOff: (UIButton *)sender {
    self.lightsOffActivated = !self.lightsOffActivated;
    NSLog(@"pressed, %d", self.lightsOffActivated);
}

- (void)expandModifyFocusTextView: (UIButton *)sender {
    [self.uiView addSubview:self.modifyFocusTextFontSizeSlider];
    [self.uiView addSubview:self.focusFontSizeLabel];
    
    [UIView animateWithDuration:1.50f animations:^{
        self.focusFontSizeLabel.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)-145.0f, CGRectGetMidY(self.uiView.frame)-kToggleButtonOffsetX + 30.0f, 30.0f, 30.0f);
        self.modifyFocusTextFontSizeSlider.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)-120.0f, CGRectGetMidY(self.uiView.frame)/5, 120.0f, 30.0f);
        self.toggleFocusTextModification.alpha = kZero;
    }];
}

- (void)retractModifyFocusTextView {
    static const float kEdgeOffset = 5.0f;
    static const float kHeightOffset = -14.0f;
    [UIView animateWithDuration:0.75f animations:^{
        self.focusFontSizeLabel.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, CGRectGetMidY(self.uiView.frame)-kToggleButtonOffsetX + 30.0f, 30.0f, 30.0f);
        self.modifyFocusTextFontSizeSlider.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, CGRectGetMidY(self.uiView.frame)/5, 120.0f, 30.0f);
        self.toggleFocusTextModification.alpha = 1.0f;
        self.color1.frame = CGRectMake(self.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
        self.color2.frame = CGRectMake(self.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
        self.color3.frame = CGRectMake(self.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
        self.color4.frame = CGRectMake(self.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
        self.color5.frame = CGRectMake(self.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
    }completion:^(BOOL finished) {
        [self.focusFontSizeLabel removeFromSuperview];
        [self.modifyFocusTextFontSizeSlider removeFromSuperview];
    }];
    
}

- (void)adjustFontSize: (UISlider *)sender {
    self.currentReadingPosition.mainFontSize = self.modifyFocusTextFontSizeSlider.value;
    self.focusFontSizeLabel.text = [NSString stringWithFormat:@"%0.1f",self.currentReadingPosition.mainFontSize];
    self.focusFontSizeLabel.font = [UIFont fontWithName:(@"AmericanTypewriter") size:12.0f];
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
        self.assistantTextView.layer.transform = CATransform3DRotate(self.assistantTextView.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.speedLabel.layer.transform = CATransform3DRotate(self.speedLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.speedometerReadLabel.layer.transform = CATransform3DRotate(self.speedometerReadLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.focusFontSizeLabel.layer.transform = CATransform3DRotate(self.focusFontSizeLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.hideControlButton.layer.transform = CATransform3DRotate(self.hideControlButton.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.toggleConsonates.layer.transform = CATransform3DRotate(self.toggleConsonates.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.toggleUserSelections.layer.transform = CATransform3DRotate(self.toggleUserSelections.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.speedPropertySelector.layer.transform = CATransform3DRotate(self.speedPropertySelector.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userSelectedTextTextField.layer.transform = CATransform3DRotate(self.userSelectedTextTextField.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
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
    self.hideControlsActivated = YES;
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
    
    self.retractDictionaryButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)/2-kAccessButtonHeight/2, CGRectGetHeight(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight)];
    [self.retractDictionaryButton setTitle:@"<" forState:UIControlStateNormal];
    [self rotationTransformation:self.retractDictionaryButton.layer degrees:-k180Rotation/2];
    self.retractDictionaryButton.layer.zPosition = 1.50f;
    [self.retractDictionaryButton addTarget:self action:@selector(retractDictionary:) forControlEvents:UIControlEventTouchUpInside];
    [self configureRoundButton:self.retractDictionaryButton dimension:kAccessButtonHeight];
    [UIView animateWithDuration:0.5f animations:^{
        self.retractDictionaryButton.frame = CGRectMake(CGRectGetWidth(self.uiView.frame)/2-kAccessButtonHeight/2, CGRectGetHeight(self.uiView.frame)/2-kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight);
        self.dictionaryViewController.view.frame = CGRectMake(kZero, CGRectGetHeight(self.uiView.frame)/2, CGRectGetWidth(self.uiView.frame), CGRectGetHeight(self.uiView.frame)/2);
        [self rotationTransformation:self.presentDictionaryButton.layer degrees:k180Rotation];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            self.presentDictionaryButton.alpha = kZero;
        }];
    }];
}

- (void)retractDictionary: (UIButton *)sender {
    [self beginTimer];
    [UIView animateWithDuration:0.5f animations:^{
        self.presentDictionaryButton.alpha = 1.0f;
        self.retractDictionaryButton.frame = CGRectMake(CGRectGetWidth(self.uiView.frame)/2-kAccessButtonHeight/2, CGRectGetHeight(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight);
        self.dictionaryViewController.view.frame = CGRectMake(kZero, CGRectGetHeight(self.uiView.frame), CGRectGetWidth(self.uiView.frame), CGRectGetHeight(self.uiView.frame)/2);
        [self rotationTransformation:self.presentDictionaryButton.layer degrees:k180Rotation];
    }completion:^(BOOL finished) {
        [self.retractDictionaryButton removeFromSuperview];
        [self.dictionaryViewController.view removeFromSuperview];
    }];
}

- (void)toggleSpeedometerDetails: (UIButton *)sender {
    
}

#pragma TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.userSelectedTextTextField resignFirstResponder];
    return YES;
}


@end
