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
@property (nonatomic, strong) UIView *canvasView;
@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UIButton *pencilButton;
@property (nonatomic, strong) UIButton *pictureButton;

@property (nonatomic, strong) ROADColors *userColors;
@property (nonatomic, assign) BOOL drawingToolActivated;

@end

@implementation ROADNoteBookView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Notes %@", self.arrayOfNotes);
    
    self.drawingToolActivated = YES;
    self.userColors = [[ROADColors alloc]init];
    UIView *backgroundView = [[UIView alloc]initWithFrame:self.view.frame];
    UIImage *ivoryPaper = [UIImage imageNamed:@"ivoryPaper.png"];
    UIImage *pencilImage = [UIImage imageNamed:@"drawingPencil"];
   backgroundView.layer.contents = (__bridge id)ivoryPaper.CGImage;
    [self.view addSubview:backgroundView];
    
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
    self.pictureButton.layer.opacity = 0.2f;
    [self.pictureButton addTarget:self action:@selector(toggleDrawingTool:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.canvasView = [[UIView alloc]initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.view.frame)-40, CGRectGetHeight(self.view.frame)-80)];
    self.canvasView.layer.shadowOffset = CGSizeMake(-1.0f, 6.0f);
    self.canvasView.layer.borderWidth = kBoarderWidth;
    self.canvasView.layer.shadowOpacity = kShadowOpacity;
    
    [self setDrawingTool];

    [self.view addSubview:self.canvasView];
    [self.canvasView addSubview:self.drawToolView];
    [self.view addSubview:self.returnButton];
    [self.view addSubview:self.pencilButton];
    [self.view addSubview:self.pictureButton];
    [self.view bringSubviewToFront:self.returnButton];
    [self.view bringSubviewToFront:self.pencilButton];
    
    [self displayNotes];
}

- (void)backtoBook: (UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleDrawingTool: (UIButton *)sender {
    self.drawingToolActivated = !self.drawingToolActivated;
    if (!self.drawingToolActivated) {
        self.drawToolView.layer.zPosition = -1.0f;
        [UIView animateWithDuration:0.20f animations:^{
            self.drawToolView.alpha = kZero;
        }];
        [UIView animateWithDuration:1.0f animations:^{
            self.pencilButton.alpha = 0.2f;
        }];
    }
    if (self.drawingToolActivated) {
        self.drawToolView.layer.zPosition = 1.0f;
        [UIView animateWithDuration:0.20f animations:^{
            self.drawToolView.alpha = 1.0f;
        }];
        [UIView animateWithDuration:1.0f animations:^{
            self.pencilButton.alpha = 1.0f;
        }];
    }
    NSLog(@"%d", self.drawingToolActivated);
}

- (void)setDrawingTool {
    self.drawToolView = [[ROADDrawToolView alloc] initWithFrame:self.canvasView.bounds];
    self.drawToolView.currentColor = self.userColors.colorSix;
    self.drawToolView.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:47.0/255.0 blue:64.0/255.0 alpha:0.01];
    self.drawToolView.userInteractionEnabled = YES;
    self.drawToolView.alpha = kZero;
}

- (void)displayNotes {
    int indexCount = 1;
    for (NSString *notesString in self.arrayOfNotes) {
        indexCount++;
        UILabel *notesLabel = [[UILabel alloc]initWithFrame:CGRectMake(30.0f, 40.0f + indexCount*40.0f, 400.0f, 200.0f)];
        notesLabel.text = notesString;
        notesLabel.textColor = self.userColors.colorSix;
        notesLabel.font = [UIFont fontWithName:@"American Typewriter" size:13.0f];
        [self.canvasView addSubview:notesLabel];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
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
