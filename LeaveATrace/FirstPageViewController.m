//----------------------------------------------------------------
//
//  FirstPageViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 11/12/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Perpose: this file of class ViewController is the first screen
//  that the user sees if he logs out or is the first time using
//  the app. It has two options log in & sign up. 
//
//----------------------------------------------------------------

#import "FirstPageViewController.h"

#import "CanvasViewController.h"

@interface FirstPageViewController ()

@end

@implementation FirstPageViewController

//---------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: when the screen opens and you are logged in
// it will skip this screen and go to the drawing screen
// in the app.
//
//---------------------------------------------------------

- (void)viewDidLoad
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userLoggedIn = [defaults objectForKey:@"theUser"];
    
    if ([userLoggedIn isEqual:@"LoggedIn"])
    {
        
        //DTRB / DB
        
    }
    
}

@end


