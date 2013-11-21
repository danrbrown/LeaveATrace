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
@synthesize emailTextField ,userSignUpTextField, passwordSignUpTextField, varifyPasswordSignUpTextField;

- (void)viewDidLoad {
    
    emailTextField.layer.cornerRadius = 7;
    
    userSignUpTextField.layer.cornerRadius = 7;
    
    passwordSignUpTextField.layer.cornerRadius = 7;
    
    varifyPasswordSignUpTextField.layer.cornerRadius = 7;
    
    self.varifyPasswordSignUpTextField.delegate = self;
    
    [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:0.4];
    
    emailTextField.autocorrectionType = FALSE;
    emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    userSignUpTextField.autocorrectionType = FALSE;
    userSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    passwordSignUpTextField.autocorrectionType = FALSE;
    passwordSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    varifyPasswordSignUpTextField.autocorrectionType = FALSE;
    varifyPasswordSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (IBAction)closeKeyBoard:(UITapGestureRecognizer *)sender {
    [self.emailTextField resignFirstResponder];
    [self.passwordSignUpTextField resignFirstResponder];
    [self.userSignUpTextField resignFirstResponder];
    [self.varifyPasswordSignUpTextField resignFirstResponder];
}

-(void)showKeyBoard {
    [self.userSignUpTextField becomeFirstResponder];
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
            
        }
        else if (error){
         
           UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username already taken or not valid email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
          [errorAlertView show];
            
            
            userSignUpTextField.text = nil;
            
            emailTextField.text = nil;
            
        }
    }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
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
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
            userSignUpTextField.text = nil;
            emailTextField.text = nil;
            
        }
    }];
    
    return NO;
}

@end
