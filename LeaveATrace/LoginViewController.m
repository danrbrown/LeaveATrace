//
//  LoginViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userNameTextField, passWordTextField;

- (void)viewDidLoad
{
    
    
    
    
}

- (IBAction)userLogInPressed:(id)sender
{
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passWordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            //Open the wall
            [self performSegueWithIdentifier:@"LoginSuccesful" sender:self];
        } else {
            //Something bad has ocurred
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"Either you password or your username was wrong, rookie mistake!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
}

@end