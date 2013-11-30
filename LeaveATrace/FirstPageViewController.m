//
//  FirstPageViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 11/12/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "FirstPageViewController.h"

#import "CanvasViewController.h"

@interface FirstPageViewController ()

@end

@implementation FirstPageViewController

- (void)viewDidLoad
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    userLoggedIn = [defaults objectForKey:@"theUser"];
    
    if ([userLoggedIn isEqual:@"LoggedIn"]) {
        
        
        
        
        
    }
    

    
}

@end
