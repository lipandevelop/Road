//
//  ROADNoteBookFeatureButtonShapeLayer.m
//  Road
//
//  Created by Li Pan on 2016-03-16.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADNoteBookFeatureButtonShapeLayer.h"
#import <UIKit/UIKit.h>
#import "ROADConstants.h"

@implementation ROADNoteBookFeatureButtonShapeLayer

- (instancetype)init {
    self = [super init];
    if (self) {
        UIBezierPath *path = [[UIBezierPath alloc]init];
        [path moveToPoint:CGPointMake(kZero, kZero)];
        [path addLineToPoint:CGPointMake(55.0f, kZero)];
        [path addLineToPoint:CGPointMake(45.0, 25.0f)];
        [path addLineToPoint:CGPointMake(kZero, 25.0f)];
        [path closePath];
        self.path = path.CGPath;
        self.shadowOffset = CGSizeMake(-kOne, 6.0f);
        self.shadowOpacity = kShadowOpacity;
        self.borderWidth = kBorderWidth;
    }
    return self;
}

@end
