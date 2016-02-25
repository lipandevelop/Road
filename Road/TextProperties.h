//
//  Text.h
//  Road
//
//  Created by Li Pan on 2016-02-25.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextProperties : NSObject
@property (nonatomic, assign) NSInteger *characterLoaction;
@property (nonatomic, assign) NSInteger wordLocation;
@property (nonatomic, assign) NSInteger wordCount;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) NSString *text;

- (instancetype)initWithWordCount: (NSInteger)wordCount wordLocation:(NSInteger)wordLocation length: (NSInteger)wordLength text: (NSString *)text;

@end
