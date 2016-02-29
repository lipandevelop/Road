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

@property (nonatomic, strong) UILongPressGestureRecognizer *breakPedalGesture;
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
@property (nonatomic, strong) UITextView *assistantTextView;
@property (nonatomic, strong) UIButton *fullScreenTextViewButton;
@property (nonatomic, strong) UIButton *lightsOffButton;
@property (nonatomic, strong) UIButton *exitReadView;
@property (nonatomic, strong) UIButton *retractTextViewButton;
@property (nonatomic, strong) UIButton *flipXAxisButton;
@property (nonatomic, strong) UILongPressGestureRecognizer *openColorOptionsGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureDrawTool;
@property (nonatomic, strong) UISlider *speedAdjusterSlider;
@property (nonatomic, strong) UISlider *modifyFocusTextFontSizeSlider;
@property (nonatomic, strong) UISegmentedControl *speedPropertySelector;
@property (nonatomic, strong) UITextField *userSelectedTextTextField;

@end
