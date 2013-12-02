//
//  CanvasViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/19/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import <Parse/Parse.h>

//Global variables
extern NSString *badgeString;
extern NSInteger badgeInt;
extern NSString *tracesBadgeString;
extern NSInteger tracesBadgeInt;
extern NSData *pictureData;
extern UIImage *SaveImage;
extern PFFile *file;
extern NSString *userLoggedIn;
extern NSUserDefaults *defaults;
extern UIImageView *mainImage;

@interface CanvasViewController : UIViewController <SettingsViewControllerDelegate, UIActionSheetDelegate> {
    
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
    int waitTwo;
    NSArray *imagesArray;
    NSMutableArray *pathArray;
    NSMutableArray *bufferArray;
    UIBezierPath *myPath;
    
    //Buttons for view
    IBOutlet UIButton *undoB;
    IBOutlet UIButton *trashB;
    IBOutlet UIButton *eraseB;
    IBOutlet UIButton *colorsB;
    IBOutlet UIButton *menuB;
    IBOutlet UIButton *saveB;
    IBOutlet UIButton *sendB;
    
}

//Image propertys for view
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *currentColorImage;


//Color property vaiables for view
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;
@property CGFloat brush;
@property IBOutlet UISlider *brushSize;
@property IBOutlet UISlider *colorValue;

//Actions for view
-(IBAction) eraser:(id)sender;
-(IBAction) undo:(id)sender;
-(IBAction) send:(id)sender;
-(IBAction) save:(id)sender;
-(IBAction) clear:(id)sender;
-(IBAction) sliderChanged:(id)sender;

//Methods for view
-(void) uploadTrace;
-(void) countRequests;
-(void) countTraces;
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
-(void) closeSettings:(id)sender;
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
-(UIImage*) convertToMask: (UIImage *) image;

@end
