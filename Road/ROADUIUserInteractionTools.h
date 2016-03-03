//
//  UIUserInteractionButtons.h
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ROADUIUserInteractionTools : NSObject

@property (nonatomic, strong) UIButton *toggleFocusTextModification;
@property (nonatomic, strong) UIButton *togglePunctuationButton;
@property (nonatomic, strong) UIButton *hideControlButton;
@property (nonatomic, strong) UIButton *toggleConsonates;
@property (nonatomic, strong) UIButton *toggleVowels;
@property (nonatomic, strong) UIButton *toggleUserSelections;
@property (nonatomic, strong) UIButton *presentDictionaryButton;
@property (nonatomic, strong) UIButton *retractDictionaryButton;
@property (nonatomic, strong) UIButton *restoreDefaultButton;
@property (nonatomic, strong) UIButton *accessTextViewButton;
@property (nonatomic, strong) UIButton *accessUserNotesTextFieldButton;
@property (nonatomic, strong) UIButton *expandTextViewButton;
@property (nonatomic, strong) UIButton *fullScreenTextViewButton;
@property (nonatomic, strong) UIButton *exitReadView;
@property (nonatomic, strong) UIButton *retractTextViewButton;

@property (nonatomic, strong) UIButton *flipXAxisButton;
@property (nonatomic, strong) UIButton *lightsOffButton;
@property (nonatomic, strong) UIButton *toggleSoundButton;

@property (nonatomic, strong) UIButton *openSpeedometerDetailButton;
@property (nonatomic, strong) UIButton *retractUserNotesTextFieldButton;
@property (nonatomic, strong) UIButton *toggleNoteBookButton;
@property (nonatomic, strong) UIButton *snapShotButton;
@property (nonatomic, strong) UIButton *chooseDrawingToolColorButton;

@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *voiceButton;

@property (nonatomic, strong) UIButton *toggleMusicButton;

@property (nonatomic, strong) UITextView *assistantTextView;
@property (nonatomic, strong) UITextField *userSelectedTextTextField;
@property (nonatomic, strong) UITextField *userNotesTextField;

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpToPreviousWord;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownToNextWord;

@property (nonatomic, strong) UISlider *modifyFocusTextFontSizeSlider;
@property (nonatomic, strong) UISlider *speedAdjusterSlider;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureDrawTool;
@property (nonatomic, strong) UILongPressGestureRecognizer *openColorOptionsGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *breakPedalGesture;


@property (nonatomic, strong) UISegmentedControl *speedPropertySelector;









@end
