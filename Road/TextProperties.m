//
//  Text.m
//  Road
//
//  Created by Li Pan on 2016-02-25.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "TextProperties.h"

@implementation TextProperties
- (instancetype)initWithWordCount: (NSInteger)wordCount wordLocation:(NSInteger)wordLocation length: (NSInteger)wordLength text: (NSString *)text {
    self = [super init];
    if (self) {
        _wordCount = wordCount;
        _wordLocation = wordLocation;
        _length = wordLength;
        _text = text;

    }
    return self;
}


@end
