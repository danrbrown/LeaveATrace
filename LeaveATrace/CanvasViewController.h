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

extern NSString *badgeString;

extern NSInteger badgeInt;

extern NSData *pictureData;

extern UIImage *SaveImage;

extern PFFile *file;

extern NSString *userLoggedIn;

extern NSUserDefaults *defaults;

@interface CanvasViewController : UIViewController <SettingsViewControllerDelegate, UIActionSheetDelegate> {
    
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    
    BOOL dontTrash;
    
    int waitTwo;
    
    IBOutlet UILabel *DrawAnything;
    
    IBOutlet UILabel *SendToAnyone;
    
    IBOutlet UIButton *undoB;
    IBOutlet UIButton *trashB;
    IBOutlet UIButton *eraseB;
    IBOutlet UIButton *colorsB;
    IBOutlet UIButton *menuB;
    IBOutlet UIButton *saveB;
    IBOutlet UIButton *sendB;
    IBOutlet UIButton *getB;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *currentColorImage;

@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;

-(void)uploadTrace;

-(IBAction)eraser:(id)sender;
-(IBAction)undo:(id)sender;
-(IBAction)send:(id)sender;

@end
