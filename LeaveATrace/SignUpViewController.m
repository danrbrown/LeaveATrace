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

@synthesize emailTextField ,userSignUpTextField, passwordSignUpTextField, varifyPasswordSignUpTextField, signUpButton;

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
    
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    userSignUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    userSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passwordSignUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    varifyPasswordSignUpTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    varifyPasswordSignUpTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;

    [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:0.4];
    
    int smallScreen = 480;
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == smallScreen)
    {
        
        signUpButton.frame = CGRectMake(113, 229, signUpButton.frame.size.width, signUpButton.frame.size.height);
        
        userSignUpTextField.frame = CGRectMake(11, 24, userSignUpTextField.frame.size.width, userSignUpTextField.frame.size.height);
        
        emailTextField.frame = CGRectMake(11, 76, emailTextField.frame.size.width, emailTextField.frame.size.height);
        
        passwordSignUpTextField.frame = CGRectMake(11, 128, passwordSignUpTextField.frame.size.width, passwordSignUpTextField.frame.size.height);
        
        varifyPasswordSignUpTextField.frame = CGRectMake(11, 180, varifyPasswordSignUpTextField.frame.size.width, varifyPasswordSignUpTextField.frame.size.height);
        
    }
    
}

//----------------------------------------------------------
//
// Name: closeKeyBoard
//
// Purpose: closes the keyboard if you touch any free space
// in the view.
//
//----------------------------------------------------------

-(IBAction) closeKeyBoard:(UITapGestureRecognizer *)sender
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
// Purpose: When the user presses the sign-up button , this
// method creates the User record in Parse. Upon completion
// the user will be taken to the canvas screen.
//
//---------------------------------------------------------

-(IBAction) signUpUserPressed:(id)sender
{
    
    NSLog(@"pass = %@ var %@", passwordSignUpTextField.text, varifyPasswordSignUpTextField.text);
    
    if ([passwordSignUpTextField.text isEqual:varifyPasswordSignUpTextField.text])
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
    else
    {
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Password does not match verify passowrd!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [errorAlertView show];
        
        passwordSignUpTextField.text = nil;
        
        varifyPasswordSignUpTextField.text = nil;
        
    }
    
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
