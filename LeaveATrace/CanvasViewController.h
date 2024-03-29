//
//  CanvasViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/19/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

//Global variables
extern NSString *badgeString;
extern NSInteger badgeInt;
extern NSString *tracesBadgeString;
extern NSInteger tracesBadgeInt;
extern NSData *pictureData;
extern UIImage *SaveImage;
extern PFFile *file;
extern long iconBadge;
extern BOOL sentImage;
extern NSMutableArray *undoImageArray;

@interface CanvasViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> {
    
    //Variables for drawing
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    CGPoint prevoiusPoint1;
    CGPoint prevoiusPoint2;
    BOOL mouseSwiped;
    UIColor *theColor;
    double hue;
    
    //Undo
    UIImage *undoImage;
    
    //Variables
    BOOL dontTrash;
    int viewText;
    NSMutableArray *imagesArray;
    UIImagePickerController *imagePicker;
    UIImagePickerController *picturePicker;
    
    //Outlets for view
    IBOutlet UIButton *undoB;
    IBOutlet UIButton *trashB;
    IBOutlet UIButton *colorsB;
    IBOutlet UIButton *menuB;
    IBOutlet UIButton *saveB;
    IBOutlet UIButton *sendB;
    IBOutlet UIActivityIndicatorView *loading;
    IBOutlet UIImageView *sliderImage;
    IBOutlet UIImageView *tutorialImage;
    UIView *_hudView;
    UILabel *_captionLabel;
    
}

//Image propertys for view
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *currentColorImage;

//Propertys for view
@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;
@property CGFloat brush;
@property IBOutlet UISlider *brushSize;
@property IBOutlet UISlider *colorValue;

//Actions for view
-(IBAction) undo:(id)sender;
-(IBAction) send:(id)sender;
-(IBAction) save:(id)sender;
-(IBAction) clear:(id)sender;
-(IBAction) sliderChanged:(id)sender;

//Methods for view
-(void) hide;
-(void) show;
-(void) fade;
-(void) countTraces;
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
-(BOOL) canBecomeFirstResponder;
-(UIImage*) convertToMask: (UIImage *) image;

@end
