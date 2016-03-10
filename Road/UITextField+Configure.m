//
//  UITextField+Configure.m
//  Road
//
//  Created by Li Pan on 2016-03-09.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "UITextField+Configure.h"

@implementation UITextField (Configure)

- (void)configureUserSelectedTextField {
    self.layer.borderWidth = kBoarderWidth/2;
    self.layer.borderColor = [UIColor colorWithWhite:kZero alpha:kUINormaAlpha].CGColor;
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0);
    self.layer.shadowOpacity = kShadowOpacity;
    self.placeholder = @"Customize";
    self.textAlignment = NSTextAlignmentCenter;
    self.autocorrectionType = NO;
    self.autocapitalizationType = NO;
    self.keyboardType = UIKeyboardTypeAlphabet;
    self.keyboardAppearance = UIKeyboardAppearanceDark;
    self.font = [UIFont fontWithName:(kFontType) size:kSmallFontSize];
    
}

@end
