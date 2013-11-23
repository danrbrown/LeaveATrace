//
//  RequestsAndLogOutViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "RequestsAndLogOutViewController.h"
#import "LeaveATraceRequest.h"
#import <Parse/Parse.h>

@interface RequestsAndLogOutViewController ()

@end

@implementation RequestsAndLogOutViewController 

- (void)viewDidLoad
{
    
    requests = [[NSMutableArray alloc] initWithCapacity:1000];
    [self displayRequests];

    
    [[[[[self tabBarController] tabBar] items]
      objectAtIndex:3] setBadgeValue:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;
    
}
-(void) displayRequests {
    
    //LeaveATraceRequest *request = [[LeaveATraceRequest alloc] init];
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"contact" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"userAccepted" equalTo:@"NO"];
    [query orderByAscending:@"username"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSLog(@"The find for requests succeeded!");
            
            for (PFObject *myRequests in objects) {

                LeaveATraceRequest *request = [[LeaveATraceRequest alloc] init];
                
                userContact = [myRequests objectForKey:@"username"];
                
                request.text = userContact;
                NSLog(@"%@",userContact);
               
                //[self addRequestViewControllerNoDismiss:nil didFinishAddingItem:request];
                
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}



-(IBAction)logOut:(id)sender {
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"LogOutSuccesful" sender:self];
    
}

- (void)refreshView:(UIRefreshControl *)sender {

    [sender endRefreshing];
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LeaveATraceRequest *request = [requests objectAtIndex:indexPath.row];
    if (request.checked) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    LeaveATraceRequest *request = [requests objectAtIndex:indexPath.row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1000]; label.text = request.text;
    
    [self configureCheckmarkForCell:cell atIndexPath:indexPath]; return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    LeaveATraceRequest *request = [requests objectAtIndex:indexPath.row];
    request.checked = !request.checked;
    
    [self configureCheckmarkForCell:cell atIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
