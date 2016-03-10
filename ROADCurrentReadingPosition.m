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
NSString * const kDotColor = @"kDotColor";
NSString * const kdefaultButtonColor = @"kdefaultButtonColor";


NSString * const kNormalSpeed = @"kNormalSpeed";
NSString * const kMaxSpeed = @"kMaxSpeed";
NSString * const kMinSpeed = @"kMinSpeed";
NSString * const kAcceleration = @"kAcceleration";
NSString * const kProgress = @"kProgress";

NSString * const kUserNotesArray = @"kUserNotesArray";
NSString * const kAverageReadingSpeed = @"kAverageReadingSpeed";



@implementation ROADCurrentReadingPosition

- (void) encodeWithCoder: (NSCoder *) coder {
//    [coder encodeInteger:self.wordIndex forKey:kWordIndexKey];
    [coder encodeFloat:self.mainFontSize forKey:kMainFontSize];
    [coder encodeInteger:self.assistantTextRangeIndex forKey:kAssistantTextRangeIndex];
    [coder encodeInteger:self.assistantTextRangeLength forKey:kAssistantTextRangeLength];
    [coder encodeBool:self.xAxisFlipped forKey:kXAxisFlipped];
    [coder encodeObject:self.highlightVowelColor forKey:kHighlightVowelColor];
    [coder encodeObject:self.highlightConsonantColor forKey:kHighlightConsonantColor];
    [coder encodeObject:self.highlightUserSelectedTextColor forKey:kHighlightUserSelectedTextColor];
    [coder encodeObject:self.highlightMovingTextColor forKey:kHighlightMovingTextColor];
    [coder encodeObject:self.dotColor forKey:kDotColor];
    [coder encodeObject:self.defaultButtonColor forKey:kdefaultButtonColor];
    
    [coder encodeFloat:self.normalSpeed forKey:kNormalSpeed];
    [coder encodeFloat:self.maxSpeed forKey:kMaxSpeed];
    [coder encodeFloat:self.minSpeed forKey:kMinSpeed];
    [coder encodeFloat:self.acceleration forKey:kAcceleration];
    [coder encodeFloat:self.progress forKey:kProgress];
    [coder encodeFloat:self.averageReadingSpeed forKey:kAverageReadingSpeed];

    
    [coder encodeObject:self.userNotesArray forKey:kUserNotesArray];
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [self init];
    
//    self.wordIndex = [coder decodeIntegerForKey:kWordIndexKey];
    self.mainFontSize = [coder decodeFloatForKey:kMainFontSize];
    self.assistantTextRangeIndex = [coder decodeIntegerForKey:kAssistantTextRangeIndex];
    self.assistantTextRangeLength = [coder decodeIntegerForKey:kAssistantTextRangeLength];
    self.xAxisFlipped = [coder decodeBoolForKey:kXAxisFlipped];
    self.highlightVowelColor = [coder decodeObjectForKey:kHighlightVowelColor];
    self.highlightConsonantColor = [coder decodeObjectForKey:kHighlightConsonantColor];
    self.highlightUserSelectedTextColor = [coder decodeObjectForKey:kHighlightUserSelectedTextColor];
    self.highlightMovingTextColor = [coder decodeObjectForKey:kHighlightMovingTextColor];
    self.dotColor = [coder decodeObjectForKey:kDotColor];
    self.defaultButtonColor = [coder decodeObjectForKey:kdefaultButtonColor];
    
    
    self.normalSpeed = [coder decodeFloatForKey:kNormalSpeed];
    self.maxSpeed = [coder decodeFloatForKey:kMaxSpeed];
    self.minSpeed = [coder decodeFloatForKey:kMinSpeed];
    self.acceleration = [coder decodeFloatForKey:kAcceleration];
    self.progress = [coder decodeFloatForKey:kProgress];
    self.averageReadingSpeed = [coder decodeFloatForKey:kAverageReadingSpeed];

    self.userNotesArray = [coder decodeObjectForKey:kProgress];



    
    return self;
}


@end

