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
    
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;
    
    
}

-(IBAction)logOut:(id)sender {
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LogOutSuccesful" sender:self];
    
}

- (void)refreshView:(UIRefreshControl *)sender {

    
    [sender endRefreshing];
}

@end
