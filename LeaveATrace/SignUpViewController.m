//
//  SignUpViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    
    
    
}

-(IBAction)signUpUserPressed:(id)sender
{
    //1
    PFUser *user = [PFUser user];
    //2
    user.username = self.userSignUpTextField.text;
    user.password = self.passwordSignUpTextField.text;
    //3
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //The registration was successful, go to the wall
            [self performSegueWithIdentifier:@"SignupSuccesful" sender:self];
            
        } else {
            //Something bad has occurred
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"Either you password or your username was wrong, rookie mistake!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
}

@end
