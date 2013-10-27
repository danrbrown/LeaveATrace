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
    
    userNameTextField.layer.cornerRadius = 7;
    
    userNameTextField.tintColor = [UIColor redColor];
    
    passWordTextField.layer.cornerRadius = 7;
    
    passWordTextField.tintColor = [UIColor redColor];
    
}

- (IBAction)userLogInPressed:(id)sender
{
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passWordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            
            [self performSegueWithIdentifier:@"LoginSuccesful" sender:self];
            
            
            
        } else {
            //Something bad has ocurred
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"Either your password or your username was wrong, rookie mistake!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];
}

@end