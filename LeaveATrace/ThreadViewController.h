//
//  ThreadViewController.h
//  LeaveATrace
//
//  Created by RICKY BROWN on 11/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

extern int timerInt;
extern NSString *timerString;

@interface ThreadViewController : UIViewController <UIActionSheetDelegate> {
    
    //Variables for drawing
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    
    //Variables
    BOOL dontTrash;
    NSTimer *timer;
    int minutes;
    
    //IBOutlets
    IBOutlet UIButton *undoB;
    IBOutlet UIButton *trashB;
    IBOutlet UIButton *eraseB;
    IBOutlet UIButton *colorsB;
    IBOutlet UIButton *saveB;
    IBOutlet UIButton *sendB;
    IBOutlet UIProgressView *sendingProg;
    
}

//Property type UIImageView for the image that you draw on
@property (weak, nonatomic) IBOutlet UIImageView *mainThreadImage;

//Property type UIImageView for the current color you are drawing
@property (weak, nonatomic) IBOutlet UIImageView *currentColorImage;

//Varibles for colors
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;
@property IBOutlet UISlider *brushSize;
@property IBOutlet UISlider *colorValue;

//Actions for the View
-(IBAction) eraser:(id)sender;
-(IBAction) undo:(id)sender;
-(IBAction) clear:(id)sender;
-(IBAction) save:(id)sender;
-(IBAction) send:(id)sender;
-(IBAction) sliderChanged:(id)sender;

//Methods for view
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
-(void) countIt;
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
-(void) uploadThreadTrace;
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) getThreadTrace:(NSString *)userWhoSentTrace;
-(UIImage *) convertToMask:(UIImage *)image;

@end





