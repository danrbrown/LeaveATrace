//
//  DetialViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 2/3/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface DetialViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
    //support
    IBOutlet UITextView *supportText;
    IBOutlet UIButton *supportButton;
    
    //Terms of use
    
    //Privacy policy
    
    
}

@property (nonatomic, retain) NSString *TextForTitle;

@property (strong, nonatomic) NSArray *detailModel;

-(IBAction)sendEmail:(id)sender;

@end
