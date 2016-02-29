//
//  ROADDrawToolView.h
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ROADDrawToolView : UIView
@property (nonatomic, strong) UIColor *currentColor;
@property (nonatomic, assign) CGPoint gesturePoints;
@property (nonatomic, assign) CGPoint gestureDrags;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, assign) double velocity;

@end
