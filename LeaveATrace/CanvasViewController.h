//
//  CanvasViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/19/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

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
    
}

@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

-(IBAction)send:(id)sender;


@end
