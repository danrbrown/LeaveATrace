//
//  RequestsAndLogOutViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "RequestsAndLogOutViewController.h"
#import <Parse/Parse.h>

@interface RequestsAndLogOutViewController ()

@end

@implementation RequestsAndLogOutViewController

- (void)viewDidLoad
{
    
    
    
    
    
}

-(IBAction)logOut:(id)sender {
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LogOutSuccesful" sender:self];
    
}

@end
