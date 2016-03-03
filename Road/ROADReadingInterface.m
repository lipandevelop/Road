//
//  ViewController.m
//  Road
//
//  Created by Li Pan on 2016-02-19.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "ROADConstants.h"
#import "ROADReadingInterface.h"
#import "KFEpubController.h"
#import "KFEpubContentModel.h"
#import "ROADCurrentReadingPosition.h"
#import "Utilities.h"
#import "ConfigureView.h"
#import "ROADUIUserInteractionTools.h"

#import "ROADReadInterfaceBOOLs.h"
#import "ROADDisplayReadingTextLabel.h"
#import "ROADNoneInteractiveViews.h"
#import "ROADColors.h"
#import "ROADPalette.h"
#import "ROADPaletteButton.h"
#import "ROADNoteBookView.h"

#pragma mark Properties

@interface ROADReadingInterface () <KFEpubControllerDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) KFEpubController *epubController;
@property (nonatomic, strong) KFEpubContentModel *contentModel;
@property (nonatomic, strong) UIReferenceLibraryViewController *dictionaryViewController;
@property (nonatomic, strong) UIWebView *bookContentView;
@property (nonatomic, assign) NSUInteger spineIndex;
@property (nonatomic, strong) NSScanner *assistantTextRangeScanner;
@property (nonatomic, strong) ROADCurrentReadingPosition *currentReadingPosition;
@property (nonatomic, strong) ROADNoteBookView *noteBook;

@property (nonatomic, strong) ROADUIUserInteractionTools *userInteractionTools;
@property (nonatomic, strong) ROADNoneInteractiveViews *nonInteractiveViews;
@property (nonatomic, strong) ROADReadInterfaceBOOLs *readingInterfaceBOOLs;
@property (nonatomic, strong) ROADDisplayReadingTextLabel *displayReadingTextLabe;
@property (nonatomic, strong) ROADColors *userColor;
@property (nonatomic, strong) ROADPalette *toggleFocusTextHighlightPaletteButton;

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
@property (nonatomic, assign) float assistantTextContentOffset;

@property (nonatomic, strong) NSString *userInputForHighlightedTextString;
@property (nonatomic, strong) NSString *selectedSpeedToAdjustIndicator;
@property (nonatomic, strong) NSString *userNotesString;
@property (nonatomic, strong) NSArray *speedArray;

#pragma mark UI Display Properties

@property (nonatomic, strong) UIView *labelView;
@property (nonatomic, strong) UIView *uiView;
@property (nonatomic, strong) UILabel *chapterLabel;

#pragma mark Runtime Properties
@property (nonatomic, strong) CADisplayLink *displaylink;
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval timeIntervalBetweenIndex;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *accelerationtimer;
@property (nonatomic, strong) NSTimer *deccelerationtimer;
@property (nonatomic, strong) NSTimer *breaktimer;

@property (nonatomic, assign) float speedShown;
@property (nonatomic, assign) float deceleration;
@property (nonatomic, assign) float timeElapsed;
@property (nonatomic, assign) float timeCount;
@property (nonatomic, assign) float currentTime;
@property (nonatomic, assign) CGRect highlightButtonLocationFrames;

#pragma Mark Palette Properties
@property (nonatomic, assign) float colorPaletteXOrigin;
@property (nonatomic, assign) float colorPaletteYOrigin;
@property (nonatomic, assign) ModifyColorForTextActivated textColorBeingModified;

#pragma mark Images
@property (nonatomic, strong) UIImage *bulbLight;
@property (nonatomic, strong) UIImage *bulbDark;
@property (nonatomic, strong) UIView *connector;
@property (nonatomic, strong) UIView *connector2;

@property (nonatomic, assign) int swipeUpIndex;
@property (nonatomic, assign) int swipeDownIndex;


@end

@implementation ROADReadingInterface

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidAppear:(BOOL)animated {
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeIntervalBetweenIndex target:self selector:@selector(update) userInfo:nil repeats:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userColor = [[ROADColors alloc]init];
    [self loadData];
    [self loadValues];
    [self loadBook];
    [self loadUIContents];
    [self loadText];
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
    self.currentReadingPosition.highlightVowelColor = self.userColor.colorOne;
    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorTwo;
    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorThree;
    self.currentReadingPosition.dotColor = self.userColor.colorZero;
    self.currentReadingPosition.dotColor = self.userColor.colorSix;
    self.currentReadingPosition.highlightMovingTextColor = [UIColor blackColor];
    self.currentReadingPosition.mainFontSize = kDefaultMainFontSize;
    self.currentReadingPosition.normalSpeed = kDefaultNormalSpeed;
    self.currentReadingPosition.minSpeed = kDefaultMaxSpeed;
    self.currentReadingPosition.maxSpeed = kDefaultMinSpeed;
    self.currentReadingPosition.acceleration = kDefaultAcceleration;
    self.currentReadingPosition.averageReadingSpeed = kDefaultNormalSpeed*60;
    self.currentReadingPosition.userNotesArray = [NSMutableArray array];
}

#pragma mark Loading Values

- (void)loadValues {
    [self updateFontSize];
    self.readingInterfaceBOOLs  = [[ROADReadInterfaceBOOLs alloc]init];
    self.readingInterfaceBOOLs.accelerationBegan = NO;
    self.readingInterfaceBOOLs.highlightVowelsActivated = NO;
    self.readingInterfaceBOOLs.highlightConsonantsActivated = NO;
    self.readingInterfaceBOOLs.hideControlsActivated = YES;
    self.readingInterfaceBOOLs.speedometerDetailOpened = NO;
    self.readingInterfaceBOOLs.punctuationActivated = NO;
    self.toggleFocusTextHighlightPaletteButton = [[ROADPalette alloc]init];
    self.fontType = @"AmericanTypewriter";
    self.deceleration = 0.0007;
    self.timeIntervalBetweenIndex = self.currentReadingPosition.normalSpeed;
    self.speedArray = [NSArray arrayWithObjects: @"norm speed", @"max speed", @"min speed", @"accel", @"default", nil];
    self.startTime = self.startTime = CACurrentMediaTime();
    
    self.displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkLoop)];
    [self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.bulbLight = [UIImage imageNamed:@"bulbLight.png"];
    self.bulbDark = [UIImage imageNamed:@"bulbDark.png"];
}

#pragma mark Load UIContents
- (void)loadUIContents {
    //        self.exitReadView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    //        self.exitReadView.backgroundColor = [UIColor redColor];
    //        [self.exitReadView addTarget:self action:@selector(saveData) forControlEvents:UIControlEventTouchUpInside];
    
    self.startTime = CACurrentMediaTime();
    
    self.uiView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.uiView];
    //    [self.uiView addSubview:self.exitReadView];
    
    self.labelView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*kGoldenRatioMinusOne-kLabelViewWidth/2, CGRectGetMaxY(self.view.frame)*kOneMinusGoldenRatioMinusOne-kLabelViewHeight/2, kLabelViewWidth, kLabelViewHeight)];
    self.labelView.userInteractionEnabled = NO;
    [self.view addSubview:self.labelView];
    
    self.userInteractionTools = [[ROADUIUserInteractionTools alloc]init];
    self.nonInteractiveViews = [[ROADNoneInteractiveViews alloc]init];
    
    UIImage *paper = [UIImage imageNamed:@"ivoryPaper.png"];
    UIImage *breakPedal = [UIImage imageNamed:@"finger_clean.png"];
    UIImage *speedometerImage = [UIImage imageNamed:@"Speedometer.png"];
    UIImage *pinImage= [UIImage imageNamed:@"Pin.png"];
    UIImage *leftHandImage = [UIImage imageNamed:@"leftHand"];
    UIImage *penImage = [UIImage imageNamed:@"pen.png"];
    UIImage *notebookImage = [UIImage imageNamed:@"noteBook.png"];
    
    
#pragma Speedometer Set
    
    //SpeedometerView
    self.uiView.layer.contents = (__bridge id)paper.CGImage;
    self.nonInteractiveViews.speedometerView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.uiView.frame)-kSpeedometerDimension, 35.0f, kSpeedometerDimension, kSpeedometerDimension)];
    self.nonInteractiveViews.speedometerView.layer.contents = (__bridge id)speedometerImage.CGImage;
    self.nonInteractiveViews.speedometerView.layer.contentsGravity = kCAGravityResizeAspect;
    self.nonInteractiveViews.speedometerView.alpha = 0.20f;
    self.nonInteractiveViews.speedometerView.userInteractionEnabled = NO;
    
    //Progress View
    self.nonInteractiveViews.progress = [[UIView alloc]initWithFrame:CGRectMake(2.0f, 1.50f, kZero, kProgressBarHeight/2 + 0.5)];
    self.nonInteractiveViews.progress.layer.borderWidth = kBoarderWidth/2;
    self.nonInteractiveViews.progress.layer.cornerRadius = 3.0f;
    self.nonInteractiveViews.progress.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.nonInteractiveViews.progress.layer.shadowOpacity = kShadowOpacity;
    self.nonInteractiveViews.progress.alpha = 1.0f;
    self.nonInteractiveViews.progress.backgroundColor = self.userColor.colorFour;
    
    //AverageSpeed Label
    self.nonInteractiveViews.averageSpeedLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame)+20.0f, kZero, kProgressBarHeight*1.5)];
    self.nonInteractiveViews.averageSpeedLabel.layer.borderWidth = kBoarderWidth;
    self.nonInteractiveViews.averageSpeedLabel.layer.borderWidth = kBoarderWidth/2;
    self.nonInteractiveViews.averageSpeedLabel.layer.cornerRadius = kProgressBarHeight/1.50f;
    self.nonInteractiveViews.averageSpeedLabel.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.nonInteractiveViews.averageSpeedLabel.layer.shadowOpacity = kShadowOpacity;
    self.nonInteractiveViews.averageSpeedLabel.alpha = 1.0f;
    self.nonInteractiveViews.averageSpeedLabel.font = [UIFont fontWithName:(self.fontType) size:8.0f];
    self.nonInteractiveViews.averageSpeedLabel.textAlignment = NSTextAlignmentLeft;
    
    //TimeElapsed Label
    self.nonInteractiveViews.timerLabel = [[UIButton alloc]initWithFrame:CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2 + 65.0f, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame)+20.0f, kZero, kProgressBarHeight*1.5)];
    self.nonInteractiveViews.timerLabel.layer.cornerRadius = kProgressBarHeight/1.80f;
    self.nonInteractiveViews.timerLabel.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.nonInteractiveViews.timerLabel.layer.shadowOpacity = kShadowOpacity+0.20f;
    self.nonInteractiveViews.timerLabel.alpha = kHiddenControlRevealedAlhpa;
    self.nonInteractiveViews.timerLabel.titleLabel.font = [UIFont fontWithName:(self.fontType) size:8.0f];
    self.nonInteractiveViews.timerLabel.backgroundColor = self.userColor.colorTwo;
    self.nonInteractiveViews.timerLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.nonInteractiveViews.timerLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nonInteractiveViews.timerLabel.alpha = 0.65f;
    self.nonInteractiveViews.timerLabel.layer.borderWidth = kBoarderWidth;
    self.nonInteractiveViews.timerLabel.layer.borderWidth = kBoarderWidth*1.7f;
    self.nonInteractiveViews.timerLabel.layer.borderColor = [UIColor colorWithWhite:1.0f alpha:0.40f].CGColor;
    
    //Progress Bar
    self.nonInteractiveViews.progressBar = [[UIView alloc]initWithFrame:CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame), kZero, kProgressBarHeight - kProgressOffSetFromProgressBar)];
    self.nonInteractiveViews.progressBar.layer.borderWidth = 0.75f;
    self.nonInteractiveViews.progressBar.layer.cornerRadius = 5.0f;
    self.nonInteractiveViews.progressBar.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.nonInteractiveViews.progressBar.layer.shadowOpacity = kShadowOpacity;
    self.nonInteractiveViews.progressBar.alpha = kUINormaAlpha;
    
    //Progress Label
    self.nonInteractiveViews.progressLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/1.25, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame), kAccessButtonWidth, kProgressBarHeight - kProgressOffSetFromProgressBar)];
    self.nonInteractiveViews.progressLabel.textColor = self.currentReadingPosition.defaultButtonColor;
    self.nonInteractiveViews.progressLabel.font = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    [self.uiView addSubview:self.nonInteractiveViews.progressLabel];
    self.nonInteractiveViews.progressLabel.alpha = kZero;
    
    //Pin Image View
    UIImageView *pinImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15.0f, 70.0f)];
    pinImageView.image = [UIImage imageNamed:@"Pin.png"];
    self.nonInteractiveViews.pinView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.view.frame)-75.1f, 65.0f, 15.0f, 70.0f)];
    self.nonInteractiveViews.pinView.layer.contents = (__bridge id)pinImage.CGImage;
    self.nonInteractiveViews.pinView.layer.contentsGravity = kCAGravityResizeAspect;
    self.nonInteractiveViews.pinView.layer.shadowOffset = CGSizeMake(-1.0, 4.0);
    self.nonInteractiveViews.pinView.layer.shadowOpacity = kShadowOpacity;
    
    //Current Speed Label
    self.nonInteractiveViews.speedometerReadLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.uiView.frame)-97.0f, 114.0f, 60.0f, 15.0f)];
    self.nonInteractiveViews.speedometerReadLabel.font = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    self.nonInteractiveViews.speedometerReadLabel.alpha = kUINormaAlpha;
    self.nonInteractiveViews.speedometerReadLabel.textAlignment = NSTextAlignmentCenter;
    
    //Speedometer Details
    self.userInteractionTools.openSpeedometerDetailButton = [[UIButton alloc]initWithFrame:CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame), kToggleButtonDimension, kToggleButtonDimension)];
    [self.userInteractionTools.openSpeedometerDetailButton addTarget:self action:@selector(toggleSpeedometerDetails:) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.userInteractionTools.openSpeedometerDetailButton buttonLayer:self.userInteractionTools.openSpeedometerDetailButton.layer color: self.currentReadingPosition.defaultButtonColor string:@"s"];
    self.userInteractionTools.openSpeedometerDetailButton.backgroundColor = [UIColor colorWithRed:138.0f/255.0f green:131.0f/255.0f blue:117.0f/255.0f alpha:0.7f];
    self.userInteractionTools.openSpeedometerDetailButton.alpha = 1.0f;
    
#pragma mark RightSide Controls
    
    //+A
    self.userInteractionTools.toggleFocusTextModification = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)-kAccessButtonHeight, CGRectGetMidY(self.uiView.frame)-kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight)];
    [self.userInteractionTools.toggleFocusTextModification addTarget:self action:@selector(revealModifyFocusTextView:) forControlEvents:UIControlEventTouchUpInside];
    
    //+A Label
    self.nonInteractiveViews.focusFontSizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, 60.0f, 30.0f, 30.0f)];
    self.nonInteractiveViews.focusFontSizeLabel.text = @"+A";
    self.nonInteractiveViews.focusFontSizeLabel.textColor = self.currentReadingPosition.defaultButtonColor;
    
    //+A Slider
    self.userInteractionTools.modifyFocusTextFontSizeSlider = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, 60.0f + 30.0f, 120.0f, 30.0f)];
    self.userInteractionTools.modifyFocusTextFontSizeSlider.tintColor = self.userColor.colorFive;
    self.userInteractionTools.modifyFocusTextFontSizeSlider.layer.shadowOffset = CGSizeMake(-1.0f, 6.0);
    self.userInteractionTools.modifyFocusTextFontSizeSlider.layer.shadowOpacity = 0.10f;
    self.userInteractionTools.modifyFocusTextFontSizeSlider.value = self.currentReadingPosition.mainFontSize;
    self.userInteractionTools.modifyFocusTextFontSizeSlider.maximumValue = 32.0f;
    self.userInteractionTools.modifyFocusTextFontSizeSlider.minimumValue = 22.0f;
    [self.userInteractionTools.modifyFocusTextFontSizeSlider addTarget:self action:@selector(adjustFontSize:) forControlEvents:UIControlEventValueChanged];
    
    //Punctuation
    self.userInteractionTools.togglePunctuationButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.uiView.frame)-kAccessButtonHeight, CGRectGetMidY(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight)];
    [self.userInteractionTools.togglePunctuationButton addTarget:self action:@selector(togglePunctuation:) forControlEvents:UIControlEventTouchUpInside];
    
    [self refreshLightsoffUI];
    
#pragma Bottom Right Controls
    
    //Show/Hide Highlight Focus Text Controls
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
    
    //Break Gesture
    self.userInteractionTools.breakPedalGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(breaking)];
    self.userInteractionTools.breakPedalGesture.minimumPressDuration = 0.01;
    self.breakPedalFrame = CGRectMake(CGRectGetWidth(self.uiView.frame)*0.38196601125, CGRectGetMaxY(self.uiView.frame)/kGoldenRatio, 220.0f, 220.0f);
    CGAffineTransform pedalPosition = CGAffineTransformIdentity;
    pedalPosition = CGAffineTransformScale(pedalPosition, 0.50f, 0.50f);
    pedalPosition = CGAffineTransformRotate(pedalPosition, M_PI/k180Rotation * -37);
    pedalPosition = CGAffineTransformTranslate(pedalPosition, 50.0f, kZero);
    
    //Break Pedal
    self.breakPedal = [[UIView alloc]initWithFrame:self.breakPedalFrame];
    self.breakPedal.layer.contents = (__bridge id)breakPedal.CGImage;
    self.breakPedal.layer.opacity = 0.2f;
    self.breakPedal.layer.affineTransform = pedalPosition;
    self.breakPedal.layer.shadowColor = [UIColor blackColor].CGColor;
    [self.breakPedal addGestureRecognizer:self.userInteractionTools.breakPedalGesture];
    
    //Gesture Open Palette
    self.userInteractionTools.openColorOptionsGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(openColorPalette:)];
    self.userInteractionTools.openColorOptionsGesture.minimumPressDuration = 0.30f;
    
    //Pause
    UIImage *pauseButtonImage = [UIImage imageNamed:@"pauseImage.png"];
    self.userInteractionTools.pauseButton =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*0.67f-35.0f, CGRectGetMaxY(self.uiView.frame)*0.82f, 35.0f, 35.0f)];
    self.userInteractionTools.pauseButton.layer.contents = (__bridge id)pauseButtonImage.CGImage;
    self.userInteractionTools.pauseButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.pauseButton.alpha = kUINormaAlpha;
    self.userInteractionTools.pauseButton.layer.cornerRadius = self.userInteractionTools.hideControlButton.frame.size.width/2;
    [self.userInteractionTools.pauseButton addTarget:self action:@selector(togglePause:) forControlEvents:UIControlEventTouchUpInside];
    [self.uiView addSubview:self.userInteractionTools.pauseButton];
    
    //Voice
    UIImage *speakButtonImage = [UIImage imageNamed:@"speak.png"];
    self.userInteractionTools.voiceButton =[[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*0.67f-80.0f, CGRectGetMaxY(self.uiView.frame)*0.82f, 35.0f, 35.0f)];
    self.userInteractionTools.voiceButton.layer.contents = (__bridge id)speakButtonImage.CGImage;
    self.userInteractionTools.voiceButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.voiceButton.layer.contentsGravity = kCAGravityResizeAspect;
    self.userInteractionTools.voiceButton.alpha = kZero;
    self.userInteractionTools.voiceButton.layer.cornerRadius = self.userInteractionTools.hideControlButton.frame.size.width/2;
    [self.userInteractionTools.voiceButton addTarget:self action:@selector(voiceWord:) forControlEvents:UIControlEventTouchUpInside];
    [self.uiView addSubview:self.userInteractionTools.voiceButton];
    
    self.connector = [[UIView alloc]initWithFrame:CGRectMake(self.userInteractionTools.voiceButton.frame.origin.x+35.0f, self.userInteractionTools.pauseButton.frame.origin.y + self.userInteractionTools.pauseButton.frame.size.height-19.5f, kZero, 4.0f)];
    
    //Dictionary
    UIImage *dictionaryButtonImage = [UIImage imageNamed:@"dictionary"];
    self.userInteractionTools.presentDictionaryButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*0.67f-125.0f, CGRectGetMaxY(self.uiView.frame)*0.82f, 35.0f, 35.0f)];
    self.userInteractionTools.presentDictionaryButton.layer.contents = (__bridge id)dictionaryButtonImage.CGImage;
    self.userInteractionTools.presentDictionaryButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.presentDictionaryButton.layer.contentsGravity = kCAGravityResizeAspect;
    self.userInteractionTools.presentDictionaryButton.alpha = kZero;
    self.userInteractionTools.presentDictionaryButton.layer.cornerRadius = self.userInteractionTools.hideControlButton.frame.size.width/2;
    [self.uiView addSubview:self.userInteractionTools.presentDictionaryButton];
    [self.userInteractionTools.presentDictionaryButton addTarget:self action:@selector(presentDictionary:) forControlEvents:UIControlEventTouchUpInside];
    [self.uiView addSubview:self.userInteractionTools.presentDictionaryButton];
    
    self.connector2 = [[UIView alloc]initWithFrame:CGRectMake(self.userInteractionTools.presentDictionaryButton.frame.origin.x+35.0f, self.userInteractionTools.voiceButton.frame.origin.y + self.userInteractionTools.voiceButton.frame.size.height-19.5f, kZero, 4.0f)];
    
    //Swipe
    self.userInteractionTools.swipeUpToPreviousWord = [[UISwipeGestureRecognizer alloc]init];
    [self.userInteractionTools.swipeUpToPreviousWord setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.userInteractionTools.swipeUpToPreviousWord setEnabled:NO];
    [self.userInteractionTools.swipeUpToPreviousWord addTarget:self action:@selector(scrollToPreviousWord:)];
    [self.uiView addGestureRecognizer:self.userInteractionTools.swipeUpToPreviousWord];
    
    self.userInteractionTools.swipeDownToNextWord = [[UISwipeGestureRecognizer alloc]init];
    [self.userInteractionTools.swipeDownToNextWord setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.userInteractionTools.swipeDownToNextWord addTarget:self action:@selector(scrollToNextWord:)];
    [self.userInteractionTools.swipeDownToNextWord setEnabled:NO];
    [self.uiView addGestureRecognizer:self.userInteractionTools.swipeDownToNextWord];
    
#pragma Bottom Left Controls
    
    //Vowel Highlight
    self.highlightButtonLocationFrames = CGRectMake(100, CGRectGetHeight(self.uiView.frame) - 95, kToggleButtonDimension, kToggleButtonDimension);
    self.userInteractionTools.toggleVowels = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.userInteractionTools.toggleVowels addTarget:self action:@selector(toggleVowelsSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.userInteractionTools.toggleVowels buttonLayer:self.userInteractionTools.toggleVowels.layer color: self.userColor.colorSix string:@"æ"];
    self.userInteractionTools.toggleUserSelections.layer.affineTransform = CGAffineTransformMakeTranslation(-65, -100);
    
    //User Highlight
    self.userInteractionTools.toggleVowels.layer.affineTransform = CGAffineTransformMakeTranslation(-45, -40);
    self.userInteractionTools.toggleUserSelections = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.userInteractionTools.toggleUserSelections addTarget:self action:@selector(toggleUserSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.userInteractionTools.toggleUserSelections buttonLayer:self.userInteractionTools.toggleUserSelections.layer color:self.userColor.colorSix string:@"u"];
    self.userInteractionTools.toggleUserSelections.layer.affineTransform = CGAffineTransformMakeTranslation(-65, -100);
    
    //Consonant Highlight
    self.userInteractionTools.toggleConsonates = [[UIButton alloc]initWithFrame:self.highlightButtonLocationFrames];
    [self.userInteractionTools.toggleConsonates addTarget:self action:@selector(toggleConsonantsSelected) forControlEvents:UIControlEventTouchUpInside];
    [self modifyToggleButtonWithButton:self.userInteractionTools.toggleConsonates buttonLayer:self.userInteractionTools.toggleConsonates.layer color:self.userColor.colorSix string:@"ɳ"];
    
    //Flip XAxis
    self.userInteractionTools.flipXAxisButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.uiView.frame)+25.0f, CGRectGetHeight(self.uiView.frame)-kAccessButtonHeight-10.0f, kAccessButtonHeight, kAccessButtonHeight)];
    [self.userInteractionTools.flipXAxisButton addTarget:self action:@selector(flipXAxis:) forControlEvents:UIControlEventTouchUpInside];
    self.userInteractionTools.flipXAxisButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.flipXAxisButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.flipXAxisButton.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.flipXAxisButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.userInteractionTools.flipXAxisButton.layer.contents = (__bridge id)leftHandImage.CGImage;
    self.userInteractionTools.flipXAxisButton.layer.contentsGravity = kCAGravityResizeAspect;
    self.userInteractionTools.flipXAxisButton.alpha = kUINormaAlpha;
    self.userInteractionTools.flipXAxisButton.layer.transform = CATransform3DRotate(self.userInteractionTools.flipXAxisButton.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
    
    //Flip Lights
    self.userInteractionTools.lightsOffButton = [[UIButton alloc]initWithFrame: CGRectMake(CGRectGetMinX(self.uiView.frame)+85.0f, CGRectGetHeight(self.uiView.frame)-kAccessButtonHeight-10.0f, kAccessButtonHeight, kAccessButtonHeight)];
    [self.userInteractionTools.lightsOffButton addTarget:self action:@selector(toggleLight:) forControlEvents:UIControlEventTouchUpInside];
    self.userInteractionTools.lightsOffButton.layer.borderWidth = kBoarderWidth;
    self.userInteractionTools.lightsOffButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.lightsOffButton.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.lightsOffButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.userInteractionTools.lightsOffButton.layer.contents = (__bridge id)self.bulbDark.CGImage;
    self.userInteractionTools.lightsOffButton.alpha = kUINormaAlpha;
    self.userInteractionTools.lightsOffButton.layer.contentsGravity = kCAGravityResizeAspect;
    
    //Speed Adjuster Slider
    self.userInteractionTools.speedAdjusterSlider = [[UISlider alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*kOneMinusGoldenRatioMinusOne, CGRectGetMaxY(self.uiView.frame)/kGoldenRatio, 100, 30)];
    [self.userInteractionTools.speedAdjusterSlider addTarget:self action:@selector(adjustSpeedUsingSlider:) forControlEvents:UIControlEventValueChanged];
    [self rotationTransformation:self.userInteractionTools.speedAdjusterSlider.layer degrees:-40.0f];
    self.userInteractionTools.speedAdjusterSlider.layer.affineTransform = CGAffineTransformTranslate(self.userInteractionTools.speedAdjusterSlider.layer.affineTransform, 30.0f, 45.0f);
    self.userInteractionTools.speedAdjusterSlider.tintColor = self.userColor.colorSix;
    self.userInteractionTools.speedAdjusterSlider.alpha = kUINormaAlpha;
    self.userInteractionTools.speedAdjusterSlider.maximumValue = 1/self.currentReadingPosition.maxSpeed;
    self.userInteractionTools.speedAdjusterSlider.minimumValue = 1/self.currentReadingPosition.minSpeed;
    self.userInteractionTools.speedAdjusterSlider.value = 1/self.currentReadingPosition.normalSpeed;
    
    //Speed Label
    self.nonInteractiveViews.speedLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.uiView.frame)*kOneMinusGoldenRatioMinusOne, CGRectGetMaxY(self.uiView.frame)/kGoldenRatio, 220, 60)];
    self.nonInteractiveViews.speedLabel.font = [UIFont fontWithName:(self.fontType) size:kSmallFontSize];
    self.nonInteractiveViews.speedLabel.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.nonInteractiveViews.speedLabel.layer.shadowOpacity = kShadowOpacity;
    self.nonInteractiveViews.speedLabel.numberOfLines = kZero;
    self.nonInteractiveViews.speedLabel.alpha = kZero;
    
    //Speed Property Segment Controller
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
    
    //User Notes Text Field
    self.userInteractionTools.userNotesTextField = [[UITextField alloc]initWithFrame:CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, kZero, CGRectGetHeight(self.uiView.frame)-70.0f)];
    self.userInteractionTools.userNotesTextField.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.userInteractionTools.userNotesTextField.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.userNotesTextField.placeholder = @"Notes";
    self.userInteractionTools.userNotesTextField.textAlignment = NSTextAlignmentRight;
    self.userInteractionTools.userNotesTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    self.userInteractionTools.userNotesTextField.font = [UIFont fontWithName:(self.fontType) size:16];
    self.userInteractionTools.userNotesTextField.delegate = self;
    
    self.userNotesString = [[NSString alloc]init];
    
    //Access Assistant Text View
    self.userInteractionTools.accessTextViewButton = [[UIButton alloc]initWithFrame:CGRectMake(-kAccessButtonWidth/3, CGRectGetMidY(self.uiView.frame), 55.0f, kAccessButtonHeight)];
    [self.userInteractionTools.accessTextViewButton setTitle:@"t" forState:UIControlStateNormal];
    [self.userInteractionTools.accessTextViewButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:kGoldenRatioMinusOne] forState:UIControlStateNormal];
    self.userInteractionTools.accessTextViewButton.titleLabel.font = [UIFont fontWithName:(self.fontType) size:14];
    self.userInteractionTools.accessTextViewButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.userInteractionTools.accessTextViewButton.layer.borderWidth = kBoarderWidth/3;
    self.userInteractionTools.accessTextViewButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.accessTextViewButton.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.accessTextViewButton.layer.cornerRadius = kAccessButtonHeight/2;
    [self.userInteractionTools.accessTextViewButton addTarget:self action:@selector(revealAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.accessUserNotesTextFieldButton = [[UIButton alloc]initWithFrame:CGRectMake(-kAccessButtonWidth/3, CGRectGetMidY(self.uiView.frame)+kAccessButtonWidth, kAccessButtonWidth, kAccessButtonWidth)];
    self.userInteractionTools.accessUserNotesTextFieldButton.titleLabel.font = [UIFont fontWithName:(self.fontType) size:14];
    self.userInteractionTools.accessUserNotesTextFieldButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.userInteractionTools.accessUserNotesTextFieldButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.accessUserNotesTextFieldButton.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.accessUserNotesTextFieldButton.layer.contents = (__bridge id)penImage.CGImage;
    self.userInteractionTools.accessUserNotesTextFieldButton.layer.contentsGravity = kCAGravityResizeAspect;
    self.userInteractionTools.accessUserNotesTextFieldButton.alpha = kUINormaAlpha;
    [self.userInteractionTools.accessUserNotesTextFieldButton addTarget:self action:@selector(revealUserNotesView:) forControlEvents:UIControlEventTouchDown];
    [self.uiView addSubview:self.userInteractionTools.accessUserNotesTextFieldButton];
    
    self.userInteractionTools.toggleNoteBookButton = [[UIButton alloc]initWithFrame:CGRectMake(-kAccessButtonWidth, CGRectGetMidY(self.uiView.frame)+3*kAccessButtonWidth, kAccessButtonWidth, kAccessButtonWidth)];
    self.userInteractionTools.toggleNoteBookButton.titleLabel.font = [UIFont fontWithName:(self.fontType) size:14];
    self.userInteractionTools.toggleNoteBookButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.userInteractionTools.toggleNoteBookButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.userInteractionTools.toggleNoteBookButton.layer.shadowOpacity = kShadowOpacity;
    self.userInteractionTools.toggleNoteBookButton.layer.contents = (__bridge id)notebookImage.CGImage;
    self.userInteractionTools.toggleNoteBookButton.userInteractionEnabled = NO;
    self.userInteractionTools.toggleNoteBookButton.layer.contentsGravity = kCAGravityResizeAspect;
    self.userInteractionTools.toggleNoteBookButton.layer.opacity = kGoldenRatioMinusOne;
    [self.userInteractionTools.toggleNoteBookButton addTarget:self action:@selector(revealNoteBookView:) forControlEvents:UIControlEventTouchDown];
    [self.uiView addSubview:self.userInteractionTools.toggleNoteBookButton];
    
    self.userInteractionTools.expandTextViewButton = [[UIButton alloc]init];
    [ConfigureView configureCircleButton:self.userInteractionTools.expandTextViewButton title:@"+"];
    [self.userInteractionTools.expandTextViewButton addTarget:self action:@selector(expandAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.fullScreenTextViewButton = [[UIButton alloc]init];
    [ConfigureView configureCircleButton:self.userInteractionTools.fullScreenTextViewButton title:@">"];
    [self.userInteractionTools.fullScreenTextViewButton addTarget:self action:@selector(fullScreenTextView:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.retractTextViewButton = [[UIButton alloc]init];
    self.userInteractionTools.retractTextViewButton.alpha = 0.1;
    
    [self.userInteractionTools.retractTextViewButton setTitle:@"<" forState:UIControlStateNormal];
    [ConfigureView configureCircleButton:self.userInteractionTools.retractTextViewButton title:@"<"];
    [self.userInteractionTools.retractTextViewButton addTarget:self action:@selector(retractAssistantText:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.retractUserNotesTextFieldButton = [[UIButton alloc]init];
    [ConfigureView configureCircleButton:self.userInteractionTools.retractUserNotesTextFieldButton title:@"<"];
    [self.userInteractionTools.retractUserNotesTextFieldButton addTarget:self action:@selector(retractUserNotesField:) forControlEvents:UIControlEventTouchDown];
    
    self.userInteractionTools.assistantTextView = [[UITextView alloc]initWithFrame:CGRectMake(-120.0f, CGRectGetMidY(self.uiView.frame)-40, 120.0f, 120.0f)];
    self.userInteractionTools.assistantTextView.layer.zPosition = 0.9;
    self.userInteractionTools.assistantTextView.text = self.bookTextRawString;
    self.userInteractionTools.assistantTextView.textColor = self.userColor.colorSix;
    self.userInteractionTools.assistantTextView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0];
    self.userInteractionTools.assistantTextView.alpha = 1.0f;
    self.userInteractionTools.assistantTextView.editable = NO;
    
    self.nonInteractiveViews.dividerLabel = [[UILabel alloc]init];
    self.nonInteractiveViews.dividerLabel.backgroundColor = self.userColor.colorSix;
    self.nonInteractiveViews.dividerLabel.alpha = 0.40f;
    
    self.toggleFocusTextHighlightPaletteButton.color1 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, CGRectGetHeight(self.uiView.frame)*kColorPaletteheightMultiple, kColorPaletteWidth, kColorPaletteHeight)];
    self.userInteractionTools.userSelectedTextTextField.delegate = self;
    self.toggleFocusTextHighlightPaletteButton.color1.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.toggleFocusTextHighlightPaletteButton.color1.layer.shadowOpacity = kShadowOpacity;
    self.toggleFocusTextHighlightPaletteButton.color1.backgroundColor = self.userColor.colorOne;
    
    self.toggleFocusTextHighlightPaletteButton.color2 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.toggleFocusTextHighlightPaletteButton.color2.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.toggleFocusTextHighlightPaletteButton.color2.layer.shadowOpacity = kShadowOpacity;
    self.toggleFocusTextHighlightPaletteButton.color2.backgroundColor = self.userColor.colorTwo;
    
    self.toggleFocusTextHighlightPaletteButton.color3 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.toggleFocusTextHighlightPaletteButton.color3.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.toggleFocusTextHighlightPaletteButton.color3.layer.shadowOpacity = kShadowOpacity;
    self.toggleFocusTextHighlightPaletteButton.color3.backgroundColor = self.userColor.colorThree;
    
    self.toggleFocusTextHighlightPaletteButton.color4 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.toggleFocusTextHighlightPaletteButton.color4.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.toggleFocusTextHighlightPaletteButton.color4.layer.shadowOpacity = kShadowOpacity;
    self.toggleFocusTextHighlightPaletteButton.color4.backgroundColor = self.userColor.colorFour;
    
    self.toggleFocusTextHighlightPaletteButton.color5 = [[UIButton alloc]initWithFrame:CGRectMake(kColorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight)];
    self.toggleFocusTextHighlightPaletteButton.color5.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.toggleFocusTextHighlightPaletteButton.color5.layer.shadowOpacity = kShadowOpacity;
    self.toggleFocusTextHighlightPaletteButton.color5.backgroundColor = self.userColor.colorFive;
    
    [self.uiView addSubview:self.nonInteractiveViews.progressBar];
    [self.uiView addSubview:self.nonInteractiveViews.averageSpeedLabel];
    [self.nonInteractiveViews.progressBar addSubview:self.nonInteractiveViews.progress];
    [self.uiView addSubview:self.userInteractionTools.openSpeedometerDetailButton];
    [self.uiView addSubview:self.userInteractionTools.speedAdjusterSlider];
    [self.uiView addSubview:self.nonInteractiveViews.timerLabel];
    [self.uiView addSubview:self.breakPedal];
    [self.uiView addSubview:self.userInteractionTools.hideControlButton];
    [self.uiView addSubview:self.nonInteractiveViews.pinView];
    [self.uiView addSubview:self.nonInteractiveViews.speedometerReadLabel];
    [self.uiView addSubview:self.userInteractionTools.accessTextViewButton];
    [self.uiView addSubview:self.nonInteractiveViews.speedometerView];
    [self.uiView addSubview:self.userInteractionTools.toggleFocusTextModification];
    [self.uiView addSubview:self.userInteractionTools.togglePunctuationButton];
    [self.uiView  addSubview:self.userInteractionTools.flipXAxisButton];
    [self.uiView addSubview:self.userInteractionTools.lightsOffButton];
    
    [self.uiView setNeedsDisplay];
}

#pragma mark Modify Toggle Buttons

- (void)togglePause: (UIButton *)sender {
    self.swipeUpIndex = 1;
    self.swipeDownIndex = 1;
    
    self.readingInterfaceBOOLs.paused = !self.readingInterfaceBOOLs.paused;
    self.connector.backgroundColor = self.userColor.colorSix;
    self.connector.alpha = 1.0f;
    self.connector.layer.cornerRadius = 2.0f;
    self.connector2.backgroundColor = self.userColor.colorSix;
    self.connector2.alpha = 1.0f;
    self.connector2.layer.cornerRadius = 2.0f;
    [self.uiView addSubview:self.connector];
    [self.uiView addSubview:self.connector2];
    if (self.readingInterfaceBOOLs.paused) {
        self.userInteractionTools.swipeDownToNextWord.enabled = YES;
        self.userInteractionTools.swipeUpToPreviousWord.enabled = YES;
        
        NSLog(@"userEnabled %d %d", self.userInteractionTools.swipeUpToPreviousWord.enabled ,self.userInteractionTools.swipeDownToNextWord.enabled);
        
        UIImage *paused = [UIImage imageNamed:@"pauseImage.png"];
        self.userInteractionTools.pauseButton.alpha = 0.2f;
        self.userInteractionTools.pauseButton.layer.contents = (__bridge id)paused.CGImage;
        self.connector.backgroundColor = self.userColor.colorSix;
        self.connector2.backgroundColor = self.userColor.colorSix;
        
        [UIView animateWithDuration:0.25f animations:^{
            self.connector.frame = CGRectMake(self.userInteractionTools.voiceButton.frame.origin.x+34.0f, self.userInteractionTools.pauseButton.frame.origin.y + self.userInteractionTools.pauseButton.frame.size.height-20.5f, 12.0f, 6.0f);
            self.userInteractionTools.pauseButton.alpha = kUINormaAlpha;
            self.userInteractionTools.voiceButton.alpha = kUINormaAlpha;
            
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.connector2.frame = CGRectMake(self.userInteractionTools.presentDictionaryButton.frame.origin.x+34.0f, self.userInteractionTools.pauseButton.frame.origin.y + self.userInteractionTools.pauseButton.frame.size.height-20.5f, 12.0f, 6.0f);
                self.userInteractionTools.presentDictionaryButton.alpha = kUINormaAlpha;
            }];
        }];
        
        [self stopTimer];
    }
    if (!self.readingInterfaceBOOLs.paused) {
        self.userInteractionTools.swipeDownToNextWord.enabled = NO;
        self.userInteractionTools.swipeUpToPreviousWord.enabled = NO;
        NSLog(@"userEnabled %d %d", self.userInteractionTools.swipeUpToPreviousWord.enabled ,self.userInteractionTools.swipeDownToNextWord.enabled);
        
        UIImage *play = [UIImage imageNamed:@"playImage.png"];
        self.userInteractionTools.pauseButton.alpha = 0.2f;
        self.userInteractionTools.pauseButton.layer.contents = (__bridge id)play.CGImage;
        [UIView animateWithDuration:1.0f animations:^{
            self.connector.frame = CGRectMake(self.userInteractionTools.voiceButton.frame.origin.x+35.0f, self.userInteractionTools.pauseButton.frame.origin.y + self.userInteractionTools.pauseButton.frame.size.height-20.5f, kZero, 6.0f);
            self.connector2.frame = CGRectMake(self.userInteractionTools.presentDictionaryButton.frame.origin.x+35.0f, self.userInteractionTools.pauseButton.frame.origin.y + self.userInteractionTools.pauseButton.frame.size.height-20.5f, kZero, 6.0f);
            self.userInteractionTools.pauseButton.alpha = kUINormaAlpha;
            self.userInteractionTools.voiceButton.alpha = kZero;
            self.userInteractionTools.presentDictionaryButton.alpha = kZero;
            
        }];
        [self beginTimer];
    }
}

- (void)voiceWord: (UIButton *)sender {
    self.userInteractionTools.voiceButton.backgroundColor = self.userColor.colorSix;
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.voiceButton.backgroundColor = [UIColor colorWithWhite:kZero alpha:kZero];
    }];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:self.nonInteractiveViews.focusText.text];
    AVSpeechSynthesizer *syn = [[AVSpeechSynthesizer alloc] init];
    [syn speakUtterance:utterance];
    
}

- (void)scrollToPreviousWord: (UIGestureRecognizer *)sender {
    NSLog(@"Swiped up");
    if (self.readingInterfaceBOOLs.paused) {
        self.swipeDownIndex++;
        
        self.nonInteractiveViews.focusText.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+3-self.swipeDownIndex];
        self.nonInteractiveViews.previousWord3.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+7-self.swipeDownIndex];
        self.nonInteractiveViews.previousWord2.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+6-self.swipeDownIndex];
        self.nonInteractiveViews.previousWord.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+5-self.swipeDownIndex];
        self.nonInteractiveViews.focusText.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+4-self.swipeDownIndex];
        self.nonInteractiveViews.nextWord.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+3-self.swipeDownIndex];
        self.nonInteractiveViews.nextWord2.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+2-self.swipeDownIndex];
        self.nonInteractiveViews.nextWord3.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+1-self.swipeDownIndex];
        self.nonInteractiveViews.nextWord4.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex-self.swipeDownIndex];
    }
    else {
        return;
    }
}

- (void)scrollToNextWord: (UIGestureRecognizer *)sender {
    NSLog(@"Swiped down");
    if (self.readingInterfaceBOOLs.paused) {
        self.swipeUpIndex++;
        self.nonInteractiveViews.previousWord3.text = [self.wordsArray objectAtIndex:(self.currentReadingPosition.wordIndex+7+self.swipeUpIndex)];
        self.nonInteractiveViews.previousWord2.text = [self.wordsArray objectAtIndex:(self.currentReadingPosition.wordIndex+6+self.swipeUpIndex)];
        self.nonInteractiveViews.previousWord.text = [self.wordsArray objectAtIndex:(self.currentReadingPosition.wordIndex+5+self.swipeUpIndex)];
        self.nonInteractiveViews.focusText.text = [self.wordsArray objectAtIndex:(self.currentReadingPosition.wordIndex+4+self.swipeUpIndex)];
        self.nonInteractiveViews.nextWord.text = [self.wordsArray objectAtIndex:(self.currentReadingPosition.wordIndex+3+self.swipeUpIndex)];
        self.nonInteractiveViews.nextWord2.text = [self.wordsArray objectAtIndex:(self.currentReadingPosition.wordIndex+2+self.swipeUpIndex)];
        self.nonInteractiveViews.nextWord3.text = [self.wordsArray objectAtIndex:(self.currentReadingPosition.wordIndex+1+self.swipeUpIndex)];
        self.nonInteractiveViews.nextWord4.text = [self.wordsArray objectAtIndex:(self.currentReadingPosition.wordIndex+self.swipeUpIndex)];
    }
    else {
        return;
    }
}

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
    //    NSLog(@"%lu", (unsigned long)self.wordsArray.count);
    
}

- (void)loadText {
    self.chapterLabel = [[UILabel alloc]initWithFrame:CGRectMake(15.0f, CGRectGetMidY(self.uiView.frame)-85.0f, 150.0f, 130.0f)];
    [self.uiView addSubview:self.chapterLabel];
    
    self.nonInteractiveViews.dot = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.labelView.bounds)/2-4.0f, CGRectGetHeight(self.labelView.bounds)/2+kLabelHeightOffset, 8.0f, 8.0f)];
    [self.labelView addSubview:self.nonInteractiveViews.dot];
    
    self.nonInteractiveViews.focusText = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2, kLabelViewWidth, kLabelHeight)];
    [self.labelView addSubview:self.nonInteractiveViews.focusText];
    
    self.nonInteractiveViews.previousWord3 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-3*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [self.labelView addSubview:self.nonInteractiveViews.previousWord3];
    
    self.nonInteractiveViews.previousWord2 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-2*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [self.labelView addSubview:self.nonInteractiveViews.previousWord2];
    
    self.nonInteractiveViews.previousWord = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2-kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [self.labelView addSubview:self.nonInteractiveViews.previousWord];
    
    self.nonInteractiveViews.nextWord = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight, kLabelViewWidth, kLabelHeight)];
    [self.labelView addSubview:self.nonInteractiveViews.nextWord];
    
    self.nonInteractiveViews.nextWord2 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [self.labelView addSubview:self.nonInteractiveViews.nextWord2];
    
    self.nonInteractiveViews.nextWord3 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+2*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [self.labelView addSubview:self.nonInteractiveViews.nextWord3];
    
    self.nonInteractiveViews.nextWord4 = [[UILabel alloc]initWithFrame:CGRectMake(kZero, CGRectGetHeight(self.labelView.bounds)/2-kLabelHeight/2+kLabelHeight+3*kLabelHeightOffset, kLabelViewWidth, kLabelHeight)];
    [self.labelView addSubview:self.nonInteractiveViews.nextWord4];
    [self refreshText];
}

- (void)refreshText {
    self.nonInteractiveViews.dot.layer.cornerRadius = 4.0f;
    self.nonInteractiveViews.dot.layer.borderWidth = kBoarderWidth;
    self.nonInteractiveViews.dot.clipsToBounds = YES;
    self.nonInteractiveViews.dot.layer.borderColor = self.userColor.colorZero.CGColor;
    
    [ConfigureView configureReadingTextLabel:self.nonInteractiveViews.focusText alpha:kGoldenRatioMinusOne andColor:self.currentReadingPosition.highlightMovingTextColor];
    [ConfigureView configureReadingTextLabel:self.nonInteractiveViews.previousWord3 alpha:kHiddenControlRevealedAlhpa andColor:self.currentReadingPosition.highlightMovingTextColor];
    
    self.nonInteractiveViews.previousWord3.textColor = self.userColor.colorZero;
    
    [ConfigureView configureReadingTextLabel:self.nonInteractiveViews.previousWord2 alpha:kUINormaAlpha - 0.1 andColor:self.currentReadingPosition.highlightMovingTextColor];
    [ConfigureView configureReadingTextLabel:self.nonInteractiveViews.previousWord alpha:kUINormaAlpha andColor:self.currentReadingPosition.highlightMovingTextColor];
    [ConfigureView configureReadingTextLabel:self.nonInteractiveViews.nextWord alpha:kUINormaAlpha andColor:self.currentReadingPosition.highlightMovingTextColor];
    [ConfigureView configureReadingTextLabel:self.nonInteractiveViews.nextWord3 alpha:kUINormaAlpha-0.15f andColor:self.currentReadingPosition.highlightMovingTextColor];
    [ConfigureView configureReadingTextLabel:self.nonInteractiveViews.nextWord2 alpha:kUINormaAlpha-0.1f andColor:self.currentReadingPosition.highlightMovingTextColor];
    [ConfigureView configureReadingTextLabel:self.nonInteractiveViews.nextWord4 alpha:kUINormaAlpha-0.175f andColor:self.currentReadingPosition.highlightMovingTextColor];
    [self updateFontSize];
    
}

- (void)updateFontSize {
    self.nonInteractiveViews.focusText.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize];
    self.chapterLabel.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-11];
    self.userInteractionTools.assistantTextView.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-10];
    self.nonInteractiveViews.previousWord3.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-11];
    self.nonInteractiveViews.previousWord2.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-11];
    self.nonInteractiveViews.previousWord.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-10];
    self.nonInteractiveViews.nextWord.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-10];
    self.nonInteractiveViews.nextWord2.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-11];
    self.nonInteractiveViews.nextWord3.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-12];
    self.nonInteractiveViews.nextWord4.font = [UIFont fontWithName:(self.fontType) size:self.currentReadingPosition.mainFontSize-13];
}

#pragma mark Modify Time Methods

- (void)displayLinkLoop {
}

- (void)update {
    self.userInteractionTools.assistantTextView.textColor = self.userColor.colorSix;
    float angle = -(self.timeIntervalBetweenIndex *4.5)+8.5f;
    angle = MAX(angle, 4.75);
    angle = MIN(angle, 8.0);
    //    NSLog(@"%f", angle);
    
    self.nonInteractiveViews.speedometerReadLabel.text = [NSString stringWithFormat:@"%0.1fwpm",1/self.timeIntervalBetweenIndex*60];
    self.nonInteractiveViews.pinView.layer.affineTransform = CGAffineTransformMakeRotation(angle);
    if (self.timeIntervalBetweenIndex == self.currentReadingPosition.normalSpeed) {
        [self.deccelerationtimer invalidate];
        self.deccelerationtimer = nil;
    }
    
    if (self.timeIntervalBetweenIndex < self.currentReadingPosition.minSpeed) {
        self.currentReadingPosition.wordIndex ++;
    } else if (self.timeIntervalBetweenIndex >= self.currentReadingPosition.minSpeed) {
        self.currentReadingPosition.wordIndex --;
    }
    
    self.nonInteractiveViews.previousWord3.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+7];
    self.nonInteractiveViews.previousWord2.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+6];
    self.nonInteractiveViews.previousWord.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+5];
    self.nonInteractiveViews.focusText.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+4];
    self.nonInteractiveViews.nextWord.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+3];
    self.nonInteractiveViews.nextWord2.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+2];
    self.nonInteractiveViews.nextWord3.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex+1];
    self.nonInteractiveViews.nextWord4.text = [self.wordsArray objectAtIndex:self.currentReadingPosition.wordIndex];
    
    if (self.currentReadingPosition.wordIndex >= self.wordsArray.count - 3) {
        [self stopTimer];
    }
    
    else {
        [self beginTimer];
    }
    
    if (self.readingInterfaceBOOLs.highlightVowelsActivated) {
        [ConfigureView modifyTextWithString:kVowels color:self.currentReadingPosition.highlightVowelColor toLabel:self.nonInteractiveViews.focusText];
    }
    
    if (self.readingInterfaceBOOLs.highlightConsonantsActivated) {
        [ConfigureView modifyTextWithString:kConsonants color:self.currentReadingPosition.highlightConsonantColor toLabel:self.nonInteractiveViews.focusText];
    }
    
    if (self.readingInterfaceBOOLs.highlightUserSelectionActivated) {
        [ConfigureView modifyTextWithString:self.userInteractionTools.userSelectedTextTextField.text color:self.currentReadingPosition.highlightUserSelectedTextColor toLabel:self.nonInteractiveViews.focusText];
    }
    if (self.readingInterfaceBOOLs.punctuationActivated) {
        [self emphasizePunctuation:@",.;:"];
    }
    if (self.readingInterfaceBOOLs.highlightAssistantTextActivated) {
        //        [self highlightAssistantTextWithColor:self.currentReadingPosition.highlightMovingTextColor];
        [self highlightAssistantTextWithColor:self.userColor.colorZero];
        
        ;
        //        [self highlightAssistantTextWithColor:[UIColor blackColor]];
        
    }
    [ConfigureView highlighPunctuationWithColor:self.userColor.colorZero toLabel:self.nonInteractiveViews.focusText];
    
    self.nonInteractiveViews.dot.alpha = 0.8;
    [UIView animateWithDuration:self.timeIntervalBetweenIndex delay:kZero options:UIViewKeyframeAnimationOptionRepeat animations:^{
        self.nonInteractiveViews.dot.alpha = kZero;
    } completion:nil];
    
    [self progressCalculation];
    self.nonInteractiveViews.progressLabel.text = [NSString stringWithFormat:@"%0.2f%%", self.currentReadingPosition.progress];
    self.nonInteractiveViews.averageSpeedLabel.text = [NSString stringWithFormat:@"   avg spd:%0.1f", self.currentReadingPosition.averageReadingSpeed];
    [self.nonInteractiveViews.timerLabel setTitle:[NSString stringWithFormat:@"%0.0fs",self.timeElapsed] forState:UIControlStateNormal];
    self.timeCount++;
}

- (void)progressCalculation {
    float index = self.currentReadingPosition.wordIndex;
    self.currentTime = self.displaylink.timestamp;
    float wordArray = self.wordsArray.count;
    self.timeElapsed = self.currentTime - self.startTime;
    float wordPerSecond = self.timeElapsed/self.timeCount;
    self.currentReadingPosition.averageReadingSpeed = 1.0f/wordPerSecond*60;
    self.currentReadingPosition.progress = index/wordArray;
    //    NSLog(@"%f, %f, %f, %f", self.timeElapsed, index, self.currentReadingPosition.averageReadingSpeed, self.currentReadingPosition.progress);
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
        self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, self.currentReadingPosition.maxSpeed);
        self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, self.currentReadingPosition.normalSpeed);
    } else if (self.readingInterfaceBOOLs.breakingBegan) {
        self.timeIntervalBetweenIndex += time;
        self.timeIntervalBetweenIndex = MAX(self.timeIntervalBetweenIndex, self.currentReadingPosition.maxSpeed);
        self.timeIntervalBetweenIndex = MIN(self.timeIntervalBetweenIndex, self.currentReadingPosition.minSpeed + 0.10f);
    }
    //        NSLog(@"%f %d", self.timeIntervalBetweenIndex, self.wordIndex);
}

- (void)modifySpeed {
    if (self.readingInterfaceBOOLs.accelerationBegan) {
        //        NSLog(@"Accelerating!...");
        [self modifyTimeInterval:-self.currentReadingPosition.acceleration];
    } else if (!self.readingInterfaceBOOLs.accelerationBegan) {
        //        NSLog(@"Decelerating!... %f",self.timeIntervalBetweenIndex);
        [self modifyTimeInterval:+self.deceleration];
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.userInteractionTools.userSelectedTextTextField resignFirstResponder];
    [self.nextResponder touchesBegan:touches withEvent:event];
    if (self.timeIntervalBetweenIndex < 6.575) {
        self.nonInteractiveViews.pinView.layer.affineTransform = CGAffineTransformMakeRotation(self.timeIntervalBetweenIndex);
    }
    self.readingInterfaceBOOLs.accelerationBegan = YES;
    self.accelerationtimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Began %d", self.readingInterfaceBOOLs.accelerationBegan);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.readingInterfaceBOOLs.accelerationBegan = NO;
    [self.accelerationtimer invalidate];
    self.accelerationtimer = nil;
    [self.userInteractionTools.userNotesTextField resignFirstResponder];
    self.deccelerationtimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(modifySpeed) userInfo:nil repeats:YES];
    NSLog(@"Ended %d", self.readingInterfaceBOOLs.accelerationBegan);
    
    [UIView animateWithDuration:1.5 animations:^{
        self.userInteractionTools.speedPropertySelector.frame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), 30);
        self.nonInteractiveViews.speedLabel.alpha = kZero;
        self.userInteractionTools.flipXAxisButton.alpha = kUINormaAlpha;
        self.userInteractionTools.lightsOffButton.alpha = kUINormaAlpha;
    }];
    
    [self retractColorPalette];
    [self retractUserInputTextField];
    
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
        [self stopTimer];
        //        self.breaktimer = [NSTimer scheduledTimerWithTimeInterval: kUpdateSpeed target:self selector:@selector(startBreaking) userInfo:nil repeats:YES];
        NSLog(@"%f", self.timeIntervalBetweenIndex);
        
    } if (self.userInteractionTools.breakPedalGesture.state == UIGestureRecognizerStateEnded) {
        [self beginTimer];
        [UIView animateWithDuration:4.0f animations:^{
            self.breakPedal.alpha = kUINormaAlpha;
            self.breakPedal.layer.shadowOpacity = kZero;
            self.breakPedal.layer.shadowRadius = kZero;
        }];
        [UIView animateWithDuration:1.5 animations:^{
            self.nonInteractiveViews.pinView.layer.affineTransform = CGAffineTransformMakeRotation(self.timeIntervalBetweenIndex);
            self.breakPedal.alpha = 0.25;
            
        }];
        self.readingInterfaceBOOLs.breakingBegan = NO;
        NSLog(@"break ended");
        [self.breaktimer invalidate];
        self.breaktimer = nil;
    }
    [self.nonInteractiveViews.speedLabel removeFromSuperview];
    
}

#pragma mark Modify Text Methods

- (void)emphasizePunctuation: (NSString *)characterSetString {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:characterSetString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: self.nonInteractiveViews.focusText.attributedText];
    for (NSInteger charIdx = 0; charIdx < self.nonInteractiveViews.focusText.text.length; charIdx++){
        unichar currentCharacter = [self.nonInteractiveViews.focusText.text characterAtIndex:charIdx];
        BOOL isCharacterSet = [characterSet characterIsMember:currentCharacter];
        if (isCharacterSet) {
            [self stopTimer];
            UILabel *attributedStringLabel = [[UILabel alloc]initWithFrame:self.nonInteractiveViews.focusText.frame];
            attributedStringLabel.attributedText = attributedString;
            attributedStringLabel.font = [UIFont fontWithName:(self.fontType) size:20];
            attributedStringLabel.textColor = self.userColor.colorSix;
            attributedStringLabel.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
            attributedStringLabel.layer.shadowOpacity = kShadowOpacity;
            attributedStringLabel.alpha = kUINormaAlpha;
            [self.labelView addSubview:attributedStringLabel];
            [UIView animateWithDuration:0.45f animations:^{
                attributedStringLabel.layer.affineTransform = CGAffineTransformScale(attributedStringLabel.layer.affineTransform, 1.5f, 1.5f);
                attributedStringLabel.alpha = 0.30f;
            } completion:^(BOOL finished) {
                [attributedStringLabel removeFromSuperview];
                [self beginTimer];
            }];
            [attributedString addAttribute:NSForegroundColorAttributeName value:self.userColor.colorSix range:NSMakeRange(charIdx, 1)];
            [self.nonInteractiveViews.focusText setAttributedText: attributedString];
        }
    }
}

- (void)highlightAssistantTextWithColor: (UIColor *)color {
    NSCharacterSet *characterSet = [NSCharacterSet alphanumericCharacterSet];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: self.userInteractionTools.assistantTextView.attributedText];
    for (NSInteger charIdx = 0; charIdx < self.nonInteractiveViews.focusText.text.length; charIdx++){
        unichar currentWord = [self.nonInteractiveViews.focusText.text characterAtIndex:charIdx];
        BOOL isWord = [characterSet characterIsMember:currentWord];
        if (isWord) {
            
            self.currentReadingPosition.assistantTextRangeIndex = [([self.assistantTextRangeIndexArray objectAtIndex:self.currentReadingPosition.wordIndex+3])integerValue];
            self.currentReadingPosition.assistantTextRangeLength = [([self.assistantTextRangeLenghtArray objectAtIndex:self.currentReadingPosition.wordIndex+4])integerValue];
            
            NSInteger textViewRange = [([self.assistantTextRangeIndexArray objectAtIndex:self.currentReadingPosition.wordIndex+23])integerValue];
            NSInteger textViewLength = [([self.assistantTextRangeLenghtArray objectAtIndex:self.currentReadingPosition.wordIndex+24])integerValue];
            
            //            [self.userInteractionTools.assistantTextView scrollRangeToVisible:NSMakeRange(self.currentReadingPosition.assistantTextRangeIndex, self.currentReadingPosition.assistantTextRangeLength)];
            
            [self.userInteractionTools.assistantTextView scrollRangeToVisible:NSMakeRange(textViewRange, textViewLength)];
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(self.currentReadingPosition.assistantTextRangeIndex, self.currentReadingPosition.assistantTextRangeLength+1)];
            //                        NSLog(@"%lu, %lu, %d, %@", range, length, isWord, self.focusText.text);
            [self.userInteractionTools.assistantTextView setAttributedText: attributedString];
        }
    }
}

#pragma mark Vowels

- (void)togglePunctuation: (UIButton *)button {
    self.readingInterfaceBOOLs.punctuationActivated = !self.readingInterfaceBOOLs.punctuationActivated;
    if (self.readingInterfaceBOOLs.punctuationActivated) {
        [UIView animateWithDuration:1.0f animations:^{
            self.userInteractionTools.togglePunctuationButton.alpha = 1.0f;
            [self rotationTransformation:self.userInteractionTools.togglePunctuationButton.layer degrees:-45.0f];
        }];
    }
    if (!self.readingInterfaceBOOLs.punctuationActivated) {
        [UIView animateWithDuration:1.0f animations:^{
            self.userInteractionTools.togglePunctuationButton.alpha = kGoldenRatioMinusOne;
            [self rotationTransformation:self.userInteractionTools.togglePunctuationButton.layer degrees:45.0f];
        }];
    }
}

- (void)toggleVowelsSelected {
    self.readingInterfaceBOOLs.highlightVowelsActivated = !self.readingInterfaceBOOLs.highlightVowelsActivated;
    self.textColorBeingModified = Vowels;
    
    if (self.readingInterfaceBOOLs.highlightVowelsActivated) {
        [self.userInteractionTools.toggleVowels addGestureRecognizer:self.userInteractionTools.openColorOptionsGesture];
        [UIView animateWithDuration:0.5 animations:^{
            self.userInteractionTools.toggleVowels.frame = CGRectMake(55, CGRectGetHeight(self.uiView.frame) - 140, kToggleButtonDimension, kToggleButtonDimension);
            self.userInteractionTools.toggleVowels.layer.shadowOpacity = 0.55f;
            self.userInteractionTools.toggleVowels.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorOne;
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
            self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorSix;
            self.userInteractionTools.toggleVowels.alpha = kHiddenControlRevealedAlhpa;
        }];
    }
    
}


#pragma mark Consonants

- (void)toggleConsonantsSelected {
    self.readingInterfaceBOOLs.highlightConsonantsActivated = !self.readingInterfaceBOOLs.highlightConsonantsActivated;
    self.textColorBeingModified = Consonants;
    [self updatePaletteOrigin];
    if (self.readingInterfaceBOOLs.highlightConsonantsActivated) {
        [self.userInteractionTools.toggleConsonates addGestureRecognizer:self.userInteractionTools.openColorOptionsGesture];
        [UIView animateWithDuration:0.5f animations:^{
            self.userInteractionTools.toggleConsonates.frame = CGRectMake(100, CGRectGetHeight(self.view.frame) - 95, kToggleButtonDimension, kToggleButtonDimension);
            self.userInteractionTools.toggleConsonates.layer.shadowOpacity = kUINormaAlpha;
            self.userInteractionTools.toggleConsonates.layer.shadowOffset = CGSizeMake(-1.5, 7.0);
            self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorTwo;
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
            self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorSix;
            self.userInteractionTools.toggleConsonates.alpha = kUINormaAlpha;
        }];
    }
}


#pragma mark UserSelected

- (void)toggleUserSelected {
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
            self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorThree;
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
            self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorSix;
            self.userInteractionTools.toggleUserSelections.alpha = kUINormaAlpha;
        }];
    }
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
                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorOne;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorOne;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorOne;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorOne;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorOne;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorOne;
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorTwo;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorTwo;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorTwo;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorTwo;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorTwo;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorTwo;
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorThree;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorThree;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorThree;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorThree;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorThree;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorThree;
                    break;
                default:
                    break;
            }
            break;
        case 4:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorFour;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorFour;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorFour;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorFour;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorFour;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorFour;
                    break;
                default:
                    break;
            }
            break;
        case 5:
            switch (self.textColorBeingModified) {
                case Consonants:
                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorFive;
                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorFive;
                    break;
                case Vowels:
                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorFive;
                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorFive;
                    break;
                case UserSelection:
                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorFive;
                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorFive;
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
            self.speedShown = self.currentReadingPosition.normalSpeed;
            self.currentReadingPosition.normalSpeed = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = self.currentReadingPosition.minSpeed;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = self.currentReadingPosition.maxSpeed;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.userColor.colorOne;
            self.selectedSpeedToAdjustIndicator = @"normal speed";
            break;
        case MaximumSpeed:
            self.speedShown = self.currentReadingPosition.maxSpeed;
            self.currentReadingPosition.maxSpeed = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = 0.75f;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = 0.01f;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.currentReadingPosition.highlightUserSelectedTextColor;
            self.selectedSpeedToAdjustIndicator = @"max speed";
            break;
        case MinimumSpeed:
            self.speedShown = self.currentReadingPosition.minSpeed;
            self.currentReadingPosition.minSpeed = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = 1.0f;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = 0.01f;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.userColor.colorTwo;
            self.selectedSpeedToAdjustIndicator = @"min speed";
            break;
        case AccelerationSpeed:
            self.speedShown = self.currentReadingPosition.acceleration;
            self.currentReadingPosition.acceleration = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = 0.1f;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = 0.001f;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.userColor.colorThree;
            self.selectedSpeedToAdjustIndicator = @"acceleration";
            break;
        case Default:
            self.currentReadingPosition.normalSpeed = 0.45;
            self.currentReadingPosition.minSpeed = 1.0;
            self.currentReadingPosition.maxSpeed = 0.15;
            self.currentReadingPosition.acceleration = 0.002;
            self.deceleration = 0.0007;
            self.nonInteractiveViews.speedLabel.text = @"Default\nrestored";
            
            break;
        default:
            self.speedShown = self.currentReadingPosition.maxSpeed;
            self.currentReadingPosition.maxSpeed = self.userInteractionTools.speedAdjusterSlider.value;
            self.userInteractionTools.speedAdjusterSlider.maximumValue = 0.75f;
            self.userInteractionTools.speedAdjusterSlider.minimumValue = 0.01f;
            self.userInteractionTools.speedAdjusterSlider.maximumTrackTintColor = self.userColor.colorFive;
            self.selectedSpeedToAdjustIndicator = @"normal speed";
            break;
    }
    [self.uiView addSubview:self.nonInteractiveViews.speedLabel];
    [self.uiView addSubview:self.userInteractionTools.speedPropertySelector];
    self.speedShown = self.userInteractionTools.speedAdjusterSlider.value;
    float wordsPerMinute = 1/self.speedShown * 60;
    if (segmentSelected == Default) {
        self.nonInteractiveViews.speedLabel.text = @"Default\nrestored";
    } else {
        self.nonInteractiveViews.speedLabel.text = [NSString stringWithFormat:@"%@\n%0.1f\nwords/min",self.selectedSpeedToAdjustIndicator, wordsPerMinute];
        [UIView animateWithDuration:1.0 animations:^{
            self.nonInteractiveViews.speedLabel.alpha = kUINormaAlpha;
            self.userInteractionTools.speedPropertySelector.frame = CGRectMake(0, CGRectGetHeight(self.uiView.frame) - 30, CGRectGetWidth(self.uiView.frame), 30);
            self.userInteractionTools.speedPropertySelector.alpha = kHiddenControlRevealedAlhpa;
            self.userInteractionTools.flipXAxisButton.alpha = kZero;
            self.userInteractionTools.lightsOffButton.alpha = kZero;
            
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
            self.chapterLabel.alpha = kGoldenRatioMinusOne;
            [self.userInteractionTools.hideControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.userInteractionTools.hideControlButton setTitle:@"hide" forState:UIControlStateNormal];
            self.userInteractionTools.hideControlButton.backgroundColor = [UIColor blackColor];
            self.userInteractionTools.hideControlButton.alpha = 0.25f;
            self.userInteractionTools.toggleVowels.alpha = kHiddenControlRevealedAlhpa + 0.1f;
            self.userInteractionTools.toggleConsonates.alpha = kHiddenControlRevealedAlhpa;
            self.userInteractionTools.toggleUserSelections.alpha = kHiddenControlRevealedAlhpa + 0.2f;
            //            self.userInteractionTools.speedAdjusterSlider.alpha = kUINormaAlpha;
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
            //            self.userInteractionTools.speedAdjusterSlider.alpha = kZero;
            self.chapterLabel.alpha = kZero;
        }];
    }
}

- (void)revealHiddenUI {
    
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.hideControlButton.alpha = kUINormaAlpha;
        self.userInteractionTools.toggleFocusTextModification.alpha = kGoldenRatioMinusOne;
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
    self.nonInteractiveViews.dividerLabel.alpha = kZero;
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
        self.userInteractionTools.openSpeedometerDetailButton.alpha = 1.0f;
        self.nonInteractiveViews.progressLabel.alpha = 1.0f;
        self.nonInteractiveViews.pinView.alpha = 1.0f;
        self.nonInteractiveViews.speedometerView.alpha = 0.15;
        self.nonInteractiveViews.speedometerReadLabel.alpha = kUINormaAlpha;
        self.nonInteractiveViews.progress.alpha = 1.0f;
        self.nonInteractiveViews.averageSpeedLabel.alpha = 1.0f;
        self.nonInteractiveViews.progressBar.alpha = kUINormaAlpha;
    }];
    
}

- (void)hideSpeedometer {
    [UIView animateWithDuration:0.50f animations:^{
        self.userInteractionTools.openSpeedometerDetailButton.alpha = kZero;
        self.nonInteractiveViews.progressLabel.alpha = kZero;
        self.nonInteractiveViews.pinView.alpha = kZero;
        self.nonInteractiveViews.speedometerView.alpha = kZero;
        self.nonInteractiveViews.speedometerReadLabel.alpha = kZero;
        self.nonInteractiveViews.progress.alpha = kZero;
        self.nonInteractiveViews.averageSpeedLabel.alpha = kZero;
        self.nonInteractiveViews.progressBar.alpha = kZero;
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
    [self.uiView addSubview:self.toggleFocusTextHighlightPaletteButton.color5];
    [self.uiView addSubview:self.toggleFocusTextHighlightPaletteButton.color4];
    [self.uiView addSubview:self.toggleFocusTextHighlightPaletteButton.color3];
    [self.uiView addSubview:self.toggleFocusTextHighlightPaletteButton.color2];
    [self.uiView addSubview:self.toggleFocusTextHighlightPaletteButton.color1];
    self.toggleFocusTextHighlightPaletteButton.color1.tag = 1;
    self.toggleFocusTextHighlightPaletteButton.color2.tag = 2;
    self.toggleFocusTextHighlightPaletteButton.color3.tag = 3;
    self.toggleFocusTextHighlightPaletteButton.color4.tag = 4;
    self.toggleFocusTextHighlightPaletteButton.color5.tag = 5;
    [self.toggleFocusTextHighlightPaletteButton.color1 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.toggleFocusTextHighlightPaletteButton.color2 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.toggleFocusTextHighlightPaletteButton.color3 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.toggleFocusTextHighlightPaletteButton.color4 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    [self.toggleFocusTextHighlightPaletteButton.color5 addTarget:self action:@selector(changeSelectedTextColor:) forControlEvents:UIControlEventTouchUpInside];
    self.toggleFocusTextHighlightPaletteButton.color1.alpha = 1.0f;
    self.toggleFocusTextHighlightPaletteButton.color2.alpha = 1.0f;
    self.toggleFocusTextHighlightPaletteButton.color3.alpha = 1.0f;
    self.toggleFocusTextHighlightPaletteButton.color4.alpha = 1.0f;
    self.toggleFocusTextHighlightPaletteButton.color5.alpha = 1.0f;
    [UIView animateWithDuration:0.0 animations:^{
        [self updatePaletteOrigin];
        self.toggleFocusTextHighlightPaletteButton.color1.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.toggleFocusTextHighlightPaletteButton.color2.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.toggleFocusTextHighlightPaletteButton.color3.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.toggleFocusTextHighlightPaletteButton.color4.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.toggleFocusTextHighlightPaletteButton.color5.frame = CGRectMake(self.colorPaletteXOrigin-15, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.toggleFocusTextHighlightPaletteButton.color1.frame = CGRectMake(self.colorPaletteXOrigin, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.toggleFocusTextHighlightPaletteButton.color2.frame = CGRectMake(self.colorPaletteXOrigin + kColorPaletteWidth, self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.toggleFocusTextHighlightPaletteButton.color3.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *2), self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.toggleFocusTextHighlightPaletteButton.color4.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *3), self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
            self.toggleFocusTextHighlightPaletteButton.color5.frame = CGRectMake(self.colorPaletteXOrigin + (kColorPaletteWidth *4), self.colorPaletteYOrigin, kColorPaletteWidth, kColorPaletteHeight);
        }];
    }];
    
}
- (void)retractColorPalette {
    [UIView animateWithDuration:0.25 animations:^{
        self.toggleFocusTextHighlightPaletteButton.color1.alpha = kZero;
        self.toggleFocusTextHighlightPaletteButton.color2.alpha = kZero;
        self.toggleFocusTextHighlightPaletteButton.color3.alpha = kZero;
        self.toggleFocusTextHighlightPaletteButton.color4.alpha = kZero;
        self.toggleFocusTextHighlightPaletteButton.color5.alpha = kZero;
        
        self.toggleFocusTextHighlightPaletteButton.color1.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.toggleFocusTextHighlightPaletteButton.color2.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.toggleFocusTextHighlightPaletteButton.color3.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.toggleFocusTextHighlightPaletteButton.color4.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
        self.toggleFocusTextHighlightPaletteButton.color5.frame = CGRectMake(self.colorPaletteXOrigin-10, self.colorPaletteYOrigin, kZero, kColorPaletteHeight);
    }completion:^(BOOL finished) {
        [self.toggleFocusTextHighlightPaletteButton.color1 removeFromSuperview];
        [self.toggleFocusTextHighlightPaletteButton.color2 removeFromSuperview];
        [self.toggleFocusTextHighlightPaletteButton.color3 removeFromSuperview];
        [self.toggleFocusTextHighlightPaletteButton.color4 removeFromSuperview];
        [self.toggleFocusTextHighlightPaletteButton.color5 removeFromSuperview];
    }];
}

- (void)openUserInputTextField {
    [self.uiView addSubview:self.userInteractionTools.userSelectedTextTextField];
    [UIView animateWithDuration:1.20f animations:^{
        self.userInteractionTools.userSelectedTextTextField.frame = CGRectMake(kZero, self.userInteractionTools.toggleUserSelections.frame.origin.y-155.0f, 145.0f, 30.0f);
        
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
    
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.flipXAxisButton.alpha = kUINormaAlpha;
        [self rotationTransformation:self.userInteractionTools.expandTextViewButton.layer degrees:k180Rotation];
        self.userInteractionTools.accessTextViewButton.alpha = kZero;
        self.userInteractionTools.accessUserNotesTextFieldButton.alpha = kZero;
        self.userInteractionTools.assistantTextView.frame = CGRectMake(kZero, CGRectGetMidY(self.uiView.frame)-kControlButtonMidYOffset, CGRectGetWidth(self.uiView.frame)/2, kAssistantTextViewWidth);
        self.userInteractionTools.expandTextViewButton.alpha = 1.0f;
        self.userInteractionTools.retractTextViewButton.alpha = 1.0f;
        self.userInteractionTools.fullScreenTextViewButton.alpha =1.0f;
        self.userInteractionTools.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.retractTextViewButton.frame = CGRectMake(kControlButtonXOrigin, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.fullScreenTextViewButton.frame = CGRectMake(kControlButtonXOrigin+2*kControlButtonXOffset, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.lightsOffButton.frame = CGRectMake(CGRectGetMinX(self.uiView.frame)+85.0f, CGRectGetHeight(self.uiView.frame) -kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight);
        self.userInteractionTools.flipXAxisButton.frame = CGRectMake(CGRectGetMinX(self.uiView.frame)+25.0f, CGRectGetHeight(self.uiView.frame)-kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight);
        
    }completion:^(BOOL finished) {
        self.userInteractionTools.accessTextViewButton.backgroundColor = [UIColor colorWithWhite:kZero alpha:kZero];
        self.userInteractionTools.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.userInteractionTools.assistantTextView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.accessTextViewButton.layer.borderWidth = kBoarderWidth;
        self.userInteractionTools.accessTextViewButton.layer.borderColor = self.userColor.colorSix.CGColor;
        [self.userInteractionTools.accessTextViewButton setTitle:@"+" forState:UIControlStateNormal];
        [self.userInteractionTools.accessTextViewButton setTitleColor:self.userColor.colorSix forState:UIControlStateNormal];
        self.userInteractionTools.accessTextViewButton.layer.cornerRadius = kAccessButtonHeight/2;
        self.userInteractionTools.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight);
    }];
}

- (void)retractAssistantText: (UIButton *)sender {
    self.readingInterfaceBOOLs.highlightAssistantTextActivated = NO;
    self.readingInterfaceBOOLs.textFieldRevealed = NO;
    [self.userInteractionTools.accessTextViewButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:kZero] forState:UIControlStateNormal];
    self.userInteractionTools.assistantTextView.frame = CGRectMake(-kAssistantTextViewWidth, CGRectGetMidY(self.uiView.frame)-kControlButtonMidYOffset, kAssistantTextViewWidth, kAssistantTextViewWidth);
    self.userInteractionTools.accessTextViewButton.frame = CGRectMake(-kAccessButtonWidth/3, CGRectGetMidY(self.uiView.frame), 55.0f, kAccessButtonHeight);
    [self.userInteractionTools.accessTextViewButton setTitle:@"t" forState:UIControlStateNormal];
    [self.userInteractionTools.accessTextViewButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:kGoldenRatioMinusOne] forState:UIControlStateNormal];
    self.userInteractionTools.accessTextViewButton.titleLabel.textAlignment = NSTextAlignmentRight;
    self.userInteractionTools.accessUserNotesTextFieldButton.alpha = kUINormaAlpha;
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.expandTextViewButton.alpha = kZero;
        self.userInteractionTools.expandTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.userInteractionTools.expandTextViewButton.layer.affineTransform, M_PI/k180Rotation * k180Rotation);
        self.userInteractionTools.expandTextViewButton.frame = CGRectMake(kControlButtonXOrigin+kControlButtonXOffset, self.uiView.frame.origin.y-kControlButtonYOffset, kControlButtonDimension, kControlButtonDimension);
        self.userInteractionTools.accessTextViewButton.alpha = 1.0f;
        self.userInteractionTools.retractTextViewButton.alpha = kZero;
        self.userInteractionTools.fullScreenTextViewButton.alpha= kZero;
        
        self.userInteractionTools.lightsOffButton.frame = CGRectMake(CGRectGetMinX(self.uiView.frame)+85.0f, CGRectGetHeight(self.uiView.frame) -kAccessButtonHeight-10.0f, kAccessButtonHeight, kAccessButtonHeight);
        self.userInteractionTools.flipXAxisButton.frame = CGRectMake(CGRectGetMinX(self.uiView.frame)+25.0f, CGRectGetHeight(self.uiView.frame)-kAccessButtonHeight-10.0f, kAccessButtonHeight, kAccessButtonHeight);
        
    } completion:^(BOOL finished) {
        [self.userInteractionTools.retractTextViewButton removeFromSuperview];
        [self.userInteractionTools.expandTextViewButton removeFromSuperview];
        [self.nonInteractiveViews.dividerLabel removeFromSuperview];
        [self.userInteractionTools.fullScreenTextViewButton removeFromSuperview];
        [self revealSpeedometer];
    }];
}

- (void)expandAssistantText: (UIButton *)sender {
    self.readingInterfaceBOOLs.textFieldRevealed = NO;
    self.readingInterfaceBOOLs.hideControlsActivated = YES;
    [self hideSpeedometer];
    [self.uiView addSubview:self.nonInteractiveViews.dividerLabel];
    [self.userInteractionTools.accessTextViewButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.65f] forState:UIControlStateNormal];
    [self.userInteractionTools.accessTextViewButton setTitle:@"-" forState:UIControlStateNormal];
    self.userInteractionTools.accessTextViewButton.titleLabel.font = [UIFont fontWithName:self.fontType size:16.0f];
    [self.userInteractionTools.accessTextViewButton setTitleColor:self.userColor.colorSix forState:UIControlStateNormal];
    self.nonInteractiveViews.dividerLabel.frame = CGRectMake(CGRectGetMidX(self.uiView.frame), CGRectGetMidY(self.uiView.frame)+90.0f, 1.0f, 1.0f);
    self.userInteractionTools.fullScreenTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+140.0f, kAccessButtonHeight, kAccessButtonHeight);
    self.userInteractionTools.fullScreenTextViewButton.alpha = kZero;
    
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.lightsOffButton.frame = CGRectMake(CGRectGetMinX(self.uiView.frame)+85.0f, CGRectGetHeight(self.uiView.frame) -kAccessButtonHeight, kAccessButtonHeight, kAccessButtonHeight);
        self.nonInteractiveViews.dividerLabel.frame = CGRectMake(CGRectGetMidX(self.uiView.frame), kZero, 1.0f, CGRectGetHeight(self.uiView.frame));
        self.userInteractionTools.flipXAxisButton.alpha = kZero;
        self.userInteractionTools.expandTextViewButton.alpha = kZero;
        self.userInteractionTools.retractTextViewButton.alpha = kZero;
        self.userInteractionTools.expandTextViewButton.frame = CGRectMake(87.5f, self.uiView.frame.origin.y-65, 45, 45);
        self.userInteractionTools.retractTextViewButton.frame = CGRectMake(37.5f, self.uiView.frame.origin.y-65, 45, 45);
        self.userInteractionTools.assistantTextView.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, CGRectGetMidX(self.uiView.frame)-4.0f, CGRectGetHeight(self.uiView.frame)-70.0f);
        self.userInteractionTools.accessTextViewButton.alpha = 1.0f;
        self.userInteractionTools.fullScreenTextViewButton.alpha = 1.0f;
        self.nonInteractiveViews.dividerLabel.alpha = 0.2f;
        self.userInteractionTools.accessTextViewButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+90.0f, kAccessButtonHeight, kAccessButtonHeight);
        self.userInteractionTools.expandTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.userInteractionTools.expandTextViewButton.layer.affineTransform, M_PI/k180Rotation * k180Rotation);
        //        self.userInteractionTools.accessTextViewButton.layer.affineTransform = CGAffineTransformRotate(self.userInteractionTools.expandTextViewButton.layer.affineTransform, M_PI/k180Rotation * k180Rotation);
        
    }];
}

- (void)fullScreenTextView: (UIButton *)sender {
    [self hideSpeedometer];
    [self configureRoundButton:self.userInteractionTools.lightsOffButton dimension:kAccessButtonHeight];
    self.userInteractionTools.lightsOffButton.alpha = kZero;
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


- (void)revealUserNotesView: (UIButton *)sender {
    self.noteBook = [[ROADNoteBookView alloc]init];
    self.noteBook.arrayOfNotes = [NSMutableArray array];
    
    self.readingInterfaceBOOLs.hideControlsActivated = YES;
    self.userInteractionTools.toggleNoteBookButton.userInteractionEnabled = YES;
    [self hideSpeedometer];
    [self.uiView addSubview:self.nonInteractiveViews.dividerLabel];
    [self.uiView addSubview:self.userInteractionTools.userNotesTextField];
    [self.uiView addSubview:self.userInteractionTools.retractUserNotesTextFieldButton];
    self.userInteractionTools.retractUserNotesTextFieldButton.alpha = 1.0f;
    self.userInteractionTools.retractUserNotesTextFieldButton.frame = CGRectMake(-kAccessButtonWidth/3, CGRectGetMidY(self.uiView.frame)+90.0f, kAccessButtonHeight, kAccessButtonHeight);
    [UIView animateWithDuration:1.0f animations:^{
        self.nonInteractiveViews.dividerLabel.frame = CGRectMake(CGRectGetMidX(self.uiView.frame), kZero, 1.0f, CGRectGetHeight(self.uiView.frame));
        self.userInteractionTools.accessTextViewButton.alpha = kZero;
        self.userInteractionTools.accessUserNotesTextFieldButton.alpha =kZero;
        self.userInteractionTools.userNotesTextField.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, CGRectGetMidX(self.uiView.frame)-4.0f, CGRectGetHeight(self.uiView.frame)-70.0f);
        self.userInteractionTools.toggleNoteBookButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+3*kAccessButtonWidth, kAccessButtonWidth, kAccessButtonWidth);
        self.userInteractionTools.retractUserNotesTextFieldButton.frame = CGRectMake(CGRectGetMidX(self.uiView.frame)-kAccessButtonWidth/2, CGRectGetMidY(self.uiView.frame)+90.0f, kAccessButtonHeight, kAccessButtonHeight);
    }];
}

- (void)retractUserNotesField: (UIButton *)sender {
    [self revealSpeedometer];
    [UIView animateWithDuration:1.0f animations:^{
        self.userInteractionTools.userNotesTextField.frame = CGRectMake(kZero, CGRectGetMinY(self.uiView.frame)+30.0f, kZero, CGRectGetHeight(self.uiView.frame)-70.0f);
        self.nonInteractiveViews.dividerLabel.frame = CGRectMake(CGRectGetMidX(self.uiView.frame), CGRectGetMidY(self.uiView.frame)+90.0f, 1.0f, 1.0f);
        self.userInteractionTools.accessTextViewButton.alpha = 1.0f;
        self.userInteractionTools.accessUserNotesTextFieldButton.alpha = kUINormaAlpha;
        self.userInteractionTools.retractUserNotesTextFieldButton.frame = CGRectMake(kZero, CGRectGetMidY(self.uiView.frame)+90.0f, kAccessButtonHeight, kAccessButtonHeight);
        self.userInteractionTools.toggleNoteBookButton.frame = CGRectMake(-kAccessButtonWidth, CGRectGetMidY(self.uiView.frame)+3*kAccessButtonWidth, kAccessButtonWidth, kAccessButtonWidth);
        self.userInteractionTools.retractUserNotesTextFieldButton.alpha = kZero;
        
    }completion:^(BOOL finished) {
        [self.userInteractionTools.userNotesTextField removeFromSuperview];
        [self.nonInteractiveViews.dividerLabel removeFromSuperview];
        [self.userInteractionTools.retractUserNotesTextFieldButton removeFromSuperview];
    }];
    
}

- (void)toggleLight: (UIButton *)sender {
    self.readingInterfaceBOOLs.lightsOffActivated = !self.readingInterfaceBOOLs.lightsOffActivated;
    NSLog(@"pressed, %d", self.readingInterfaceBOOLs.lightsOffActivated);
    [self modifyLightState];
    [self refreshText];
    [self refreshLightsoffUI];
}

- (void)modifyLightState {
    if (self.readingInterfaceBOOLs.lightsOffActivated) {
        UIImage *darkPaper = [UIImage imageNamed:@"darkPaper"];
        self.uiView.layer.contents = (__bridge id)darkPaper.CGImage;
        self.userInteractionTools.lightsOffButton.layer.contents = (__bridge id)self.bulbLight.CGImage;
        self.currentReadingPosition.highlightMovingTextColor = [UIColor colorWithRed:242.0f/255.0f green:203.0f/255.0f blue:189.0f/255.0f alpha:1.0f];
    }
    if (!self.readingInterfaceBOOLs.lightsOffActivated) {
        UIImage *paper = [UIImage imageNamed:@"ivoryPaper.png"];
        self.uiView.layer.contents = (__bridge id)paper.CGImage;
        self.userInteractionTools.lightsOffButton.layer.contents = (__bridge id)self.bulbDark.CGImage;
        self.userInteractionTools.accessTextViewButton.layer.borderColor = self.userColor.colorSix.CGColor;
        self.currentReadingPosition.highlightMovingTextColor = [UIColor blackColor];
    }
}

- (void)refreshLightsoffUI {
    if (self.readingInterfaceBOOLs.lightsOffActivated) {
        self.nonInteractiveViews.dot.layer.borderColor = self.userColor.colorFive.CGColor;
        self.nonInteractiveViews.previousWord3.textColor = self.userColor.colorFive;
        self.nonInteractiveViews.progressLabel.textColor = self.userColor.colorFour;
        self.nonInteractiveViews.speedLabel.textColor = self.userColor.colorFour;
        self.nonInteractiveViews.averageSpeedLabel.textColor = self.userColor.colorFour;
        self.userInteractionTools.assistantTextView.textColor = [UIColor colorWithRed:175.0f/255.0f green:152.0f/255.0f blue:110.0/255.0f alpha:1.0f];
        
    }
    if (!self.readingInterfaceBOOLs.lightsOffActivated) {
        self.nonInteractiveViews.dot.layer.borderColor = self.userColor.colorZero.CGColor;
        self.nonInteractiveViews.previousWord3.textColor = self.userColor.colorZero;
        self.nonInteractiveViews.progressLabel.textColor = self.userColor.colorSix;
        self.nonInteractiveViews.speedLabel.textColor = self.userColor.colorSix;
        self.nonInteractiveViews.averageSpeedLabel.textColor = self.userColor.colorSix;
        self.userInteractionTools.assistantTextView.textColor = self.userColor.colorSix;
    }
    
    [self configureRoundButton:self.userInteractionTools.togglePunctuationButton dimension:kAccessButtonHeight];
    [self configureRoundButton:self.userInteractionTools.toggleFocusTextModification dimension:kAccessButtonHeight];
    [self rotationTransformation:self.userInteractionTools.modifyFocusTextFontSizeSlider.layer degrees:k180Rotation];
    
    [ConfigureView configureTrapezoidButton:self.userInteractionTools.toggleFocusTextModification title:@"+A" font:self.fontType andColor:self.currentReadingPosition.highlightMovingTextColor];
    [ConfigureView configureTrapezoidButton:self.userInteractionTools.togglePunctuationButton title:@"P" font:self.fontType andColor:self.currentReadingPosition.highlightMovingTextColor];
}

- (void)revealModifyFocusTextView: (UIButton *)sender {
    self.readingInterfaceBOOLs.modifyTextActivated = !self.readingInterfaceBOOLs.modifyTextActivated;
    if (self.readingInterfaceBOOLs.modifyTextActivated) {
        [self.uiView addSubview:self.userInteractionTools.modifyFocusTextFontSizeSlider];
        [self.uiView addSubview:self.nonInteractiveViews.focusFontSizeLabel];
        
        [UIView animateWithDuration:1.50f animations:^{
            self.nonInteractiveViews.focusFontSizeLabel.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)-145.0f, 60.0f, 30.0f, 30.0f);
            self.userInteractionTools.modifyFocusTextFontSizeSlider.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)-120.0f, 60.0f, 120.0f, 30.0f);
            self.userInteractionTools.toggleFocusTextModification.alpha = 1.0f;
            [self rotationTransformation:self.userInteractionTools.toggleFocusTextModification.layer degrees:-45.0f];
        }];
    }
    if (!self.readingInterfaceBOOLs.modifyTextActivated) {
        static const float kEdgeOffset = 5.0f;
        static const float kHeightOffset = -14.0f;
        [UIView animateWithDuration:0.75f animations:^{
            self.nonInteractiveViews.focusFontSizeLabel.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, 60.0f, 30.0f, 30.0f);
            self.userInteractionTools.modifyFocusTextFontSizeSlider.frame = CGRectMake(CGRectGetMaxX(self.uiView.frame)+120, 60.0f, 120.0f, 30.0f);
            self.toggleFocusTextHighlightPaletteButton.color1.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
            self.toggleFocusTextHighlightPaletteButton.color2.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
            self.toggleFocusTextHighlightPaletteButton.color3.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
            self.toggleFocusTextHighlightPaletteButton.color4.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
            self.toggleFocusTextHighlightPaletteButton.color5.frame = CGRectMake(self.userInteractionTools.toggleFocusTextModification.frame.origin.x+kAccessButtonWidth+kEdgeOffset, self.userInteractionTools.toggleFocusTextModification.frame.origin.y+kHeightOffset, kZero, kColorPaletteHeight);
            self.userInteractionTools.toggleFocusTextModification.alpha = kGoldenRatioMinusOne;
            [self rotationTransformation:self.userInteractionTools.toggleFocusTextModification.layer degrees:45.0f];
        }completion:^(BOOL finished) {
            [self.nonInteractiveViews.focusFontSizeLabel removeFromSuperview];
            [self.userInteractionTools.modifyFocusTextFontSizeSlider removeFromSuperview];
        }];
    }
}


- (void)adjustFontSize: (UISlider *)sender {
    self.currentReadingPosition.mainFontSize = self.userInteractionTools.modifyFocusTextFontSizeSlider.value;
    self.nonInteractiveViews.focusFontSizeLabel.text = [NSString stringWithFormat:@"%0.1f",self.currentReadingPosition.mainFontSize];
    self.nonInteractiveViews.focusFontSizeLabel.font = [UIFont fontWithName:(self.fontType) size:12.0f];
    [self updateFontSize];
}

- (void)flipXAxis: (UIButton *)sender {
    self.uiView.layer.transform = CATransform3DRotate(self.uiView.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
    [self flipUI];
    
}
- (void)flipUI {
    self.currentReadingPosition.xAxisFlipped = !self.currentReadingPosition.xAxisFlipped;
    
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
        self.nonInteractiveViews.speedLabel.layer.transform = CATransform3DRotate(self.nonInteractiveViews.speedLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.nonInteractiveViews.speedometerReadLabel.layer.transform = CATransform3DRotate(self.nonInteractiveViews.speedometerReadLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.nonInteractiveViews.averageSpeedLabel.layer.transform = CATransform3DRotate(self.nonInteractiveViews.speedometerReadLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.nonInteractiveViews.progressLabel.layer.transform = CATransform3DRotate(self.nonInteractiveViews.progressLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.chapterLabel.layer.transform = CATransform3DRotate(self.chapterLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.nonInteractiveViews.focusFontSizeLabel.layer.transform = CATransform3DRotate(self.nonInteractiveViews.focusFontSizeLabel.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.hideControlButton.layer.transform = CATransform3DRotate(self.userInteractionTools.hideControlButton.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.toggleConsonates.layer.transform = CATransform3DRotate(self.userInteractionTools.toggleConsonates.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.toggleUserSelections.layer.transform = CATransform3DRotate(self.userInteractionTools.toggleUserSelections.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.speedPropertySelector.layer.transform = CATransform3DRotate(self.userInteractionTools.speedPropertySelector.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
        self.userInteractionTools.userSelectedTextTextField.layer.transform = CATransform3DRotate(self.userInteractionTools.userSelectedTextTextField.layer.transform, M_PI, 0.0f, 1.0f, 0.0f);
    }];
}

- (void)configureRoundButton: (UIButton *)button dimension: (float)dimension{
    button.layer.borderWidth = kBoarderWidth;
    button.layer.borderColor = self.currentReadingPosition.defaultButtonColor.CGColor;
    button.layer.cornerRadius = dimension/2;
    button.layer.shadowOffset = CGSizeMake(-1, 6.0f);
    button.layer.shadowOpacity = kShadowOpacity;
    [button setTitleColor:self.currentReadingPosition.defaultButtonColor forState:UIControlStateNormal];
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
    NSString *focusTextNoPunctuation = [self.nonInteractiveViews.focusText.text stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
    
    self.dictionaryViewController = [[UIReferenceLibraryViewController alloc]initWithTerm:focusTextNoPunctuation];
    self.dictionaryViewController.view.layer.borderWidth = kBoarderWidth;
    self.dictionaryViewController.view.layer.borderColor = self.currentReadingPosition.defaultButtonColor.CGColor;
    self.dictionaryViewController.view.alpha = kGoldenRatioMinusOne;
    self.dictionaryViewController.view.frame = CGRectMake(kZero, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.uiView.frame), CGRectGetHeight(self.uiView.frame)/2);
    self.dictionaryViewController.view.tintColor = self.userColor.colorSix;
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
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            self.userInteractionTools.presentDictionaryButton.alpha = kZero;
        }];
    }];
}

- (void)retractDictionary: (UIButton *)sender {
    [self beginTimer];
    [UIView animateWithDuration:0.5f animations:^{
        self.userInteractionTools.presentDictionaryButton.alpha = kUINormaAlpha;
        self.userInteractionTools.retractDictionaryButton.frame = CGRectMake(CGRectGetWidth(self.uiView.frame)/2-kAccessButtonHeight/2, CGRectGetHeight(self.uiView.frame), kAccessButtonHeight, kAccessButtonHeight);
        self.dictionaryViewController.view.frame = CGRectMake(kZero, CGRectGetHeight(self.uiView.frame), CGRectGetWidth(self.uiView.frame), CGRectGetHeight(self.uiView.frame)/2);
        
    }completion:^(BOOL finished) {
        [self.userInteractionTools.retractDictionaryButton removeFromSuperview];
        [self.dictionaryViewController.view removeFromSuperview];
        
    }];
}

- (void)toggleSpeedometerDetails: (UIButton *)sender {
    NSLog(@"pressed");
    self.readingInterfaceBOOLs.speedometerDetailOpened = !self.readingInterfaceBOOLs.speedometerDetailOpened;
    if (!self.readingInterfaceBOOLs.speedometerDetailOpened) {
        [UIView animateWithDuration:0.75f animations:^{
            self.userInteractionTools.openSpeedometerDetailButton.backgroundColor = [UIColor colorWithRed:138.0f/255.0f green:131.0f/255.0f blue:117.0f/255.0f alpha:0.7f];
            self.nonInteractiveViews.averageSpeedLabel.frame = CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame)+20.0f, kZero, kProgressBarHeight*1.5);
            self.nonInteractiveViews.timerLabel.frame = CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2+65.0f, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame)+20.0f, kZero, 14.0f*1.5);
            self.nonInteractiveViews.progressBar.frame = CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame), kZero, 14.0f - kProgressOffSetFromProgressBar);
            self.nonInteractiveViews.progressLabel.alpha = kZero;
            self.nonInteractiveViews.progress.frame = CGRectMake(2.0f, 1.50f, kZero, kProgressBarHeight/2 + 0.5);
        }];
    }
    if (self.readingInterfaceBOOLs.speedometerDetailOpened) {
        [UIView animateWithDuration:0.75f animations:^{
            self.nonInteractiveViews.progressLabel.alpha = 1.0f;
            self.userInteractionTools.openSpeedometerDetailButton.backgroundColor = self.userColor.colorFour;
            self.nonInteractiveViews.progressBar.frame = CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame), kProgressBarWidth, kProgressBarHeight - kProgressOffSetFromProgressBar);
            self.nonInteractiveViews.timerLabel.frame = CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2+65.0f, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame)+20.0f, 25.0f, 14.0f*1.5);
            
            self.nonInteractiveViews.progress.frame = CGRectMake(2.0f, 1.50f, kProgressBarHeight, kProgressBarHeight/2 + 0.5);
            
            self.nonInteractiveViews.averageSpeedLabel.frame = CGRectMake(self.nonInteractiveViews.speedometerView.frame.size.width + kSpeedometerDimension/2, CGRectGetMidY(self.nonInteractiveViews.speedometerView.frame)+20.0f, kProgressBarWidth, 14.0f*1.5);
        }];
    }
}

- (void)revealNoteBookView: (UIButton *)sender {
    //    self.noteBook.arrayOfNotes = self.currentReadingPosition.userNotesArray;
    //        self.currentReadingPosition.userNotesArray = self.noteBook.arrayOfNotes;
    
    [self presentViewController:self.noteBook animated:YES completion:nil];
    
    
    [self stopTimer];
}

#pragma TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *saveString = [[NSString alloc]init];
    [self.userInteractionTools.userSelectedTextTextField resignFirstResponder];
    [self.userInteractionTools.userNotesTextField resignFirstResponder];
    saveString = self.userInteractionTools.userNotesTextField.text;
    
    
    [self.noteBook.arrayOfNotes addObject:saveString];
    //    [self.currentReadingPosition.userNotesArray addObject:saveString];
    NSLog(@"%@,%@", self.userNotesString, self.currentReadingPosition.userNotesArray);
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//-(BOOL)shouldAutorotate
//{
//    return YES;
//}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


@end
