//
//  ROADDisplayReadingTextLabel.h
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ROADDisplayReadingTextLabel : UILabel

@property (nonatomic, strong) UILabel *focusText;
@property (nonatomic, strong) UILabel *previousWord3;
@property (nonatomic, strong) UILabel *previousWord2;
@property (nonatomic, strong) UILabel *previousWord;
@property (nonatomic, strong) UILabel *nextWord;
@property (nonatomic, strong) UILabel *nextWord2;
@property (nonatomic, strong) UILabel *nextWord3;
@property (nonatomic, strong) UILabel *nextWord4;

@end
