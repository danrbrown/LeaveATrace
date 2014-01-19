//
//  StartUpViewController.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/18/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "StartUpViewController.h"

@interface StartUpViewController ()

@end

@implementation StartUpViewController

-(void)viewDidLoad
{
  

    
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [self performSelector:@selector(defaults) withObject:nil afterDelay:1];
    
}

-(void) defaults
{
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpUsername = [traceDefaults objectForKey:@"username"];
    
    NSLog(@"username in defaults %@",tmpUsername);
    
    if ([tmpUsername length] != 0)
    {
        
        [self performSegueWithIdentifier:@"userAlreadyLoggedIn" sender:self];
        
    }
    else
    {
        
        NSLog(@"user needs to log in");
        
        [self performSegueWithIdentifier:@"userNeedsToLogIn" sender:self];
    }
    
}

@end
