//
//  tracesViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "tracesViewController.h"

#import "traceCell.h"

#import "CanvasViewController.h"

#import <Parse/Parse.h>

UIImage *Threadimage;
NSData *data;
PFObject *traceObject;
NSString *traceObjectId;
PFQuery *query;
NSString *deliveredToUser;

@interface tracesViewController ()

@end

@implementation tracesViewController {
    
    NSMutableArray *traces;
    
}

@synthesize tracesTable;

- (void)viewDidLoad
{

    traces = [[NSMutableArray alloc] initWithCapacity:1000];
    [self performSelector:@selector(displayTraces)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor redColor];
    self.refreshControl = refreshControl;
    
    [[[[[self tabBarController] tabBar] items]
      objectAtIndex:1] setBadgeValue:nil];
    
}

- (void)refreshView:(UIRefreshControl *)sender {
    
    [self displayTraces];
    [sender endRefreshing];
}

-(void) displayTraces {
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [toUserQuery whereKey:@"toUser" equalTo:[[PFUser currentUser]username]];

    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [fromUserQuery whereKey:@"fromUser" equalTo:[[PFUser currentUser]username]];

    query = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            traces = [[NSMutableArray alloc] initWithArray:objects];
            NSLog(@"traces %@",traces);
        }
        [tracesTable reloadData];
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return traces.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"traceItem";
    
    traceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *traceObject = [traces objectAtIndex:indexPath.row];

    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    NSString *tmpFromUser = [traceObject objectForKey:@"fromUser"];
    
    if ([tmpCurrentUser isEqualToString:tmpFromUser]) {
        
        cell.usernameTitle.text = [traceObject objectForKey:@"toUser"];
        
    } else {
        
        cell.usernameTitle.text = tmpFromUser;
        
    }
    
   // cell.usernameTitle.text = [traceObject objectForKey:@"fromUser"];
    
    deliveredToUser = [traceObject objectForKey:@"deliveredToUser"];
    
    if ([deliveredToUser isEqualToString:@"YES"]) {
        
        cell.didNotOpenImage.hidden = YES;
        
    } else {
        
        cell.didNotOpenImage.hidden = NO;
        
    }

    
    NSDate *updated = [traceObject createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mm a"];
    cell.dateAndTimeLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:updated]];
    
    
    
    return cell;
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"i just clicked the trace");
    
    traceObject = [traces objectAtIndex:indexPath.row];
    traceObjectId = [traceObject objectId];
    [self performSegueWithIdentifier:@"TraceThread" sender:self];
    return nil;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [traces removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

}

-(IBAction)Edit {
    
    if (self.editing) {
        editButton.title = @"Edit";
        editButton.tintColor = [UIColor whiteColor];
        [super setEditing:NO animated:YES];
    } else {
        editButton.title = @"Done";
        editButton.tintColor = [UIColor redColor];
        [super setEditing:YES animated:YES];
    }
}

@end


