//
//  ConfigureView.m
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ConfigureView.h"

@implementation ConfigureView
static const float kZero = 0.0f;
static const float kAccessButtonHeight = 45.0f;
static const float kSmallFontSize = 10.0f;

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

@end
