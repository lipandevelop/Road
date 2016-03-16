//
//  FilterButton.m
//  Road
//
//  Created by Li Pan on 2016-03-13.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADNoteBookViewFilterButton.h"
#import "ROADConstants.h"

static const float kButtonDimension = 70.0f;
static const float kButtonMargin = 3.0f;


@implementation ROADNoteBookViewFilterButton

- (void)configureWithOrder: (float)order image: (UIImage *)image name: (NSString *)name {
    self.frame = CGRectMake((kButtonDimension * order) + kButtonMargin, kButtonMargin, kButtonDimension, kButtonDimension);
    self.layer.contents = (__bridge id)image.CGImage;
    self.layer.contentsGravity = kCAGravityResizeAspectFill;
    self.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.layer.shadowOpacity = 0.6f;
    [self setTitle:name forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:kZero alpha:kOne] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:kFontType size:12.0f];
    self.backgroundColor = [UIColor blackColor];
    self.alpha = kOne;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
