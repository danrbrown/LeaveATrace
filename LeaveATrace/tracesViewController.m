//----------------------------------------------------------------------------------
//
//  tracesViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Purpose: this file of class tableView displays each
//  thread the user is involved in.
//
//----------------------------------------------------------------------------------

#import "tracesViewController.h"
#import "traceCell.h"
#import "CanvasViewController.h"
#import <Parse/Parse.h>

//Global variables
UIImage *Threadimage;
NSData *data;
PFObject *traceObject;
NSString *traceObjectId;
PFQuery *query;
NSString *deliveredToUser;

@interface tracesViewController ()

@end

@implementation tracesViewController

@synthesize tracesTable;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: Openining method for this screen, where we allocate the traces array.
// We also call the method to display the traces for this user.
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{

    traces = [[NSMutableArray alloc] initWithCapacity:1000];
    
    [self performSelector:@selector(displayTraces)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor redColor];
    self.refreshControl = refreshControl;
    
    [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setBadgeValue:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name: refreshView
//
// Purpose: Method called if the user "pulls down" on the table view. We then call
// the method to display the traces.
//
//----------------------------------------------------------------------------------

-(void) refreshView:(UIRefreshControl *)sender
{
    
    [self displayTraces];
    
    [sender endRefreshing];
    
}

//----------------------------------------------------------------------------------
//
// Name: displayTraces
//
// Purpose: This method queries the Parse database to get all the traces for this
// user. The traces are put in our array.
//
//----------------------------------------------------------------------------------

-(void) displayTraces
{
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [toUserQuery whereKey:@"toUser" equalTo:[[PFUser currentUser]username]];

    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [fromUserQuery whereKey:@"fromUser" equalTo:[[PFUser currentUser]username]];

    query = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            traces = [[NSMutableArray alloc] initWithArray:objects];
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
            [traces sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            //NSLog(@"traces %@",traces);
            
        }
        
        [tracesTable reloadData];
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView numberOfRowsInSection
//
// Purpose: Part of the standard tableview methods, this will return the number
// of rows for this section.
//
//----------------------------------------------------------------------------------

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return traces.count;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView cellForRowAtIndexPath
//
// Purpose: This method is part of the process that displays all the traces. A trace
// can be originated from the user, or sent to the user. In either case we show
// the other person's name. So we have to do a little logic to determine if we show
// the "to" user or the "from" user.
//
//----------------------------------------------------------------------------------

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"traceItem";
    traceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *traceObject = [traces objectAtIndex:indexPath.row];

    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    NSString *tmpFromUser = [traceObject objectForKey:@"fromUser"];
    NSString *tmpLastSentBY = [traceObject objectForKey:@"lastSentBY"];
    
    if ([tmpCurrentUser isEqualToString:tmpFromUser])
    {
        
        cell.usernameTitle.text = [traceObject objectForKey:@"toUser"];
        
    }
    else
    {
        
        cell.usernameTitle.text = tmpFromUser;
        
    }
    
    deliveredToUser = [traceObject objectForKey:@"deliveredToUser"];
    
    if ([deliveredToUser isEqualToString:@"YES"])
    {
        
        //cell.didNotOpenImage.hidden = YES; //DTRB
        //cell.didNotOpenImage.image = [UIImage imageNamed:@"OpenedTraceIcon.png"];
        
        
    }
    else
    {
        
        //cell.didNotOpenImage.hidden = NO; //DTRB
        cell.didNotOpenImage.image = [UIImage imageNamed:@"NewTraceIcon.png"];
        
    }
    
    //NSDate *updated = [traceObject createdAt];
    NSDate *updated = [traceObject updatedAt];
    NSDate *currentdate = [NSDate date];
    
    NSDateFormatter *displayTimeFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *displayDayFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *displayDayAndTimeFormat = [[NSDateFormatter alloc] init];
 
    [displayTimeFormat setDateFormat:@"h:mm a"];
    [displayDayFormat setDateFormat:@"MM-dd-YYYY"];
    [displayDayAndTimeFormat setDateFormat:@"MMM dd"];
    
    NSString *tmpUpdatedDate = [NSString stringWithFormat:@"%@", [displayDayFormat stringFromDate:updated]];
    NSString *todaysDate = [NSString stringWithFormat:@"%@", [displayDayFormat stringFromDate:currentdate]];
    
    NSString *screenDate;
    NSString *combined;
    
    if ([tmpUpdatedDate isEqualToString:todaysDate])
    {
        
        screenDate = [NSString stringWithFormat:@"%@", [displayTimeFormat stringFromDate:updated]];
        
    }
    else
    {
        
        screenDate = [NSString stringWithFormat:@"%@", [displayDayAndTimeFormat stringFromDate:updated]];
        
    }
    
    if ([tmpCurrentUser isEqualToString:tmpLastSentBY])
    {
        
        combined = [NSString stringWithFormat:@"%@ - Sent", screenDate];
        
    }
    else
    {
        
        combined = [NSString stringWithFormat:@"%@ - Received", screenDate];
        
    }
    
    cell.dateAndTimeLabel.text = combined;

    return cell;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView willSelectRowAtIndexPath
//
// Purpose: This will be called when the user selects a trace. We set our global
// variable based on the selection, and then we segue to the thread canvas screen.
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    traceObject = [traces objectAtIndex:indexPath.row];
 
    traceObjectId = [traceObject objectId];
    
    [self performSegueWithIdentifier:@"TraceThread" sender:self];
    
    return nil;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView commitEditingStyle
//
// Purpose: This method is used to delete a trace from the tableview. This will
// also update the array and trace accordingly.
//
//----------------------------------------------------------------------------------

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [traces removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // DB need to put in code/method to update the row from Parse. More thought needed on how to
    // design and implement this.

}

//----------------------------------------------------------------------------------
//
// Name: edit
//
// Purpose: This is part of the "delete trace" process. It is called when the user
// presses the 'edit' button.
//
//----------------------------------------------------------------------------------

-(IBAction) edit
{
    
    if (self.editing)
    {
        
        editButton.title = @"Edit";
        
        editButton.tintColor = [UIColor whiteColor];
        
        [super setEditing:NO animated:YES];
        
    }
    else
    {
        
        editButton.title = @"Done";
        
        editButton.tintColor = [UIColor redColor];
        
        [super setEditing:YES animated:YES];
        
    }
    
}

@end







