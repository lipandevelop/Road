//
//  UIButton+Stylizer.m
//  Road
//
//  Created by Li Pan on 2016-03-05.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "UIButton+Stylizer.h"
#import "ROADConstants.h"

@implementation UIButton (Stylizer)

- (void)stylizePageBottomToggleButtons {
    self.layer.borderWidth = kBorderWidth;
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.layer.shadowOpacity = kShadowOpacity;
    self.layer.cornerRadius = self.frame.size.height/2;
    self.alpha = kUINormaAlpha;
    self.layer.contentsGravity = kCAGravityResizeAspect;
}

- (void)stylizePauseMenuButtons {
    self.layer.borderWidth = kBorderWidth;
    self.layer.contentsGravity = kCAGravityResizeAspect;
    self.alpha = kZero;
    self.layer.cornerRadius = self.frame.size.width/2;
}

- (void)stylizeAccessButtons {
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.titleLabel.font = [UIFont fontWithName:(kFontType) size:14];
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    self.layer.shadowOpacity = kShadowOpacity;
    self.layer.contentsGravity = kCAGravityResizeAspect;
    self.alpha = kGoldenRatioMinusOne;
}

- (void)stylizePaletteButtonsWithYOrigin: (float)y backgroundColor: (UIColor *)color {
    self.frame = CGRectMake(kColorPaletteXOrigin, y, kColorPaletteWidth, kColorPaletteHeight);
    self.layer.shadowOffset = CGSizeMake(-1.0, 6.0);
    self.layer.shadowOpacity = kShadowOpacity;
    self.backgroundColor = color;
    
}



@end
