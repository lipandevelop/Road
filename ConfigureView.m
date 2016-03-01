//
//  ConfigureView.m
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ConfigureView.h"
@interface ConfigureView ()
@property (nonatomic, strong) UIColor *defaultButtonColor;

@end

@implementation ConfigureView
static const float kZero = 0.0f;
static const float kAccessButtonHeight = 45.0f;
static const float kSmallFontSize = 10.0f;
static const float kBoarderWidth = 1.5f;
static const float kShadowOpacity = 0.35f;


+ (void)configureReadingTextLabel: (UILabel *)label alpha:(float)alpha {
    label.numberOfLines = kZero;
    label.textColor = [UIColor blackColor];
    label.alpha = alpha;
    label.textAlignment = NSTextAlignmentCenter;
}

+ (void)configureTrapezoidButton: (UIButton *)button title:(NSString *)title font: (NSString *)font{
    button.layer.cornerRadius = kAccessButtonHeight;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:(font) size:kSmallFontSize];
}

+ (void)configureCircleButton:(UIButton *)button title:(NSString *)title {
    button.alpha = 0.1;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:98.0f/255.0f green:91.0f/255.0f blue:77.0f/255.0f alpha:0.8f] forState:UIControlStateNormal];
    button.layer.borderWidth = kBoarderWidth;
    button.layer.borderColor = [UIColor colorWithRed:98.0f/255.0f green:91.0f/255.0f blue:77.0f/255.0f alpha:0.8f].CGColor;
    button.layer.cornerRadius = 22.5f;
    button.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
   button.layer.shadowOpacity = kShadowOpacity;
}

+ (void)modifyTextWithString: (NSString *)characterSetString color: (UIColor *)color toLabel: (UILabel *)label {
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:characterSetString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: label.attributedText];
    for (NSInteger charIdx = 0; charIdx < label.text.length; charIdx++){
        unichar currentCharacter = [label.text characterAtIndex:charIdx];
        BOOL isCharacterSet = [characterSet characterIsMember:currentCharacter];
        if (isCharacterSet) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(charIdx, 1)];
            [label setAttributedText: attributedString];
        }
    }
}

+ (void)highlighPunctuationWithColor: (UIColor *)color toLabel: (UILabel *)label {
    NSCharacterSet *characterSet = [NSCharacterSet punctuationCharacterSet];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: label.attributedText];
    for (NSInteger charIdx = 0; charIdx < label.text.length; charIdx++){
        unichar currentCharacter = [label.text characterAtIndex:charIdx];
        BOOL isCharacterSet = [characterSet characterIsMember:currentCharacter];
        if (isCharacterSet) {
            //            [self pauseforPunctuation];
            [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(charIdx, 1)];
            [label setAttributedText: attributedString];
        }
    }
}

@end