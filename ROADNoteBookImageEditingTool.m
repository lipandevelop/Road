//
//  ROADNoteBookImageEditingTool.m
//  Road
//
//  Created by Li Pan on 2016-03-13.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADNoteBookImageEditingTool.h"
#import "ROADConstants.h"
#import "ROADNoteBookViewFilterButton.h"
#import <ImageFilters/ImageFilter.h>


typedef NS_ENUM(NSInteger, FilterSelected) {
    ModeDefault,
    ModeSepia,
    ModeInvert,
    ModeBlueMood,
    ModeErode,
    ModeSunKissed,
    ModeBlackAndWhite,
    ModePolarize,
    ModeMagicHour,
    ModeToyCamera,
    ModeEqualization,
    
    ModeVibrant,
    ModeColorize,
    ModeExposure,
    ModeBrightness,
    ModeContrast,
    ModeEdges,
    ModeGamma,
    
    ModeBlur,
    ModeSharpen,
    ModePosterize,
};

@interface ROADNoteBookImageEditingTool () <NGFilterProtocol>
@property (nonatomic, strong) ImageFilter *imageFilter;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, assign) FilterSelected mode;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *sepiaButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *invertButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *blueMoodButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *erodeButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *sunkissedButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *blackAndWhiteButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *polarizeButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *toycameraButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *equalizationButton;

@property (nonatomic, strong) ROADNoteBookViewFilterButton *blurButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *posterizeButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *sharpenButton;

@property (nonatomic, strong) ROADNoteBookViewFilterButton *vibrantButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *colorizeButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *brightnessButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *exposureButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *contrastButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *edgesButton;
@property (nonatomic, strong) ROADNoteBookViewFilterButton *gammaButton;


@property (nonatomic, strong) UIImage *blackAndWhiteButtonThumbnail;
@property (nonatomic, strong) UIImage *sharpifyButtonThumbnail;
@property (nonatomic, strong) UIImage *sepiaButtonThumbnail;
@property (nonatomic, strong) UIImage *invertButtonThumbnail;
@property (nonatomic, strong) UIImage *blueMoodButtonThumbnail;
@property (nonatomic, strong) UIImage *erodeButtonThumbnail;
@property (nonatomic, strong) UIImage *sunkissedButtonThumbnail;
@property (nonatomic, strong) UIImage *crossProcessButtonThumbnail;
@property (nonatomic, strong) UIImage *polarizeButtonThumbnail;
@property (nonatomic, strong) UIImage *magichourButtonThumbnail;
@property (nonatomic, strong) UIImage *toycameraButtonThumbnail;
@property (nonatomic, strong) UIImage *envyButtonThumbnail;
@property (nonatomic, strong) UIImage *equalizationButtonThumbnail;

@end

@implementation ROADNoteBookImageEditingTool

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.contentsGravity = kCAGravityResizeAspect;
        self.layer.shadowOffset = CGSizeMake(-kOne, 6.0f);
        self.layer.shadowOpacity = kShadowOpacity;
        self.alpha = kZero;
        self.imageFilter = [[ImageFilter alloc]init];
        self.originalImage = [UIImage imageNamed:@"florence.jpg"];
        [self setupFilterGallery];
        [self setupAdjustmentsGallery];
        self.layer.contents = (__bridge id)self.originalImage.CGImage;
    }
    return self;
}

- (void) setupImageView {
    self.imageView = [[UIImageView alloc]initWithFrame:self.frame];
    self.imageView.alpha = kZero;
    [self addSubview:self.imageView];
}

- (void)setupButtonThumbnails {
    self.blackAndWhiteButtonThumbnail = [self.originalImage copy];
    self.sepiaButtonThumbnail = [self.originalImage copy];
    self.invertButtonThumbnail = [self.originalImage copy];
    self.blueMoodButtonThumbnail = [self.originalImage copy];
    self.erodeButtonThumbnail = [self.originalImage copy];
    self.sunkissedButtonThumbnail = [self.originalImage copy];
    self.polarizeButtonThumbnail = [self.originalImage copy];
    self.toycameraButtonThumbnail = [self.originalImage copy];
    self.equalizationButtonThumbnail = [self.originalImage copy];
}

- (void)setupFilterGallery {
    self.filterGallery = [[UIScrollView alloc]initWithFrame:CGRectMake(5.0f, CGRectGetMidY(self.frame), kZero, kZero)];
    self.filterGallery.alpha = kHiddenControlRevealedAlhpa;
    self.filterGallery.layer.borderWidth = kBorderWidth;
    self.filterGallery.layer.zPosition = kOne;
    self.filterGallery.contentSize = CGSizeMake(70.0f * 9, 51.0f);
    self.filterGallery.clipsToBounds = YES;
    self.filterGallery.bounces = NO;
    [self addSubview:self.filterGallery];

    
    [self setupButtonThumbnails];
    
    self.blackAndWhiteButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.blackAndWhiteButton configureWithOrder:kZero image:self.blackAndWhiteButtonThumbnail name:@"B/W"];
    [self.filterGallery addSubview:self.blackAndWhiteButton];
    [self.blackAndWhiteButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];

    self.sepiaButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.sepiaButton configureWithOrder:1 image:self.sepiaButtonThumbnail name:@"Sepia"];
    [self.filterGallery addSubview:self.sepiaButton];
    [self.sepiaButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.invertButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.invertButton configureWithOrder:2 image:self.invertButtonThumbnail name:@"Invert"];
    [self.filterGallery addSubview:self.invertButton];
    [self.invertButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.blueMoodButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.blueMoodButton configureWithOrder:3 image:self.blueMoodButtonThumbnail name:@"Blue"];
    [self.filterGallery addSubview:self.blueMoodButton];
    [self.blueMoodButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.erodeButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.erodeButton configureWithOrder:4 image:self.erodeButtonThumbnail name:@"Erode"];
    [self.filterGallery addSubview:self.erodeButton];
    [self.erodeButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];

    self.sunkissedButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.sunkissedButton configureWithOrder:5 image:self.sunkissedButtonThumbnail name:@"SunKiss"];
    [self.filterGallery addSubview:self.sunkissedButton];
    [self.sunkissedButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.polarizeButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.polarizeButton configureWithOrder:6 image:self.polarizeButtonThumbnail name:@"Polarize"];
    [self.filterGallery addSubview:self.polarizeButton];
    [self.polarizeButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toycameraButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.toycameraButton configureWithOrder:7 image:self.toycameraButtonThumbnail name:@"ToyCamera"];
    [self.filterGallery addSubview:self.toycameraButton];
    [self.toycameraButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.equalizationButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.equalizationButton configureWithOrder:8 image:self.equalizationButtonThumbnail name:@"Equalize"];
    [self.filterGallery addSubview:self.equalizationButton];
    [self.equalizationButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupAdjustmentsGallery {
    self.adjustmentsGallery = [[UIScrollView alloc]init];
    self.adjustmentsGallery.alpha = kHiddenControlRevealedAlhpa;
    self.adjustmentsGallery.layer.borderWidth = kBorderWidth;
    self.adjustmentsGallery.layer.zPosition = kOne;
    self.adjustmentsGallery.contentSize = CGSizeMake(70.0f * 10, 51.0f);
    self.adjustmentsGallery.clipsToBounds = YES;
    self.adjustmentsGallery.bounces = NO;
    [self addSubview:self.adjustmentsGallery];
    
    self.sliderAdjustmentValue = kOne;
    self.imageAdjustmentSlider = [[UISlider alloc]init];
    self.imageAdjustmentSlider.layer.zPosition = kOne;
    self.imageAdjustmentSlider.maximumValue = kOne;
    self.imageAdjustmentSlider.minimumValue = -kOne;
    self.imageAdjustmentSlider.value = self.sliderAdjustmentValue;
    [self.imageAdjustmentSlider addTarget:self action:@selector(adjustImageValues:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.imageAdjustmentSlider];
    
    self.vibrantButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.vibrantButton configureWithOrder:kZero image:self.equalizationButtonThumbnail name:@"Hue"];
    [self.adjustmentsGallery addSubview:self.vibrantButton];
    [self.vibrantButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.colorizeButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.colorizeButton configureWithOrder:1 image:self.equalizationButtonThumbnail name:@"Saturation"];
    [self.adjustmentsGallery addSubview:self.colorizeButton];
    [self.colorizeButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.brightnessButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.brightnessButton configureWithOrder:2 image:self.equalizationButtonThumbnail name:@"Brightness"];
    [self.adjustmentsGallery addSubview:self.brightnessButton];
    [self.brightnessButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.exposureButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.exposureButton configureWithOrder:3 image:self.equalizationButtonThumbnail name:@"Exposure"];
    [self.adjustmentsGallery addSubview:self.exposureButton];
    [self.exposureButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.contrastButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.contrastButton configureWithOrder:4 image:self.equalizationButtonThumbnail name:@"Contrast"];
    [self.adjustmentsGallery addSubview:self.contrastButton];
    [self.contrastButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.edgesButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.edgesButton configureWithOrder:5 image:self.equalizationButtonThumbnail name:@"Edges"];
    [self.adjustmentsGallery addSubview:self.edgesButton];
    [self.edgesButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.gammaButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.gammaButton configureWithOrder:6 image:self.equalizationButtonThumbnail name:@"Gamma"];
    [self.adjustmentsGallery addSubview:self.gammaButton];
    [self.gammaButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.polarizeButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.polarizeButton configureWithOrder:7 image:self.equalizationButtonThumbnail name:@"Polarize"];
    [self.adjustmentsGallery addSubview:self.polarizeButton];
    [self.polarizeButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.blurButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.blurButton configureWithOrder:8 image:self.equalizationButtonThumbnail name:@"Blur"];
    [self.adjustmentsGallery addSubview:self.blurButton];
    [self.blurButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    self.sharpenButton = [[ROADNoteBookViewFilterButton alloc]initWithFrame:CGRectZero];
    [self.sharpenButton configureWithOrder:9 image:self.equalizationButtonThumbnail name:@"Sharpen"];
    [self.adjustmentsGallery addSubview:self.sharpenButton];
    [self.sharpenButton addTarget:self action:@selector(toggleImageManipulationOptions:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)toggleImageManipulationOptions: (UIButton *)sender {
    self.imageView.alpha = kZero;
    if (sender == self.sepiaButton) {
        self.mode = ModeSepia;
    }
    if (sender == self.invertButton) {
        self.mode = ModeInvert;
    }
    if (sender == self.sepiaButton) {
        self.mode = ModeSepia;
    }
    if (sender == self.blueMoodButton) {
        self.mode = ModeBlueMood;
    }
    if (sender == self.erodeButton) {
        self.mode = ModeErode;
    }
    if (sender == self.sunkissedButton) {
        self.mode = ModeSunKissed;
    }
    if (sender == self.blackAndWhiteButton) {
        self.mode = ModeBlackAndWhite;
    }
    if (sender == self.polarizeButton) {
        self.mode = ModePolarize;
    }
    if (sender == self.toycameraButton) {
        self.mode = ModeToyCamera;
    }
    if (sender == self.equalizationButton) {
        self.mode = ModeEqualization;
    }
    if (sender == self.vibrantButton) {
        self.mode = ModeVibrant;
    }
    if (sender == self.colorizeButton) {
        self.mode = ModeSepia;
    }
    if (sender == self.brightnessButton) {
        self.mode = ModeBrightness;
    }
    if (sender == self.exposureButton) {
        self.mode = ModeExposure;
    }
    if (sender == self.contrastButton) {
        self.mode = ModeContrast;
    }
    if (sender == self.edgesButton) {
        self.mode = ModeEdges;
    }
    if (sender == self.gammaButton) {
        self.mode = ModeGamma;
    }
    if (sender == self.blurButton) {
        self.mode = ModeBlur;
    }
    if (sender == self.sharpenButton) {
        self.mode = ModeSharpen;
    }
    if (sender == self.polarizeButton) {
        self.mode = ModePolarize;
    }
    if (self.mode == ModeBlur) {
        self.imageAdjustmentSlider.maximumValue = 100.0f;
        self.imageAdjustmentSlider.minimumValue = kZero;
    } else {
        self.imageAdjustmentSlider.maximumValue = kOne;
        self.imageAdjustmentSlider.minimumValue = -kOne;
    }
    
    [self updateImage];
    [UIView animateWithDuration:kOne animations:^{
        self.imageView.alpha = kOne;
    }];
    
}

- (void)adjustImageValues: (UISlider *)sender {
    self.sliderAdjustmentValue = sender.value;
}

-(void) setSliderAdjustmentValue:(float)sliderAdjustmentValue {
    _sliderAdjustmentValue = sliderAdjustmentValue;
    
    //Update the image based on the current mode
    [self updateImage];

}

-(void) updateImage {
    NSLog(@"HERE!");
    UIImage *image = [self.originalImage copy];
    dispatch_async(dispatch_get_main_queue(), ^{
    switch (self.mode) {
        case ModeSepia:
            self.imageView.image = [image sepia];
            break;
        case ModeInvert:
            self.imageView.image = [image invert];
            break;
        case ModeBlueMood:
            self.imageView.image = [image blueMood];
            break;
        case ModeErode:
            self.imageView.image = [image erode];
            break;
        case ModeSunKissed:
            self.imageView.image = [image sunkissed];
            break;
        case ModeBlackAndWhite:
            self.imageView.image = [image blackAndWhite];
            break;
        case ModePolarize:
            self.imageView.image = [image polarize];
            break;
        case ModeMagicHour:
            self.imageView.image = [image magichour];
            break;
        case ModeToyCamera:
            self.imageView.image = [image toycamera];
            break;
        case ModeEqualization:
            self.imageView.image = [image equalization];
            break;
        case ModeVibrant:
            self.imageView.image = [image vibrant:self.sliderAdjustmentValue];
            break;
        case ModeColorize:
            self.imageView.image = [image colorize:self.sliderAdjustmentValue];
            break;
        case ModeContrast:
            self.imageView.image = [image contrast:self.sliderAdjustmentValue];
            break;
        case ModeBrightness:
            self.imageView.image = [image brightness:self.sliderAdjustmentValue];
            break;
        case ModeExposure:
            self.imageView.image = [image exposure:self.sliderAdjustmentValue];
            break;
        case ModeEdges:
            self.imageView.image = [image edges:self.sliderAdjustmentValue];
            break;
        case ModeGamma:
            self.imageView.image = [image gamma:self.sliderAdjustmentValue];
            break;
        case ModeBlur:
            self.imageView.image = [image blur:self.sliderAdjustmentValue];
            break;
        case ModeSharpen:
            self.imageView.image = [image sharpen:self.sliderAdjustmentValue];
            break;
        case ModePosterize:
            self.imageView.image = [image posterize:self.sliderAdjustmentValue];
            break;
        default:
            break;
    }
    });
    self.imageView.alpha = kOne;

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
