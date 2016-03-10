//
//  UISlider+Configure.m
//  Road
//
//  Created by Li Pan on 2016-03-10.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "UISlider+Configure.h"
#import "ROADConstants.h"

@implementation UISlider (Configure)

- (void)configureSpeedSliderWithTintColor: (UIColor *)color maximum: (float)max minimum: (float)min value: (float)value {
    self.layer.affineTransform = CGAffineTransformTranslate(self.layer.affineTransform, 10.0f, 40.0f);
    self.tintColor = color;
    self.alpha = kUINormaAlpha;
    self.maximumValue = max;
    self.minimumValue = min;
    self.value = value;
}

- (void)configureFontSizeSliderWithTintColor: (UIColor *)color value: (float)value {
    self.tintColor = color;
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0);
    self.layer.shadowOpacity = 0.10f;
    self.value = value;
    self.maximumValue = 32.0f;
    self.minimumValue = 20.0f;
}


@end
