//
//  ROADCurrentReadingPosition.m
//  Road
//
//  Created by Li Pan on 2016-02-28.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADCurrentReadingPosition.h"

NSString * const kWordIndexKey = @"kWordIndexKey";
NSString * const kMainFontSize = @"kMainFontSize";
NSString * const kAssistantTextRangeIndex = @"kAssistantTextRangeIndex";
NSString * const kAssistantTextRangeLength = @"kAssistantTextRangeLength";
NSString * const kXAxisFlipped = @"kXAxisFlipped";
NSString * const kHighlightVowelColor = @"kHighlightVowelColor";
NSString * const kHighlightConsonantColor = @"kHighlightConsonantColor";
NSString * const kHighlightUserSelectedTextColor = @"kHighlightUserSelectedTextColor";
NSString * const kHighlightMovingTextColor = @"kHighlightMovingTextColor";

@implementation ROADCurrentReadingPosition

- (void) encodeWithCoder: (NSCoder *) coder {
    [coder encodeInteger:self.wordIndex forKey:kWordIndexKey];
    [coder encodeFloat:self.mainFontSize forKey:kMainFontSize];
    [coder encodeInteger:self.assistantTextRangeIndex forKey:kAssistantTextRangeIndex];
    [coder encodeInteger:self.assistantTextRangeLength forKey:kAssistantTextRangeLength];
    [coder encodeBool:self.xAxisFlipped forKey:kXAxisFlipped];
    [coder encodeObject:self.highlightVowelColor forKey:kHighlightVowelColor];
    [coder encodeObject:self.highlightConsonantColor forKey:kHighlightConsonantColor];
    [coder encodeObject:self.highlightUserSelectedTextColor forKey:kHighlightUserSelectedTextColor];
    [coder encodeObject:self.highlightMovingTextColor forKey:kHighlightMovingTextColor];
    
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [self init];
    
    self.wordIndex = [coder decodeIntegerForKey:kWordIndexKey];
    self.mainFontSize = [coder decodeFloatForKey:kMainFontSize];
    self.assistantTextRangeIndex = [coder decodeIntegerForKey:kAssistantTextRangeIndex];
    self.assistantTextRangeLength = [coder decodeIntegerForKey:kAssistantTextRangeLength];
    self.xAxisFlipped = [coder decodeBoolForKey:kXAxisFlipped];
    self.highlightVowelColor = [coder decodeObjectForKey:kHighlightVowelColor];
    self.highlightConsonantColor = [coder decodeObjectForKey:kHighlightConsonantColor];
    self.highlightUserSelectedTextColor = [coder decodeObjectForKey:kHighlightUserSelectedTextColor];
    self.highlightMovingTextColor = [coder decodeObjectForKey:kHighlightMovingTextColor];
    
    return self;
}


@end

