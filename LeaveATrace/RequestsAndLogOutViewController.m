//
//  RequestsAndLogOutViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "RequestsAndLogOutViewController.h"
#import "LeaveATraceRequest.h"
#import "RequestCell.h"
#import <Parse/Parse.h>

@interface RequestsAndLogOutViewController ()

@end

@implementation RequestsAndLogOutViewController {
    
    NSMutableArray *requests;
    
}

@synthesize requestsTable;

- (void)viewDidLoad
{
    
    [[[[[self tabBarController] tabBar] items]
      objectAtIndex:3] setBadgeValue:nil];
    
    requests = [[NSMutableArray alloc] initWithCapacity:1000];
    [self performSelector:@selector(displayRequests)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;
    
}

-(void) displayRequests {
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"contact" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"userAccepted" equalTo:@"NO"];
    [query orderByAscending:@"contact"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            requests = [[NSMutableArray alloc] initWithArray:objects];
        }
        [requestsTable reloadData];
    }];
    
}

-(IBAction)Accept:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    NSLog(@"cell tapped on %li ", (long)indexPath.row);
    
    PFObject *tempObject = [requests objectAtIndex:indexPath.row];
    NSString *name;
    
    name = [tempObject objectForKey:@"username"];
    NSLog(@"Name on row --> %@", name);
    
    // Insert the new row for the new friend relationship
    
    PFObject *newContact = [PFObject objectWithClassName:@"UserContact"];
    [newContact setObject:[PFUser currentUser].username forKey:@"username"];
    [newContact setObject:name forKey:@"contact"];
    [newContact setObject:@"YES" forKey:@"userAccepted"];
    
    [newContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)  {
        
        if (!succeeded){
            
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
        }
    }];

    // Now update the existing row and set the boolean flat to YES

    query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"contact" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"username" equalTo:name];
    [query whereKey:@"userAccepted" equalTo:@"NO"];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * objects, NSError *error) {
        if (!error) {
            
            NSLog(@"The Other Row succeeded!");
            [objects setObject:@"YES" forKey:@"userAccepted"];
            [objects saveInBackground];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    
    // Now delete the row out of the array and off the screen
    
    [requests removeObjectAtIndex:indexPath.row];
    [requestsTable reloadData];
    
}

-(IBAction)Decline:(id)sender {
    
    NSLog(@"User Declined");
    
}

-(IBAction)logOut:(id)sender {
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LogOutSuccesful" sender:self];
    
}

- (void)refreshView:(UIRefreshControl *)sender {

    [sender endRefreshing];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return requests.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RequestCell";
    
    RequestCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [requests objectAtIndex:indexPath.row];
    
    cell.cellTitle.text = [tempObject objectForKey:@"username"];
    NSLog(@"%@",cell.cellTitle.text);
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}



@end
