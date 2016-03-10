//
//  UIButton+Stylizer.m
//  Road
//
//  Created by Li Pan on 2016-03-05.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "UIButton+Stylizer.h"
#import "ROADConstants.h"

@implementation UIButton (Stylizer)

- (void)stylizePageBottomToggleButtons {
    self.layer.borderWidth = kBoarderWidth;
    self.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.layer.shadowOpacity = kShadowOpacity;
    self.layer.cornerRadius = self.frame.size.height/2;
    self.alpha = kUINormaAlpha;
    self.layer.contentsGravity = kCAGravityResizeAspect;
}

- (void)stylizePauseMenuButton {
    self.layer.borderWidth = kBoarderWidth;
    self.layer.contentsGravity = kCAGravityResizeAspect;
    self.alpha = kZero;
    self.layer.cornerRadius = self.frame.size.width/2;
}



@end
