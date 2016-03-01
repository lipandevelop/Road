//
//  ROADNoneInteractiveViews.h
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ROADNoneInteractiveViews : UIView
@property (nonatomic, strong) UILabel *dot;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UIView *progress;
@property (nonatomic, strong) UIView *speedometerView;
@property (nonatomic, strong) UIView *pinView;

@property (nonatomic, strong) UILabel *focusText;
@property (nonatomic, strong) UILabel *previousWord3;
@property (nonatomic, strong) UILabel *previousWord2;
@property (nonatomic, strong) UILabel *previousWord;
@property (nonatomic, strong) UILabel *nextWord;
@property (nonatomic, strong) UILabel *nextWord2;
@property (nonatomic, strong) UILabel *nextWord3;
@property (nonatomic, strong) UILabel *nextWord4;
@property (nonatomic, strong) UILabel *dividerLabel;

@property (nonatomic, strong) UILabel *speedLabel;
@property (nonatomic, strong) UILabel *speedometerReadLabel;

@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UILabel *averageSpeedLabel;


@property (nonatomic, strong) UILabel *focusFontSizeLabel;

@end
