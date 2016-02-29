//
//  ROADCurrentReadingPosition.h
//  Road
//
//  Created by Li Pan on 2016-02-28.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ROADCurrentReadingPosition : NSObject

@property (nonatomic, assign) NSInteger wordIndex;
@property (nonatomic, assign) float mainFontSize;
@property (nonatomic, assign) NSInteger assistantTextRangeIndex;
@property (nonatomic, assign) NSInteger assistantTextRangeLength;
@property (nonatomic, assign) BOOL xAxisFlipped;
@property (nonatomic, strong) UIColor *highlightVowelColor;
@property (nonatomic, strong) UIColor *highlightConsonantColor;
@property (nonatomic, strong) UIColor *highlightUserSelectedTextColor;
@property (nonatomic, strong) UIColor *highlightMovingTextColor;

@end
