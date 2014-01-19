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
#import "ThreadViewController.h"
#import "traceCell.h"
#import "FirstPageViewController.h"
#import "CanvasViewController.h"
#import "AppDelegate.h"
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

@synthesize tracesTable,sending;

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
    
    [self performSelector:@selector(displayTraces)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blackColor];
    self.refreshControl = refreshControl;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];    
    
}

//----------------------------------------------------------------------------------
//
// Name: viewDidAppear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidAppear:(BOOL)animated
{
    
    NSLog(@"%lu", (unsigned long)(APP).tracesArray.count);
    
    [tracesTable reloadData];
    
    if ((APP).tracesArray.count == 0)
    {
        
        noTraces.text = @"You have no traces";
        
    }
    else
    {
        
        noTraces.text = @"";
        
    }
    
    tracesBadgeString = nil;
    
    [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:tracesBadgeString];
    
}


- (void) receiveTestNotification:(NSNotification *) notification
{
    
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"TestNotification"])
    {

        NSLog (@"Successfully received the test notification!");
        [tracesTable reloadData];

    }
    
}

//----------------------------------------------------------------------------------
//
// Name: draw
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) draw:(id)sender
{
    
    [self.tabBarController setSelectedIndex:1];
    
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
    [toUserQuery whereKey:@"toUserDisplay" equalTo:@"YES"];

    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [fromUserQuery whereKey:@"fromUser" equalTo:[[PFUser currentUser]username]];
    [fromUserQuery whereKey:@"fromUserDisplay" equalTo:@"YES"];

    query = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            (APP).tracesArray = [[NSMutableArray alloc] initWithArray:objects];
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastSentByDateTime" ascending:NO];
            
            [(APP).tracesArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            NSLog(@"displayTraces: count of traces %lu",(APP).tracesArray.count);
            
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
    
    return (APP).tracesArray.count;
    
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
    
    if (cell == nil)
    {
        
        cell = [[traceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    PFObject *traceObject = [(APP).tracesArray objectAtIndex:indexPath.row];

    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    NSString *tmpFromUser = [traceObject objectForKey:@"fromUser"];
    NSString *tmpLastSentBy = [traceObject objectForKey:@"lastSentBy"];
    NSString *tmpStatus = [traceObject objectForKey:@"status"];
    NSString *tmpOpenedString;
    
    //-------------------------------------------------------------------------------
    // Determine what is displayed on the Title line.  Should always be the "other"
    // user (i.e. not the Current user.
    //-------------------------------------------------------------------------------
    
    if ([tmpCurrentUser isEqualToString:tmpFromUser])
    {
        
        cell.usernameTitle.text = [traceObject objectForKey:@"toUser"];
        
    }
    else
    {
        
        cell.usernameTitle.text = tmpFromUser;
        
    }
    
    //-------------------------------------------------------------------------------
    // Determine the status: Opened, sent, or blank (i.e. just the time)
    // Display the approiate image and set the appropriate text.
    //-------------------------------------------------------------------------------

    deliveredToUser = [traceObject objectForKey:@"deliveredToUser"];
    
    if ([deliveredToUser isEqualToString:@"YES"])
    {
        
        tmpOpenedString = @"- Opened";
        
        if ([tmpCurrentUser isEqualToString:tmpLastSentBy])  // Current user sent it
        {
            
            cell.didNotOpenImage.image = [UIImage imageNamed:@"SentTrace.png"];
            cell.didNotOpenImage.frame = CGRectMake(8, 14, 47, 29);
            
        }
        else  // Other user sent it
        {
            
            tmpOpenedString = @"";
            
            cell.didNotOpenImage.image = [UIImage imageNamed:@"OpenedTrace.png"];
            cell.didNotOpenImage.frame = CGRectMake(6, 8, 50, 42);
            
        }
        
    }
    else
    {
        
        if ([tmpCurrentUser isEqualToString:tmpLastSentBy])  // Current user sent it
        {
            if ([tmpStatus isEqualToString:@"P"])  // Current user sent it
            {
                
                tmpOpenedString = @"- Sending...";
                [cell.didNotOpenImage setHidden:YES];
                [cell.sending startAnimating];
                
            }
            else
            {
                tmpOpenedString = @"- Sent";
                [cell.didNotOpenImage setHidden:NO];
                [cell.sending stopAnimating];
                
            }
            
            cell.didNotOpenImage.image = [UIImage imageNamed:@"SentNotOpened.png"];
            cell.didNotOpenImage.frame = CGRectMake(8, 14, 47, 29);
            
        }
        else  // Other user sent it
        {
            
            tmpOpenedString = @"";
            cell.didNotOpenImage.image = [UIImage imageNamed:@"NewTrace.png"];
            cell.didNotOpenImage.frame = CGRectMake(6, 14, 47, 29);
            
        }
    
    }
    
    //-------------------------------------------------------------------------------
    // Determine the display date. If the Trace happened today, then show only
    // the time. Otherwise show the entire date.
    //-------------------------------------------------------------------------------

    NSDate *updated = [traceObject objectForKey:@"lastSentByDateTime"];
    NSDate *currentdate = [NSDate date];
    
    NSDateFormatter *displayTimeFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *displayDayFormat = [[NSDateFormatter alloc] init];
    NSDateFormatter *displayDayAndTimeFormat = [[NSDateFormatter alloc] init];
 
    [displayTimeFormat setDateFormat:@"h:mm a"];
    [displayDayFormat setDateFormat:@"MM-dd-YYYY"];
    [displayDayAndTimeFormat setDateFormat:@"MMM dd, h:mm a"];
    
    NSString *tmpUpdatedDate = [NSString stringWithFormat:@"%@", [displayDayFormat stringFromDate:updated]];
    NSString *todaysDate = [NSString stringWithFormat:@"%@", [displayDayFormat stringFromDate:currentdate]];
    
    NSString *screenDate;
    NSString *combined;
    
    //-------------------------------------------------------------------------------
    // Set the string to be the full date or just the date & time
    //-------------------------------------------------------------------------------
    
    if ([tmpUpdatedDate isEqualToString:todaysDate])
    {
        
        screenDate = [NSString stringWithFormat:@"%@", [displayTimeFormat stringFromDate:updated]];
        
    }
    else
    {
        
        screenDate = [NSString stringWithFormat:@"%@", [displayDayAndTimeFormat stringFromDate:updated]];
        
    }
    
    //-------------------------------------------------------------------------------
    // Show the full date or just the date & time
    //-------------------------------------------------------------------------------

    if ([tmpCurrentUser isEqualToString:tmpLastSentBy])
    {
        
        combined = [NSString stringWithFormat:@"%@ %@", screenDate, tmpOpenedString];
        
    }
    else
    {
        
        combined = [NSString stringWithFormat:@"%@ %@", screenDate, tmpOpenedString];
        
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
    
    traceObject = [(APP).tracesArray objectAtIndex:indexPath.row];
 
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
    
    PFObject *tempObject = [(APP).tracesArray objectAtIndex:indexPath.row];
    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    
    NSString *tmpFromUser = [tempObject objectForKey:@"fromUser"];
    NSString *tmpToUser = [tempObject objectForKey:@"toUser"];
    
    if ([tmpCurrentUser isEqualToString:tmpFromUser])
        [tempObject setObject:@"NO"forKey:@"fromUserDisplay"];

    if ([tmpCurrentUser isEqualToString:tmpToUser])
        [tempObject setObject:@"NO"forKey:@"toUserDisplay"];
    
    //  See if the row should be deleted or updated. If both users deleted
    //  then delete from parse.  Else just update the delete flag
    
    NSString *tmpFromUserDisplay = [tempObject objectForKey:@"fromUserDisplay"];
    NSString *tmpToUserDisplay = [tempObject objectForKey:@"toUserDisplay"];
    
    if ([tmpFromUserDisplay isEqualToString:@"NO"] && [tmpToUserDisplay isEqualToString:@"NO"])
    {
        [tempObject deleteInBackground];
        NSLog(@"Delete row in parse");
    }
    else
    {
        [tempObject saveInBackground];
        NSLog(@"Delete one trace by updating");
    }
 
    [(APP).tracesArray removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    

}

@end







