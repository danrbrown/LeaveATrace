//
//  SettingsViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/19/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate <NSObject>
- (void)closeSettings:(id)sender;
@end

@interface SettingsViewController : UIViewController {
    
    IBOutlet UIImageView *redFrame;
    IBOutlet UIImageView *blueFrame;
    IBOutlet UIImageView *greenFrame;
    IBOutlet UIImageView *orangeFrame;
    IBOutlet UIImageView *yellowFrame;
    IBOutlet UIImageView *blackFrame;
    
}

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

@property IBOutlet UISlider *redControl;
@property IBOutlet UISlider *blueControl;
@property IBOutlet UISlider *greenControl;

@property IBOutlet UISlider *brushSize;

@property CGFloat brush;

@property CGFloat red;
@property CGFloat green;
@property CGFloat blue;

@property IBOutlet UILabel *redLabel;
@property IBOutlet UILabel *greenLabel;
@property IBOutlet UILabel *blueLabel;

@property IBOutlet UIImageView *currentColorLabel;

@property IBOutlet UIImageView *smallB;

@property IBOutlet UIImageView *bigB;

-(IBAction)justRed:(id)sender;

-(IBAction)justBlue:(id)sender;

-(IBAction)justGreen:(id)sender;

-(IBAction)justBlack:(id)sender;

-(IBAction)justOrange:(id)sender;

-(IBAction)justYellow:(id)sender;

@end


