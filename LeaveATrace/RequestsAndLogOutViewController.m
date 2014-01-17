//----------------------------------------------------------------------------------
//
//  RequestsAndLogOutViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//
//  Purpose:
//
//----------------------------------------------------------------------------------

#import "RequestsAndLogOutViewController.h"
#import "LeaveATraceRequest.h"
#import "CanvasViewController.h"
#import "RequestCell.h"
#import <Parse/Parse.h>

@interface RequestsAndLogOutViewController ()

@end

@implementation RequestsAndLogOutViewController

@synthesize requestsTable; 

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{

    // DB move this to log out method which currently isn't working
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    [traceDefaults setObject:@"" forKey:@"username"];
    [traceDefaults setObject:@"" forKey:@"password"];
    [traceDefaults synchronize];
    
    requests = [[NSMutableArray alloc] initWithCapacity:100];
    [self performSelector:@selector(displayRequests)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blackColor];
    self.refreshControl = refreshControl;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    badgeString = nil;
    
    [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:badgeString];
    
    [self performSelector:@selector(displayRequests)];
    
    [requestsTable reloadData];
    
    if (requests.count == 0)
    {
        
        noRequests.text = @"No requests right now";
        
    }
    else
    {
        
        noRequests.text = @"";
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) refreshView:(UIRefreshControl *)sender
{
    
    [self displayRequests];
    
    [sender endRefreshing];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) displayRequests
{
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    
    [query whereKey:@"contact" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"userAccepted" equalTo:@"NO"];
    [query orderByAscending:@"contact"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            requests = [[NSMutableArray alloc] initWithArray:objects];
            
        }
        
        [requestsTable reloadData];
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) Accept:(id)sender
{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    PFObject *tempObject = [requests objectAtIndex:indexPath.row];
    
    NSString *name = [tempObject objectForKey:@"username"];
    
    // Insert the new row for the new friend relationship
    
    PFObject *newContact = [PFObject objectWithClassName:@"UserContact"];
    
    [newContact setObject:[PFUser currentUser].username forKey:@"username"];
    [newContact setObject:name forKey:@"contact"];
    [newContact setObject:@"YES" forKey:@"userAccepted"];
    
    [newContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!succeeded)
        {
            
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
        
        if (!error)
        {
            
            [objects setObject:@"YES" forKey:@"userAccepted"];
            [objects saveInBackground];
            
        }
        else
        {
           
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
        
    }];

    // Now delete the row out of the array and off the screen
    
    [requests removeObjectAtIndex:indexPath.row];
    
    [requestsTable reloadData];
    
    NSString *acceptedMessage = [NSString stringWithFormat:@"You are now friends with %@!", name];
    
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:acceptedMessage message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [errorAlertView show];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) Decline:(id)sender
{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    PFObject *tempObject = [requests objectAtIndex:indexPath.row];
    
    [tempObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            [requests removeObjectAtIndex:indexPath.row];
            
            [requestsTable reloadData];
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Why can't we all be friends?" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
        }
        
        if (error)
        {
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error declining, please try again." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
            
            [errorAlertView show];
            
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return requests.count;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"RequestCell";
    
    RequestCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [requests objectAtIndex:indexPath.row];
    
    cell.cellTitle.text = [tempObject objectForKey:@"username"];
        
    return cell;
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
    
}

@end
