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
    
    requests = [[NSMutableArray alloc] initWithCapacity:1000];
    [self performSelector:@selector(displayRequests)];

    
    [[[[[self tabBarController] tabBar] items]
      objectAtIndex:3] setBadgeValue:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;
    
}
-(void) displayRequests {
    
    //PFQuery *retrieveColors = [PFQuery queryWithClassName:@"tableViewData"];
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"contact" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"userAccepted" equalTo:@"NO"];
    [query orderByAscending:@"username"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            requests = [[NSMutableArray alloc] initWithArray:objects];
        }
        [requestsTable reloadData];
    }];
    
}



-(IBAction)logOut:(id)sender {
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LogOutSuccesful" sender:self];
    
}

- (void)refreshView:(UIRefreshControl *)sender {

    [sender endRefreshing];
}

//*********************Setup table of folder names ************************

//get number of sections in tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

//get number of rows by counting number of folders
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return requests.count;
}

//setup cells in tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //setup cell
    static NSString *CellIdentifier = @"RequestCell";
    RequestCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [requests objectAtIndex:indexPath.row];
    
    cell.cellTitle.text = [tempObject objectForKey:@"username"];
    
    return cell;
}


//user selects folder to add tag to
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell tapped");
}



@end
