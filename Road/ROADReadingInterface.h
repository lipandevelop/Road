//
//  ViewController.h
//  Road
//
//  Created by Li Pan on 2016-02-19.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ROADReadingInterfaceDelegate <NSObject>
- (void)storeNote:(NSMutableArray *)notesArray;

@end

@interface ROADReadingInterface : UIViewController
@property (nonatomic, weak) id <ROADReadingInterfaceDelegate> delegate;


@end

