//
//  UIColorSelection.m
//  Road
//
//  Created by Li Pan on 2016-02-29.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "UIColorSelection.h"

typedef NS_ENUM(NSInteger, ModifyColorForTextActivated) {
    Vowels,
    Consonants,
    UserSelection,
};

@interface UIColorSelection ()
@property (nonatomic, assign) ModifyColorForTextActivated textColorBeingModified;

@end



@implementation UIColorSelection


//- (void)changeSelectedTextColor: (UIButton *)button toView: (UIView *)view consonantColor: (UIColor *)consonantColor userColorOne: (UIColor *)userColorOne {
//    
//    NSLog(@"buttonPressed %ld", (long)button.tag);
//    
//    UIButton *selectedButton = [view viewWithTag:button.tag];
//    [UIView animateWithDuration:0.50f animations:^{
//        selectedButton.alpha = 1.0f;
//        selectedButton.layer.affineTransform = CGAffineTransformScale(button.layer.affineTransform, 1.05f, 1.20f);
//        selectedButton.layer.shadowOpacity = 0.65f;
//        selectedButton.layer.zPosition = 1.0f;
//    } completion:^(BOOL finished) {
//        selectedButton.tag = -1;
//    }];
//    switch (button.tag) {
//        case 1:
//            switch (self.textColorBeingModified) {
//                case Consonants:
//                    consonantColor = userColorOne;
//                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorOne;
//                    break;
//                case Vowels:
//                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorOne;
//                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorOne;
//                    break;
//                case UserSelection:
//                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorOne;
//                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorOne;
//                    break;
//                default:
//                    break;
//            }
//            break;
//        case 2:
//            switch (self.textColorBeingModified) {
//                case Consonants:
//                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorTwo;
//                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorTwo;
//                    break;
//                case Vowels:
//                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorTwo;
//                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorTwo;
//                    break;
//                case UserSelection:
//                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorTwo;
//                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorTwo;
//                    break;
//                default:
//                    break;
//            }
//            break;
//        case 3:
//            switch (self.textColorBeingModified) {
//                case Consonants:
//                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorThree;
//                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorThree;
//                    break;
//                case Vowels:
//                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorThree;
//                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorThree;
//                    break;
//                case UserSelection:
//                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorThree;
//                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorThree;
//                    break;
//                default:
//                    break;
//            }
//            break;
//        case 4:
//            switch (self.textColorBeingModified) {
//                case Consonants:
//                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorFour;
//                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorFour;
//                    break;
//                case Vowels:
//                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorFour;
//                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorFour;
//                    break;
//                case UserSelection:
//                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorFour;
//                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorFour;
//                    break;
//                default:
//                    break;
//            }
//            break;
//        case 5:
//            switch (self.textColorBeingModified) {
//                case Consonants:
//                    self.currentReadingPosition.highlightConsonantColor = self.userColor.colorFive;
//                    self.userInteractionTools.toggleConsonates.backgroundColor = self.userColor.colorFive;
//                    break;
//                case Vowels:
//                    self.currentReadingPosition.highlightVowelColor = self.userColor.colorFive;
//                    self.userInteractionTools.toggleVowels.backgroundColor = self.userColor.colorFive;
//                    break;
//                case UserSelection:
//                    self.currentReadingPosition.highlightUserSelectedTextColor = self.userColor.colorFive;
//                    self.userInteractionTools.toggleUserSelections.backgroundColor = self.userColor.colorFive;
//                    break;
//                default:
//                    break;
//            }
//            break;
//            
//        default:
//            break;
//    }
//}

@end
