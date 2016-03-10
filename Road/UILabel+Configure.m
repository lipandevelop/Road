//
//  UILabel+Configure.m
//  Road
//
//  Created by Li Pan on 2016-03-10.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "UILabel+Configure.h"
#import "ROADConstants.h"

@implementation UILabel (Configure)

- (void)configureAverageSpeedLabelWithBorderColor: (UIColor *)color {
    self.layer.borderWidth = kBorderWidth/2;
    self.layer.borderColor = color.CGColor;
    self.layer.cornerRadius = kProgressBarHeight/1.50f;
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.layer.shadowOpacity = kShadowOpacity;
    self.alpha = kOne;
    self.font = [UIFont fontWithName:(kFontType) size:10.0f];
    self.textAlignment = NSTextAlignmentLeft;
}

- (void)configureSpeedometerReadLabels {
    self.font = [UIFont fontWithName:(kFontType) size:kSmallFontSize];
    self.alpha = kUINormaAlpha;
    self.textAlignment = NSTextAlignmentCenter;
}

- (void)configureProgressLabelWithColor: (UIColor *)color {
    self.textColor = color;
    self.font = [UIFont fontWithName:(kFontType) size:kSmallFontSize];
    self.alpha = kZero;
}

@end
