//
//  ROADDictionary.m
//  Road
//
//  Created by Li Pan on 2016-02-27.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADDictionary.h"

@implementation ROADDictionary

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIImage *dictionaryBackgroundImage = [UIImage imageNamed:@"ivoryPaper"];
        CALayer *paperImageLayer = [[CALayer alloc]init];
        paperImageLayer.contents = (__bridge id)dictionaryBackgroundImage.CGImage;
        self.navigationController.navigationBar.hidden = YES;
        self.view.tintColor = [UIColor redColor];
        [self.view.layer addSublayer:paperImageLayer];
    }
    return self;
}

@end
