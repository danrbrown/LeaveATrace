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
@synthesize scrollie, emailTextField ,userSignUpTextField, passwordSignUpTextField, varifyPasswordSignUpTextField;

- (void)viewDidLoad
{
    
    [scrollie setScrollEnabled:YES];
    [scrollie setContentSize:CGSizeMake(0, 2000)];
    
    
    emailTextField.layer.cornerRadius = 7;
    
    userSignUpTextField.layer.cornerRadius = 7;
    
    passwordSignUpTextField.layer.cornerRadius = 7;
    
    varifyPasswordSignUpTextField.layer.cornerRadius = 7;
    
    self.varifyPasswordSignUpTextField.delegate = self;

}

-(IBAction)signUpUserPressed:(id)sender
{
    
    PFUser *user = [PFUser user];
    
    user.email = self.emailTextField.text;
    user.username = self.userSignUpTextField.text;
    user.password = self.passwordSignUpTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            
            [self performSegueWithIdentifier:@"SignupSuccesful" sender:self];
            
            [self textFieldShouldReturn:varifyPasswordSignUpTextField];
            
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
            [[PFInstallation currentInstallation] saveEventually];
            
            
            
            
            
            
            
            
            
        } else if (error){
            
           UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username already taken or not valid email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
          [errorAlertView show];
            
            userSignUpTextField.text = nil;
            emailTextField.text = nil;
            
        }
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return NO;
}

@end
