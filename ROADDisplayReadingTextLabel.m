//
//  ROADDisplayReadingTextLabel.m
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADDisplayReadingTextLabel.h"
#import "ROADConstants.h"

@implementation ROADDisplayReadingTextLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.numberOfLines = kZero;
        self.textColor = [UIColor blackColor];
        self.alpha = kUINormaAlpha;
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end
