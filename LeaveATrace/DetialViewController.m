//
//  DetialViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 2/3/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "DetialViewController.h"
#import "SettingsViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

@interface DetialViewController ()

@end

@implementation DetialViewController

- (void)viewDidLoad
{
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.title = titleText;
    
    supportText.editable = NO;
    
    if (screens == 0)
    {
        
        [supportText setHidden:NO];
        [supportButton setHidden:NO];
        
    }
    else if (screens == 1)
    {
        
        [supportText setHidden:YES];
        [supportButton setHidden:YES];
        
    }
    else if (screens == 2)
    {
        
        [supportText setHidden:YES];
        [supportButton setHidden:YES];
        
    }
    
}

-(IBAction)sendEmail:(id)sender
{
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    
    [mailComposer setMailComposeDelegate:self];
    
    if ([MFMailComposeViewController canSendMail])
    {
        
        [mailComposer setToRecipients:[NSArray arrayWithObjects:@"draw@leaveatrace.com", nil]];
        
        [mailComposer setSubject:@"Leave A Trace"];
        
        [mailComposer setMessageBody:@"Dear Dan and Ricky Brown,\n" isHTML:NO];
        
        [self presentViewController:mailComposer animated:YES completion:nil];
        
    }
    
}

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
