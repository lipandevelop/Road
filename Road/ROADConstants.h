//
//  ROADConstants.h
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ModifyColorForTextActivated) {
    Vowels,
    Consonants,
    UserSelection,
};

typedef NS_ENUM(NSInteger, SpeedAdjustmentSegmentSelected) {
    NormalSpeed,
    MaximumSpeed,
    MinimumSpeed,
    AccelerationSpeed,
    Default,
};

typedef NS_ENUM(NSInteger, ColorPaletteColorSelected) {
    ColorOne,
    ColorTwo,
    ColorThree,
    ColorFour,
    ColorFive,
};

@interface ROADConstants : NSObject

extern const float kUpdateSpeed;
extern const float kShadowOpacity;
extern const float kBoarderWidth;
extern const float kMoney;
extern const float kGoldenRatio;
extern const float kGoldenRatioMinusOne;
extern const float kOneMinusGoldenRatioMinusOne;
extern const float kSmallFontSize;
extern const float kHiddenControlRevealedAlhpa;
extern const float kZero;
extern const float kUINormaAlpha;
extern const float kAccessButtonHeight;

//PaletteConstants
extern const float kColorPaletteheightMultiple;
extern const float kColorPaletteXOrigin;
extern const float kColorPaletteWidth;
extern const float kColorPaletteHeight;

extern const float kToggleButtonDimension;
extern const float kToggleButtonOffsetX;

extern const float kControlButtonXOrigin;
extern const float kControlButtonXOffset;
extern const float kControlButtonMidYOffset;
extern const float kControlButtonYOffset;
extern const float kControlButtonDimension;
extern const float kAssistantTextViewWidth;

extern const float k180Rotation;

extern const float kLabelViewWidth;
extern const float kLabelViewHeight;
extern const float kLabelHeight;
extern const float kLabelHeightOffset;

extern const float kDefaultNormalSpeed;
extern const float kDefaultMaxSpeed;;
extern const float kDefaultMinSpeed;;
extern const float kDefaultAcceleration;;

extern const float kDefaultMainFontSize;


extern NSString *const kVowels;
extern NSString *const kConsonants;

@end
