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


+ (void)configureReadingTextLabel: (UILabel *)label alpha:(float)alpha andColor: (UIColor *)color{
    label.numberOfLines = kZero;
    label.textColor = color;
    label.alpha = alpha;
    label.textAlignment = NSTextAlignmentCenter;
}

+ (void)configureTrapezoidButton: (UIButton *)button title:(NSString *)title font: (NSString *)font andColor: (UIColor *)color{
    button.layer.cornerRadius = kAccessButtonHeight;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:(font) size:kSmallFontSize];
    button.alpha = kGoldenRatioMinusOne;
}

+ (void)configureCircleButton:(UIButton *)button title:(NSString *)title {
    button.alpha = 0.1;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:98.0f/255.0f green:91.0f/255.0f blue:77.0f/255.0f alpha:0.8f] forState:UIControlStateNormal];
    button.layer.borderWidth = kBorderWidth;
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

+ (void)highlighPunctuationWithColor: (UIColor *)color toLabel: (UILabel *)label{
    NSCharacterSet *characterSet = [NSCharacterSet punctuationCharacterSet];
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

@end
