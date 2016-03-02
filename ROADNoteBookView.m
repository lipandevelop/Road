//
//  ROADNoteBookView.m
//  Road
//
//  Created by Li Pan on 2016-03-01.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "ROADNoteBookView.h"
#import "ROADConstants.h"
#import "ROADDrawToolView.h"
#import "ROADColors.h"

@interface ROADNoteBookView ()
@property (nonatomic, strong) ROADDrawToolView *drawToolView;
@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UIButton *pencilButton;
@property (nonatomic, strong) UIButton *pictureButton;
@property (nonatomic, strong) ROADColors *userColors;
@property (nonatomic, assign) BOOL drawingToolActivated;

@end

@implementation ROADNoteBookView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayNotes];
    
    self.drawingToolActivated = YES;
    self.userColors = [[ROADColors alloc]init];
    UIView *backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    UIImage *ivoryPaper = [UIImage imageNamed:@"ivoryPaper.png"];
    UIImage *pencilImage = [UIImage imageNamed:@"drawingPencil"];
   backgroundView.layer.contents = (__bridge id)ivoryPaper.CGImage;
    [self.view addSubview:backgroundView];
    
    [self setDrawingTool];
    self.returnButton = [[UIButton alloc]initWithFrame:CGRectMake(10.0f, self.view.frame.size.height - kAccessButtonHeight - 10.0f, kAccessButtonHeight, kAccessButtonHeight)];
    self.returnButton.layer.borderWidth = kBoarderWidth;
    [self.returnButton setTitle:@"<" forState:UIControlStateNormal];
    self.returnButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.returnButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.returnButton.layer.shadowOpacity = kShadowOpacity;
    self.returnButton.layer.opacity = kUINormaAlpha;
    self.returnButton.alpha = kUINormaAlpha;
    [self.returnButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.returnButton addTarget:self action:@selector(backtoBook:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pencilButton = [[UIButton alloc]initWithFrame:CGRectMake(65.0f, self.view.frame.size.height - kAccessButtonHeight - 10.0f, kAccessButtonHeight, kAccessButtonHeight)];
    self.pencilButton.layer.borderWidth = kBoarderWidth;
    self.pencilButton.layer.contents = (__bridge id)pencilImage.CGImage;
    self.pencilButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.pencilButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.pencilButton.layer.shadowOpacity = kShadowOpacity;
    self.pencilButton.alpha = kUINormaAlpha;
    self.pencilButton.layer.opacity = kUINormaAlpha;
    [self.pencilButton addTarget:self action:@selector(toggleDrawingTool:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pictureButton = [[UIButton alloc]initWithFrame:CGRectMake(65.0f, self.view.frame.size.height - kAccessButtonHeight - 10.0f, kAccessButtonHeight, kAccessButtonHeight)];
    self.pictureButton.layer.borderWidth = kBoarderWidth;
    self.pictureButton.layer.contents = (__bridge id)pencilImage.CGImage;
    self.pictureButton.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.pictureButton.layer.cornerRadius = kAccessButtonHeight/2;
    self.pictureButton.layer.shadowOpacity = kShadowOpacity;
    self.pictureButton.alpha = kUINormaAlpha;
    self.pictureButton.layer.opacity = kUINormaAlpha;
    [self.pictureButton addTarget:self action:@selector(toggleDrawingTool:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.returnButton];
    [self.view addSubview:self.pencilButton];
    [self.view addSubview:self.pictureButton];
    [self.view bringSubviewToFront:self.returnButton];
    [self.view bringSubviewToFront:self.pencilButton];
    
}

- (void)backtoBook: (UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleDrawingTool: (UIButton *)sender {
    self.drawingToolActivated = !self.drawingToolActivated;
    if (!self.drawingToolActivated) {
        [UIView animateWithDuration:0.20f animations:^{
            self.drawToolView.alpha = kZero;
        }];
        [UIView animateWithDuration:1.0f animations:^{
            self.pencilButton.alpha = kUINormaAlpha;
        }];
    }
    if (self.drawingToolActivated) {
        [UIView animateWithDuration:0.20f animations:^{
            self.drawToolView.alpha = 1.0f;
        }];
        [UIView animateWithDuration:1.0f animations:^{
            self.pencilButton.alpha = kHiddenControlRevealedAlhpa;
        }];
    }
    NSLog(@"%d", self.drawingToolActivated);
}

- (void)setDrawingTool {
    self.drawToolView = [[ROADDrawToolView alloc] initWithFrame:self.view.bounds];
    self.drawToolView.currentColor = self.userColors.colorSix;
    self.drawToolView.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:47.0/255.0 blue:64.0/255.0 alpha:0.01];
    self.drawToolView.userInteractionEnabled = YES;
    [self.view addSubview:self.drawToolView];
}

- (void)displayNotes {
    for (NSString *notesString in self.arrayOfNotes) {
        int indexCount = 1;
        indexCount++;
        UILabel *notesLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-200, 40 + indexCount*40, 40.0f, 400.0f)];
        notesLabel.text = notesString;
        [self.view addSubview:notesLabel];
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
