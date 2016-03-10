//
//  UISlider+Configure.h
//  Road
//
//  Created by Li Pan on 2016-03-10.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISlider (Configure)
- (void)configureSpeedSliderWithTintColor: (UIColor *)color maximum: (float)max minimum: (float)min value: (float)value;
- (void)configureFontSizeSliderWithTintColor: (UIColor *)color value: (float)value;

@end
