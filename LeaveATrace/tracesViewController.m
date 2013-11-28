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
    [query whereKey:@"toUser" equalTo:[[PFUser currentUser]username]];
  //  [query whereKey:@"deliveredToUser" equalTo:@"NO"];
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
    
    NSString *deliveredToUser = [traceObject objectForKey:@"deliveredToUser"];
    
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

@end





