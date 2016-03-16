//
//  ROADNoteBookImageEditingTool.h
//  Road
//
//  Created by Li Pan on 2016-03-13.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ROADNoteBookImageEditingTool : UIView
@property (nonatomic, strong) UIScrollView *filterGallery;
@property (nonatomic, strong) UIScrollView *adjustmentsGallery;
@property (nonatomic, strong) UISlider *imageAdjustmentSlider;
@property (nonatomic, assign) float sliderAdjustmentValue;

- (void) setupImageView;

@end
