//------------------------------------------------------------------
//
//  LoginViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//
//  Purpose: this file of class ViewController is the screen the
//  user can enter their username and password to log into the app.
//
//------------------------------------------------------------------

#import "LoginViewController.h"
#import "CanvasViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize userNameTextField, passWordTextField;

//---------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: when the screen shows up the two text fields
// are rounded on the corners, there is no auto correct,
// and it runs a method to bring the keyboard automatically
// after 0.4 seconds.
//
//---------------------------------------------------------

-(void) viewDidLoad
{
    
    userNameTextField.layer.cornerRadius = 7;
    passWordTextField.layer.cornerRadius = 7;
    
    self.passWordTextField.delegate = self;
    
    userNameTextField.autocorrectionType = FALSE;
    userNameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    passWordTextField.autocorrectionType = FALSE;
    passWordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:0.4];
    
}

//---------------------------------------------------------
//
// Name: showKeyBoard
//
// Purpose: Method to show the keyboard.
//
//---------------------------------------------------------

-(void) showKeyBoard
{
    
    [self.userNameTextField becomeFirstResponder];
    
}

//---------------------------------------------------------
//
// Name: closeKeyBoard
//
// Purpose: when the user touchs any free space on the
// the textfields close.
//
//---------------------------------------------------------

-(IBAction) closeKeyBoard:(UITapGestureRecognizer *)sender
{
    
    [self.userNameTextField resignFirstResponder];
    
    [self.passWordTextField resignFirstResponder];
    
}

//---------------------------------------------------------
//
// Name: textFieldShouldReturn
//
// Purpose: closes the text field on enter and will proceed
// to check in.
//
//---------------------------------------------------------

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    
    //DTRB
    
    [textField resignFirstResponder];
    
    return NO;
}

//---------------------------------------------------------
//
// Name: userLogInPressed
//
// Purpose: calls a method to log the person in.
//
//---------------------------------------------------------

-(IBAction) userLogInPressed:(id)sender
{
    
    [self logingIn];
    
}

//-----------------------------------------------------------
//
// Name: logingIn
//
// Purpose: logs the user, if he varified his/her email and
// the pasword is correct the user logs into the app, other-
// wise it will alert them that whats wrong, and clear the
// password textfield. if somtthing else not defined went
// wrong it will alert it of it.
//
//-----------------------------------------------------------

-(void) logingIn
{
    
    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passWordTextField.text block:^(PFUser *user, NSError *error) {
        if (user)
        {
            
            if (![[user objectForKey:@"emailVerified"] boolValue])
            {
                
                [user refresh]; //DB
                
                if (![[user objectForKey:@"emailVerified"] boolValue])
                {
                    
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You must verify your email before logging in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [errorAlertView show];
                    
                    passWordTextField.text = nil;
                    
                }
                
            }
            else
            {
                
                [self performSegueWithIdentifier:@"LoginSuccesful" sender:self];
                
                [self textFieldShouldReturn:passWordTextField];
                
            }
            
        }
        else
        {
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"There was a error loging in" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
            passWordTextField.text = nil;
            
        }
        
    }];
    
}

@end

