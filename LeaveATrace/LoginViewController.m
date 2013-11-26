//
//  LoginViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "LoginViewController.h"
#import "CanvasViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize userNameTextField, passWordTextField;

- (void)viewDidLoad {
    
    userNameTextField.layer.cornerRadius = 7;
    
    passWordTextField.layer.cornerRadius = 7;
    
    self.passWordTextField.delegate = self;
    
    [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:0.4];
    
    userNameTextField.autocorrectionType = FALSE;
    userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    passWordTextField.autocorrectionType = FALSE;
    passWordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
}

- (IBAction)closeKeyBoard:(UITapGestureRecognizer *)sender {
    
    [self.userNameTextField resignFirstResponder];
    
    [self.passWordTextField resignFirstResponder];
    
}

-(void) showKeyBoard {
    
    [self.userNameTextField becomeFirstResponder];
    
}

- (IBAction)userLogInPressed:(id)sender {
    
    [self logingIn];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //[self logingIn];
    
    [textField resignFirstResponder];
    
    return NO;
}

-(void)logingIn {
    
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passWordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            
            if (![[user objectForKey:@"emailVerified"] boolValue]) {
                
                [user refresh];
                
                if (![[user objectForKey:@"emailVerified"] boolValue]) {
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You must verify your email before logging in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                    passWordTextField.text = nil;
                }
            }
            else {
                
                [self performSegueWithIdentifier:@"LoginSuccesful" sender:self];
                
                [self textFieldShouldReturn:passWordTextField];
            }
            
        } else {
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"There was a error loging in" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
            passWordTextField.text = nil;
            
        }
    }];
    
}


@end





