//
//  UIView+Stylizer.m
//  Road
//
//  Created by Li Pan on 2016-03-10.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "UIView+Stylizer.h"
#import "ROADConstants.h"

@implementation UIView (Stylizer)

- (void)stylizeGasPedalView {
    UIImage *gasPedal = [UIImage imageNamed:@"finger_clean.png"];
    self.layer.contents = (__bridge id)gasPedal.CGImage;
    self.layer.opacity = kUINormaAlpha;
}

- (void)stylizeBrakePedalView {
    UIImage *brakePedal = [UIImage imageNamed:@"brake.png"];
    self.layer.contents = (__bridge id)brakePedal.CGImage;
    self.layer.opacity = kUINormaAlpha;
    self.layer.zPosition = kOne;
    self.layer.cornerRadius = kBrakePedalDimension;
    self.layer.borderWidth = kBorderWidth;
    self.layer.borderColor = [UIColor colorWithWhite:kZero alpha:kOne].CGColor;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.layer.shadowOpacity = kOneMinusGoldenRatioMinusOne;
}

- (void)stylizeSpeedometerView {
    UIImage *speedometerImage = [UIImage imageNamed:@"Speedometer.png"];
    self.layer.contents = (__bridge id)speedometerImage.CGImage;
    self.layer.contentsGravity = kCAGravityResizeAspect;
    self.alpha = 0.20f;
    self.userInteractionEnabled = NO;
}

- (void)stylizeProgressBarView {
    self.layer.borderWidth = kBorderWidth/2;
    self.layer.cornerRadius = 5.0f;
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.layer.shadowOpacity = kShadowOpacity;
    self.alpha = kUINormaAlpha;
}

- (void)stylizeProgressViewWithColor: (UIColor *)color {
    self.layer.cornerRadius = 3.0f;
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.layer.shadowOpacity = kShadowOpacity;
    self.alpha = kOne;
    self.backgroundColor = color;
}

- (void)stylizePinView {
    UIImage *pinImageView = [UIImage imageNamed:@"Pin.png"];
    self.layer.contents = (__bridge id)pinImageView.CGImage;
    self.layer.contentsGravity = kCAGravityResizeAspect;
    self.layer.shadowOffset = CGSizeMake(-1.0, 4.0);
    self.layer.shadowOpacity = kShadowOpacity;
}

@end
