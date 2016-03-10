//
//  UIButton+Stylizer.h
//  Road
//
//  Created by Li Pan on 2016-03-05.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Stylizer)

- (void)stylizePageBottomToggleButtons;
- (void)stylizePauseMenuButtons;
- (void)stylizeAccessButtons;
- (void)stylizePaletteButtonsWithYOrigin: (float)y backgroundColor: (UIColor *)color;
- (void)stylizeHideControlsButton;
- (void)stylizeOpenSpeedometerDetailButton;
- (void)stylizeTimeElapsedLabelWithColor: (UIColor *)color;




@end
