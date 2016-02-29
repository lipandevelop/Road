//
//  ROADDrawToolView.m
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADDrawToolView.h"

@implementation ROADDrawToolView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _path = [[UIBezierPath alloc] init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.path.lineCapStyle = kCGLineCapRound;
    self.path.lineJoinStyle = kCGLineCapRound;
    self.path.lineWidth = 3.50;
    [self.currentColor setStroke];
    [self.path stroke];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.gesturePoints = [[touches anyObject] locationInView:self];
    [self.path moveToPoint:self.gesturePoints];
    [self.path addLineToPoint:self.gesturePoints];
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.gestureDrags = [[touches anyObject] locationInView:self];
    [self.path addLineToPoint:self.gestureDrags];
    [self setNeedsDisplay];
    NSLog(@"%f", self.gestureDrags.x);
    NSLog(@"%f", self.gestureDrags.y);
}


@end
