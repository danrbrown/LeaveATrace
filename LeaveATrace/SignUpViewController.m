//-------------------------------------------------------
//
//  SignUpViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//
//  Purpose: this file of class ViewController is for
//  the user to sign up.
//
//-------------------------------------------------------

#import "SignUpViewController.h"
#import <Parse/Parse.h>

@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize emailTextField ,userSignUpTextField, passwordSignUpTextField, varifyPasswordSignUpTextField;

//-----------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: when the sceen comes up the text fields rounded,
// there is no autocorrect, and the keyboard comes up after
// 0.4 seconds.
//
//-----------------------------------------------------------

- (void)viewDidLoad
{
    
    emailTextField.layer.cornerRadius = 7;
    
    userSignUpTextField.layer.cornerRadius = 7;
    
    passwordSignUpTextField.layer.cornerRadius = 7;
    
    varifyPasswordSignUpTextField.layer.cornerRadius = 7;
    
    self.varifyPasswordSignUpTextField.delegate = self;
    
    emailTextField.autocorrectionType = FALSE;
    emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userSignUpTextField.autocorrectionType = FALSE;
    userSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordSignUpTextField.autocorrectionType = FALSE;
    passwordSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    varifyPasswordSignUpTextField.autocorrectionType = FALSE;
    varifyPasswordSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:0.4];
    
}

//----------------------------------------------------------
//
// Name: closeKeyBoard
//
// Purpose: closes the keyboard if you touch any free space
// in the view.
//
//----------------------------------------------------------

- (IBAction) closeKeyBoard:(UITapGestureRecognizer *)sender
{
    
    [self.emailTextField resignFirstResponder];
    
    [self.passwordSignUpTextField resignFirstResponder];
    
    [self.userSignUpTextField resignFirstResponder];
    
    [self.varifyPasswordSignUpTextField resignFirstResponder];
    
}

//---------------------------------------------------------
//
// Name: showKeyBoard
//
// Purpose: Method to show keyboard.
//
//---------------------------------------------------------

-(void) showKeyBoard
{
    
    [self.userSignUpTextField becomeFirstResponder];
    
}

//---------------------------------------------------------
//
// Name: signUpUserPressed
//
// Purpose: DB
//
//---------------------------------------------------------

-(IBAction) signUpUserPressed:(id)sender
{
    
    PFUser *user = [PFUser user];
    
    user.email = self.emailTextField.text;
    user.username = self.userSignUpTextField.text;
    user.password = self.passwordSignUpTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
        
        if (!error)
        {
            
            [self performSegueWithIdentifier:@"SignupSuccesful" sender:self];
            
            [self textFieldShouldReturn:varifyPasswordSignUpTextField];
            
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
            
            [[PFInstallation currentInstallation] saveEventually];
            
        }
        else if (error)
        {
         
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Username already taken or not valid email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
            userSignUpTextField.text = nil;
            
            emailTextField.text = nil;
            
        }
        
    }];
    
}

//---------------------------------------------------------
//
// Name:
//
// Purpose:
//
//---------------------------------------------------------

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    
    return NO;
}

@end
