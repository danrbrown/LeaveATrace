//----------------------------------------------------------------------------------
//
//  SelectAContactViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 11/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Purpose: This class is for displaying the list of contacts after the user
//  user has decided to send a Trace.  The user selects from the contact list
//  (only valid contacts) and then the Trace is sent to that user.
//----------------------------------------------------------------------------------

#import "SelectAContactViewController.h"
#import "tracesViewController.h"
#import "CanvasViewController.h"
#import "LeaveATraceItem.h"
#import "sendToCell.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

BOOL clearImage;

@interface SelectAContactViewController ()

@end

@implementation SelectAContactViewController

@synthesize validContactsTable;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: First method called. Simply allocates the array and then calls the
// method to display the list of valid contacts.
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveContactsLoadedNotification:)
                                                 name:@"ContactsLoadedNotification"
                                               object:nil];
    
    [self performSelector:@selector(displayValidContacts)];
    
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
    
    if (!(APP).CONTACTS_DATA_LOADED)
    {
        
        noSendTo.text = @"Loading...";
        [loadingValid startAnimating];
        
    }
    else if (validContacts.count == 0)
    {
        
        noSendTo.text = @"No one to send to";
        [loadingValid stopAnimating];
        
    }
    else
    {
        
        noSendTo.text = @"";
        [loadingValid stopAnimating];
        
    }
    
}

//----------------------------------------------------------------------------------

- (void) receiveContactsLoadedNotification:(NSNotification *) notification
{
    
    // [notification name] should always be @"ContactsLoadedNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"ContactsLoadedNotification"])
    {
        
        noSendTo.text = @"";
        
        [self displayValidContacts];
        
        [loadingValid stopAnimating];
        
        if ((APP).contactsArray.count == 0)
        {
            
            noSendTo.text = @"You have no Friends to send to";
            
        }
        
    }
    
}


//----------------------------------------------------------------------------------
//
// Name: displayValidContacts
//
// Purpose: This method queries the database for a list of valid contacts for the
// given user. We say 'valid contacts' because we don't want to show any that
// haven't been confirmed by the friend (i.e. they haven't accepted the friend
// request.
//
//----------------------------------------------------------------------------------

-(void) displayValidContacts
{
    
    NSString *tmpUserAccepted;
    NSInteger idx = 0;
    
    validContacts = [[NSMutableArray alloc] init];
    
    for (PFObject *friend in (APP).contactsArray)
    {
        tmpUserAccepted = [friend objectForKey:@"userAccepted"];
        if ([tmpUserAccepted isEqualToString:@"YES"])
        {
            
            [validContacts addObject:friend];
            
        }
        
        idx++;
        
    }
    
    [validContactsTable reloadData];
    
}

//----------------------------------------------------------------------------------
//
// Name: cancel
//
// Purpose:  This method is called if they press cancel on the table view. It should
// close the screen and go back to the drawing screen.
//
//----------------------------------------------------------------------------------

-(IBAction) cancel
{
    
    clearImage = NO;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name: numberOfSectionsInTableView
//
// Purpose:  Simply returns 1 because we only have 1 section.
//
//----------------------------------------------------------------------------------

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView:numberOfRowsInSection
//
// Purpose: Method returns the number of valid contacts.
//
//----------------------------------------------------------------------------------

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return validContacts.count;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView:cellForRowAtIndexPath
//
// Purpose:  This method displays the appropriate row from our array in a cell.
//
//----------------------------------------------------------------------------------

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ValidContactCell";
    
    sendToCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [validContacts objectAtIndex:indexPath.row];
    
    cell.sendToTitle.text = [tempObject objectForKey:@"contact"];
    
    return cell;
    
}

//----------------------------------------------------------------------------------
//
// Name: sendPushToAlliosUsers
//
// Purpose: This method is currently not being used, but leave it here for
// testing purposes. It will send a push to all ios users and we can use it to
// make sure the Push Notification framework is working.
//
//----------------------------------------------------------------------------------

-(void) sendPushToAlliosUsers
{
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    //  end push notification to query
    
    [PFPush sendPushMessageToQueryInBackground:pushQuery
    withMessage:@"Hello World from LeaveATrace!"];
    
}

//----------------------------------------------------------------------------------
//
// Name: sendPushToContact
//
// Purpose: Will send a push to a specifc user. It gets the Installation record
// for this user and then sends the push.
//
// To debug this incase it isn't working. There should be a row in the
// Installation object and the deviceToken should have a value (some long string).
// The 'user' field for that Installation record should be the 'objectId' in
// the User object for that user.
//
//----------------------------------------------------------------------------------

-(void) sendPushToContact:(NSDictionary *)dataParms
{
    
    NSString *pushRecipient = [dataParms objectForKey:@"friend"];
    NSString *newObjectId = [dataParms objectForKey:@"objectId"];
    
    NSLog(@"friend %@  object id %@",pushRecipient,newObjectId);
    
     NSString *pushMessage = [NSString stringWithFormat:@"%@ sent you a Trace!", [PFUser currentUser].username];

     PFQuery *userQuery = [PFUser query];
     [userQuery whereKey:@"username" equalTo:pushRecipient];
     PFUser *user = (PFUser *)[userQuery getFirstObject];
    
     NSString *friendLoggedIn = [user objectForKey:@"LoggedIn"];
    
    if ([friendLoggedIn isEqualToString:@"Y"])
    {
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:pushMessage, @"alert",
                              @"Trace",@"msgType",
                              newObjectId, @"objId",
                              pushRecipient, @"friend",nil];
                
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:user];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
    }

}

//----------------------------------------------------------------------------------
//
// Name: tableView:willSelectRowAtIndexPath
//
// Purpose: This method will determine which contact has been selected, and then
// send the image up to Parse for that person.
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    clearImage = YES;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    PFObject *tempObject = [validContacts objectAtIndex:indexPath.row];
    NSString *tempContact = [tempObject objectForKey:@"contact"];
    NSDate *currentDateTime = [NSDate date];

    PFObject *imageObject = [PFObject objectWithClassName:@"TracesObject"];
    
    [imageObject setObject:file forKey:@"image"];
    [imageObject setObject:[PFUser currentUser].username forKey:@"fromUser"];
    [imageObject setObject:@"YES" forKey:@"fromUserDisplay"];
    [imageObject setObject:[PFUser currentUser].username forKey:@"lastSentBy"];
    [imageObject setObject:currentDateTime forKey:@"lastSentByDateTime"];
    [imageObject setObject:tempContact forKey:@"toUser"];
    [imageObject setObject:@"YES" forKey:@"toUserDisplay"];
    [imageObject setObject:@"P"forKey:@"status"];
    
    [(APP).tracesArray insertObject:imageObject atIndex:0];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            [imageObject setObject:@"S"forKey:@"status"];
            [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    
                    NSString *newObjectId = [imageObject objectId];
                    [imageObject setObject:@"S"forKey:@"status"];
                    
                    NSDictionary *dataParms = [NSDictionary dictionaryWithObjectsAndKeys:tempContact, @"friend",newObjectId, @"objectId",nil];
                    
                    [self performSelectorInBackground:@selector(sendPushToContact:)
                                           withObject:dataParms];
                    
 //                   [self sendPushToContact:tempContact pushObjectId:newObjectId];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"SendTraceNotification"
                     object:self];
                    
                }
                else
                {
                    
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [errorAlertView show];
                    
                }
                
            }];
            
        }
        else
        {
            
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }
        
    }
    progressBlock:^(int percentDone)
    {
        
        NSLog(@"%d %% done", percentDone);
        
    }];

    return nil;
    
}

@end



