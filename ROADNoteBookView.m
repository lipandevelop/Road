//
//  ROADNoteBookView.m
//  Road
//
//  Created by Li Pan on 2016-03-01.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADNoteBookView.h"
#import "ROADConstants.h"
#import "ROADNoteBookDrawTool.h"
#import "ROADNoteBookImageEditingTool.h"
#import "ROADNoteBookFeatureButtonShapeLayer.h"
#import "ROADColors.h"

@interface ROADNoteBookView ()
@property (nonatomic, strong) UIView *canvasView;
@property (nonatomic, strong) ROADNoteBookDrawTool *drawToolView;
@property (nonatomic, strong) ROADNoteBookImageEditingTool *imageEditingToolView;

@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UIButton *pencilButton;
@property (nonatomic, strong) UIButton *pictureButton;
@property (nonatomic, strong) UIButton *exportButton;

@property (nonatomic, strong) UIButton *toggleImageFilterOptions;
@property (nonatomic, strong) UIButton *toggleImageAdjustmentOptions;

@property (nonatomic, strong) UIButton *shareInstagramButton;
@property (nonatomic, strong) UIButton *shareFacebookButton;
@property (nonatomic, strong) UIButton *shareTwitterButton;
@property (nonatomic, strong) UIView *shareButtonsContainer;

@property (nonatomic, strong) ROADColors *userColors;
@property (nonatomic, assign) BOOL drawingToolActivated;
@property (nonatomic, assign) BOOL imageViewActivated;
@property (nonatomic, assign) BOOL shareViewActivated;
@property (nonatomic, assign) BOOL imageFilterActivated;
@property (nonatomic, assign) BOOL imageAdjustmentActivated;

@property (nonatomic, strong) UILabel *notesLabel;

@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation ROADNoteBookView

static const float kFilterAdjustmentBarBottomOffset = 90.0f;
static const float kFilterAdjustmentSliderBottomOffset = 30.0f;
static const float kAdjustmentSliderWidth = 200.0f;
static const float kAdjustmentSliderWidthWithOffset = 205.0f;
static const float kAdjustmentSliderHeight = 20.0f;
static const float kadjustmentsGalleryHeight = 51.0f;

static const float kButtonXOriginOffset = 20.0f;
static const float kButtonMaxYOffset = 10.0f;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Notes %@", self.arrayOfNotes);
    
    self.drawingToolActivated = NO;
    self.imageViewActivated = NO;
    self.shareViewActivated = NO;
    self.imageFilterActivated = NO;
    self.imageAdjustmentActivated = NO;
    
    self.userColors = [[ROADColors alloc]init];
    UIView *backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    UIImage *ivoryPaper = [UIImage imageNamed:@"ivoryPaper.png"];
    UIImage *pencilImage = [UIImage imageNamed:@"drawingPencil"];
    UIImage *imageImage = [UIImage imageNamed:@"imageIcon"];
    UIImage *shareImage = [UIImage imageNamed:@"share.png"];
    
    UIImage *instagrameIconImage = [UIImage imageNamed:@"instagramIcon"];
    UIImage *facebookIconImage = [UIImage imageNamed:@"faceBookIcon"];
    UIImage *twitterIconImage = [UIImage imageNamed:@"twitterIcon"];
    backgroundView.layer.contents = (__bridge id)ivoryPaper.CGImage;
    [self.view addSubview:backgroundView];
    
    self.returnButton = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight)];
    //    [self.returnButton.layer addSublayer:[[ROADNoteBookFeatureButtonShapeLayer alloc]init]];
    //    self.returnButton.backgroundColor = self.userColors.colorFive;
    [self.returnButton setTitle:@"<" forState:UIControlStateNormal];
    [self.returnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.returnButton addTarget:self action:@selector(backtoBook:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pencilButton = [[UIButton alloc]initWithFrame:CGRectMake(65.0f, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight)];
    //    self.pencilButton.backgroundColor = self.userColors.colorFive;
    //    [self.pencilButton.layer addSublayer:[[ROADNoteBookFeatureButtonShapeLayer alloc]init]];
    self.pencilButton.alpha = kUINormaAlpha;
    self.pencilButton.layer.contents = (__bridge id)pencilImage.CGImage;
    [self.pencilButton addTarget:self action:@selector(toggleDrawingTool:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pictureButton = [[UIButton alloc]initWithFrame:CGRectMake(120.0f, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight)];
    self.pictureButton.alpha = kUINormaAlpha;
    //    self.pictureButton.backgroundColor = self.userColors.colorFive;
    //    [self.pictureButton.layer addSublayer:[[ROADNoteBookFeatureButtonShapeLayer alloc]init]];
    self.pictureButton.layer.contents = (__bridge id)imageImage.CGImage;
    [self.pictureButton addTarget:self action:@selector(toggleImageView:) forControlEvents:UIControlEventTouchUpInside];
    
    self.exportButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight)];
    self.exportButton.layer.borderWidth = kBorderWidth;
    self.exportButton.layer.contents = (__bridge id)shareImage.CGImage;
    self.exportButton.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.exportButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.exportButton.layer.shadowOpacity = kShadowOpacity;
    self.exportButton.alpha = kUINormaAlpha;
    [self.exportButton addTarget:self action:@selector(toggleShareView:) forControlEvents:UIControlEventTouchUpInside];
    
    self.shareButtonsContainer = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kButtonMaxYOffset, kAccessButtonHeight, kZero)];
    self.shareButtonsContainer.backgroundColor = [UIColor whiteColor];
    self.shareButtonsContainer.layer.borderWidth = kBorderWidth;
    self.shareButtonsContainer.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.shareButtonsContainer.layer.cornerRadius = kAccessButtonHeight/2;
    self.shareButtonsContainer.layer.shadowOpacity = kShadowOpacity;
    
    self.shareInstagramButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight)];
    self.shareInstagramButton.layer.borderWidth = kBorderWidth;
    self.shareInstagramButton.layer.contents = (__bridge id)instagrameIconImage.CGImage;
    self.shareInstagramButton.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.shareInstagramButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.shareInstagramButton.layer.shadowOpacity = kShadowOpacity;
    self.shareInstagramButton.alpha = kUINormaAlpha;
    
    self.shareFacebookButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight)];
    self.shareFacebookButton.layer.borderWidth = kBorderWidth;
    self.shareFacebookButton.layer.contents = (__bridge id)facebookIconImage.CGImage;
    self.shareFacebookButton.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.shareFacebookButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.shareFacebookButton.layer.shadowOpacity = kShadowOpacity;
    self.shareFacebookButton.alpha = kUINormaAlpha;
    
    self.shareTwitterButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight)];
    self.shareTwitterButton.layer.borderWidth = kBorderWidth;
    self.shareTwitterButton.layer.contents = (__bridge id)twitterIconImage.CGImage;
    self.shareTwitterButton.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.shareTwitterButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.shareTwitterButton.layer.shadowOpacity = kShadowOpacity;
    self.shareTwitterButton.alpha = kUINormaAlpha;
    
    self.shareInstagramButton.alpha = kZero;
    self.shareFacebookButton.alpha = kZero;
    self.shareTwitterButton.alpha = kZero;
    
    self.canvasView = [[UIView alloc]initWithFrame:CGRectMake(kButtonXOriginOffset, kButtonXOriginOffset, CGRectGetWidth(self.view.frame)-40, CGRectGetHeight(self.view.frame)-80)];
    self.canvasView.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
    self.canvasView.layer.borderWidth = kBorderWidth;
    self.canvasView.layer.borderColor = self.userColors.colorSix.CGColor;
    self.canvasView.layer.shadowOpacity = kShadowOpacity;
    self.canvasView.clipsToBounds = YES;
    
    [self setDrawingTool];
    [self setImageEditingTool];
    [self.imageEditingToolView setupImageView];
    
    [self.view addSubview:self.canvasView];
    [self.view addSubview:self.shareButtonsContainer];
    [self.canvasView addSubview:self.imageEditingToolView];
    [self.canvasView addSubview:self.drawToolView];
    [self.view addSubview:self.returnButton];
    [self.view addSubview:self.pencilButton];
    [self.view addSubview:self.pictureButton];
    [self.view addSubview:self.exportButton];
    [self.view bringSubviewToFront:self.notesLabel];
    
    [self displayNotes];
}

- (void)backtoBook: (UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleDrawingTool: (UIButton *)sender {
    self.drawingToolActivated = !self.drawingToolActivated;
    if (self.drawingToolActivated) {
        self.imageEditingToolView.userInteractionEnabled = NO;
        self.drawToolView.layer.zPosition = kOne;
        [UIView animateWithDuration:0.20f animations:^{
            self.drawToolView.alpha = kOne;
        }];
        [UIView animateWithDuration:kOne animations:^{
            self.pencilButton.alpha = kOne;
        }];
    }
    if (!self.drawingToolActivated) {
        self.imageEditingToolView.userInteractionEnabled = YES;
        self.drawToolView.layer.zPosition = -kOne;
        [UIView animateWithDuration:0.20f animations:^{
            self.drawToolView.alpha = kZero;
        }];
        [UIView animateWithDuration:kOne animations:^{
            self.pencilButton.layer.opacity = kUINormaAlpha;
        }];
    }
    NSLog(@"%d", self.drawingToolActivated);
}

- (void)toggleImageView: (UIButton *)sender {
    self.imageViewActivated = !self.imageViewActivated;
    self.imageEditingToolView.imageAdjustmentSlider.alpha = kZero;
    self.imageEditingToolView.imageAdjustmentSlider.tintColor = self.userColors.colorOne;
    if (self.imageViewActivated) {
        self.imageEditingToolView.userInteractionEnabled = YES;
        self.toggleImageFilterOptions = [[UIButton alloc]initWithFrame:CGRectMake(170.0f, self.view.frame.size.height - kToggleButtonDimension - 10.0f, kToggleButtonDimension, kToggleButtonDimension)];
        [self.toggleImageFilterOptions setTitle:@"Ftr" forState:UIControlStateNormal];
        self.toggleImageFilterOptions.titleLabel.font = [UIFont fontWithName:kFontType size:12.0f];
        self.toggleImageFilterOptions.backgroundColor = self.userColors.colorSix;
        self.toggleImageFilterOptions.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
        self.toggleImageFilterOptions.layer.shadowOpacity = kShadowOpacity;
        self.toggleImageFilterOptions.layer.cornerRadius = kToggleButtonDimension/2;
        self.toggleImageFilterOptions.alpha = kZero;
        [self.toggleImageFilterOptions addTarget:self action:@selector(toggleImageFilterBar:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.toggleImageFilterOptions];
        
        self.toggleImageAdjustmentOptions = [[UIButton alloc]initWithFrame:CGRectMake(210.0f, self.view.frame.size.height - kToggleButtonDimension - 10.0f, kToggleButtonDimension, kToggleButtonDimension)];
        [self.toggleImageAdjustmentOptions setTitle:@"Adj" forState:UIControlStateNormal];
        self.toggleImageAdjustmentOptions.backgroundColor = self.userColors.colorSix;
        self.toggleImageAdjustmentOptions.titleLabel.font = [UIFont fontWithName:kFontType size:12.0f];
        self.toggleImageAdjustmentOptions.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
        self.toggleImageAdjustmentOptions.layer.shadowOpacity = kShadowOpacity;
        self.toggleImageAdjustmentOptions.layer.cornerRadius = kToggleButtonDimension/2;
        self.toggleImageAdjustmentOptions.alpha = kZero;
        [self.toggleImageAdjustmentOptions addTarget:self action:@selector(toggleImageAdjustmentBar:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.toggleImageAdjustmentOptions];
        
        [UIView animateWithDuration:1.0f animations:^{
            self.pictureButton.alpha = kOne;
            self.imageEditingToolView.alpha = kOne;
            self.toggleImageFilterOptions.alpha = kUINormaAlpha;
            self.toggleImageAdjustmentOptions.alpha = kUINormaAlpha;
        }];
    }
    if (!self.imageViewActivated) {
        self.imageEditingToolView.userInteractionEnabled = NO;
        [UIView animateWithDuration:1.0f animations:^{
            self.pictureButton.alpha = kUINormaAlpha;
            self.imageEditingToolView.alpha = kZero;
            self.toggleImageFilterOptions.alpha = kZero;
            self.toggleImageAdjustmentOptions.alpha = kZero;
        }];
    }
}

- (void)setDrawingTool {
    self.drawToolView = [[ROADNoteBookDrawTool alloc] initWithFrame:self.canvasView.bounds];
    self.drawToolView.currentColor = self.userColors.colorFive;
    self.drawToolView.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:47.0/255.0 blue:64.0/255.0 alpha:0.01];
    self.drawToolView.userInteractionEnabled = YES;
    self.drawToolView.alpha = kZero;
}

- (void)setImageEditingTool {
    self.imageEditingToolView = [[ROADNoteBookImageEditingTool alloc]init];
    self.imageEditingToolView.frame = CGRectMake(0, 0, self.canvasView.frame.size.width, self.canvasView.frame.size.height);
    self.imageEditingToolView.userInteractionEnabled = YES;
    self.imageEditingToolView.backgroundColor = [UIColor blackColor];
}

- (void)displayNotes {
    int indexCount = 1;
    for (NSString *notesString in self.arrayOfNotes) {
        //        indexCount++;
        //        UILabel *notesLabel = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 40.0f + indexCount*40.0f, 400.0f, 200.0f)];
        //        notesLabel.text = notesString;
        //        notesLabel.textColor = self.userColors.colorSix;
        //        notesLabel.font = [UIFont fontWithName:@"American Typewriter" size:13.0f];
        //        [self.imageView addSubview:notesLabel];
        indexCount ++;
        self.notesLabel = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 40.0f + indexCount*40.0f, 200.0f, 100.0f)];
        self.notesLabel.text = notesString;
        self.notesLabel.textColor = self.userColors.colorSix;
        self.notesLabel.numberOfLines = kZero;
        self.notesLabel.textAlignment = NSTextAlignmentCenter;
        self.notesLabel.font = [UIFont fontWithName:@"American Typewriter" size:18.0f];
        [self.canvasView addSubview:self.notesLabel];
    }
}

- (void)toggleShareView: (UIButton *)sender {
    self.shareViewActivated = !self.shareViewActivated;
    if (self.shareViewActivated) {
        [self.view addSubview:self.shareInstagramButton];
        [self.view addSubview:self.shareFacebookButton];
        [self.view addSubview:self.shareTwitterButton];
        
        [UIView animateWithDuration:0.75f animations:^{
            self.exportButton.alpha = kOne;
            
            self.shareInstagramButton.alpha = kOne;
            self.shareFacebookButton.alpha = kOne;
            self.shareTwitterButton.alpha = kOne;
            
            self.shareButtonsContainer.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - 4*kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, 4*kAccessButtonHeight-5);
            
            self.shareFacebookButton.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - 3* kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight);
            
            self.shareTwitterButton.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - 4* kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight);
            
            self.shareInstagramButton.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - 2* kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight);
        }];
    }
    if (!self.shareViewActivated) {
        [UIView animateWithDuration:1.5 animations:^{
            self.exportButton.alpha = kUINormaAlpha;
            self.shareInstagramButton.alpha = kZero;
            self.shareFacebookButton.alpha = kZero;
            self.shareTwitterButton.alpha = kZero;
            
            self.shareButtonsContainer.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kButtonMaxYOffset, kAccessButtonHeight, kZero);
            
            self.shareFacebookButton.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight);
            
            self.shareTwitterButton.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight);
            
            self.shareInstagramButton.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - kButtonXOriginOffset - kAccessButtonHeight, self.view.frame.size.height - kAccessButtonHeight - kButtonMaxYOffset, kAccessButtonHeight, kAccessButtonHeight);
        }completion:^(BOOL finished) {
            [self.shareInstagramButton removeFromSuperview];
            [self.shareFacebookButton removeFromSuperview];
            [self.shareTwitterButton removeFromSuperview];
        }];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchLabelPoint = [[touches anyObject] locationInView:self.canvasView];
    self.notesLabel.center = touchLabelPoint;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)toggleImageFilterBar: (UIButton *)sender {
    self.imageFilterActivated = !self.imageFilterActivated;
    if (self.imageFilterActivated) {
        self.toggleImageAdjustmentOptions.enabled = NO;
        self.imageEditingToolView.filterGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentBarBottomOffset, kZero, 2.0f);
        [UIView animateWithDuration:0.5f animations:^{
            self.imageEditingToolView.filterGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentBarBottomOffset, self.imageEditingToolView.frame.size.width, 2.0f);
            self.toggleImageFilterOptions.alpha = kOne;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.imageEditingToolView.filterGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentBarBottomOffset, self.imageEditingToolView.frame.size.width, kadjustmentsGalleryHeight);
            }];
        }];
    }
    if (!self.imageFilterActivated) {
        self.toggleImageAdjustmentOptions.enabled = YES;
        self.imageEditingToolView.filterGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame)- kFilterAdjustmentBarBottomOffset, self.imageEditingToolView.frame.size.width, kadjustmentsGalleryHeight);
        [UIView animateWithDuration:0.5f animations:^{
            self.imageEditingToolView.filterGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentBarBottomOffset, self.imageEditingToolView.frame.size.width, 2.0f);
            self.toggleImageFilterOptions.alpha = kUINormaAlpha;
            
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.imageEditingToolView.filterGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame)- kFilterAdjustmentBarBottomOffset, kZero, 2.0f);
            }];
        }];
    }
}

- (void)toggleImageAdjustmentBar: (UIButton *)sender {
    self.imageAdjustmentActivated = !self.imageAdjustmentActivated;
    if (self.imageAdjustmentActivated) {
        self.toggleImageFilterOptions.enabled = NO;
        self.imageEditingToolView.adjustmentsGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentBarBottomOffset, kZero, 2.0f);
        self.imageEditingToolView.imageAdjustmentSlider.frame = CGRectMake(self.imageEditingToolView.frame.size.width - kAdjustmentSliderWidthWithOffset, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentSliderBottomOffset, kZero, kAdjustmentSliderHeight);
        self.imageEditingToolView.imageAdjustmentSlider.alpha = kZero;
        
        [UIView animateWithDuration:0.5f animations:^{
            self.imageEditingToolView.adjustmentsGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame)- kFilterAdjustmentBarBottomOffset, self.imageEditingToolView.frame.size.width, 2.0f);
            self.imageEditingToolView.imageAdjustmentSlider.alpha = kOne;
            self.toggleImageAdjustmentOptions.alpha = kOne;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.imageEditingToolView.adjustmentsGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentBarBottomOffset, self.imageEditingToolView.frame.size.width, kadjustmentsGalleryHeight);
                self.imageEditingToolView.imageAdjustmentSlider.frame = CGRectMake(self.imageEditingToolView.frame.size.width - kAdjustmentSliderWidthWithOffset, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentSliderBottomOffset, kAdjustmentSliderWidth, kAdjustmentSliderHeight);
            }];
        }];
    }
    if (!self.imageAdjustmentActivated) {
        self.toggleImageFilterOptions.enabled = YES;
        self.imageEditingToolView.adjustmentsGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame)- kFilterAdjustmentBarBottomOffset, self.imageEditingToolView.frame.size.width, kadjustmentsGalleryHeight);
        self.imageEditingToolView.imageAdjustmentSlider.frame = CGRectMake(self.imageEditingToolView.frame.size.width - kAdjustmentSliderWidthWithOffset, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentSliderBottomOffset, kAdjustmentSliderWidth, kAdjustmentSliderHeight);
        self.imageEditingToolView.imageAdjustmentSlider.alpha = kOne;
        [UIView animateWithDuration:0.5f animations:^{
            self.imageEditingToolView.adjustmentsGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentBarBottomOffset, self.imageEditingToolView.frame.size.width, 2.0f);
            self.toggleImageAdjustmentOptions.alpha = kUINormaAlpha;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5f animations:^{
                self.imageEditingToolView.adjustmentsGallery.frame = CGRectMake(kZero, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentBarBottomOffset, kZero, 2.0f);
                self.imageEditingToolView.imageAdjustmentSlider.frame = CGRectMake(self.imageEditingToolView.frame.size.width - kAdjustmentSliderWidthWithOffset, CGRectGetMaxY(self.imageEditingToolView.frame) - kFilterAdjustmentSliderBottomOffset, kZero, kAdjustmentSliderHeight);
                self.imageEditingToolView.imageAdjustmentSlider.alpha = kZero;
            }];
        }];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
