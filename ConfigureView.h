//
//  ConfigureView.h
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ROADConstants.h"


@interface ConfigureView : NSObject

+ (void)configureReadingTextLabel: (UILabel *)label alpha:(float)alpha;
+ (void)configureTrapezoidButton: (UIButton *)button title:(NSString *)title font: (NSString *)font;
+ (void)configureCircleButton:(UIButton *)button title:(NSString *)title;
+ (void)modifyTextWithString: (NSString *)characterSetString color: (UIColor *)color toString: (NSString *)string;
+ (void)modifyTextWithString: (NSString *)characterSetString color: (UIColor *)color toLabel: (UILabel *)label;
+ (void)highlighPunctuationWithColor: (UIColor *)color toLabel: (UILabel *)label;




@end
