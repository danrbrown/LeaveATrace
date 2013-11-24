//
//  tracesViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "tracesViewController.h"

#import "traceCell.h"

#import <Parse/Parse.h>

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
    refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;
    
}

- (void)refreshView:(UIRefreshControl *)sender {
    
    [self displayTraces];
    [sender endRefreshing];
}

-(void) displayTraces {
    
    query = [PFQuery queryWithClassName:@"TracesObject"];
    [query whereKey:@"fromUser" equalTo:[[PFUser currentUser]username]];
    [query orderByDescending:@"createdAt"];
    
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
    
    cell.usernameTitle.text = [traceObject objectForKey:@"fromUser"];
    
    //cell.dateAndTimeLabel.text = [traceObject objectForKey:@"createdAt"];
    
    NSDate *updated = [traceObject createdAt];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE, MMM d, h:mm a"];
    cell.dateAndTimeLabel.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:updated]];

    
    
    
    return cell;
    
}

@end
