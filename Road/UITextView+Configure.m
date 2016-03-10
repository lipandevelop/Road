//
//  UITextView+Configure.m
//  Road
//
//  Created by Li Pan on 2016-03-10.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "UITextView+Configure.h"
#import "ROADConstants.h"

@implementation UITextView (Configure)

- (void)configureAssistantTextViewWithTextColor: (UIColor *)color displayString: (NSString *)string {
    self.text = string;
    self.textColor = color;
    self.layer.zPosition = 0.9;
    self.backgroundColor = [UIColor colorWithWhite:kOne alpha:kZero];
    self.alpha = kOne;
    self.editable = NO;
}

@end
