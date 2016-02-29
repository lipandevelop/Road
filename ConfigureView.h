//
//  ConfigureView.h
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ConfigureView : NSObject

+ (void)configureReadingTextLabel: (UILabel *)label alpha:(float)alpha;
+ (void)configureTrapezoidButton: (UIButton *)button title:(NSString *)title font: (NSString *)font;



@end
