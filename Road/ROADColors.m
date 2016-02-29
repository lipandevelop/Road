//
//  ROADColors.m
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADColors.h"

@implementation ROADColors

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dotColor = [UIColor colorWithRed:195.0f/255.0f green:25.0f/255.0f blue:25.0f/255.0f alpha:1.0f];
        _colorOne = [UIColor colorWithRed:254.0f/255.0f green:82.0f/255.0f blue:15.0f/255.0f alpha:1.0f];
        _colorTwo = [UIColor colorWithRed:136.0f/255.0f green:14.0f/255.0f blue:79.0f/255.0f alpha:1.0f];
        _colorThree = [UIColor colorWithRed:11.0f/255.0f green:73.0f/255.0f blue:119.0f/255.0f alpha:1.0f];
        _colorFour = [UIColor colorWithRed:71.0f/255.0f green:215.0f/255.0f blue:193.0f/255.0f alpha:1.0f];
        _colorFive = [UIColor colorWithRed:253.0f/255.0f green:196.0f/255.0f blue:2.0f/255.0f alpha:1.0f];
        _defaultButtonColor = [UIColor colorWithRed:98.0f/255.0f green:91.0f/255.0f blue:77.0f/255.0f alpha:0.8];
    }
    return self;
}

@end
