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
@synthesize userSignUpTextField, passwordSignUpTextField;

- (void)viewDidLoad
{
    
    userSignUpTextField.layer.cornerRadius = 7;
    
    userSignUpTextField.tintColor = [UIColor redColor];
    
    passwordSignUpTextField.layer.cornerRadius = 7;
    
    passwordSignUpTextField.tintColor = [UIColor redColor];
    
}

-(IBAction)signUpUserPressed:(id)sender
{
    
    PFUser *user = [PFUser user];
    
    user.username = self.userSignUpTextField.text;
    user.password = self.passwordSignUpTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [self performSegueWithIdentifier:@"SignupSuccesful" sender:self];
            
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
            [[PFInstallation currentInstallation] saveEventually];
            
        } else if (error){
            
           UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Nope!" message:@"Username already taken" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
          [errorAlertView show];
            
        }
    }];
    
}

@end
