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
#import "CanvasViewController.h"
#import "LeaveATraceItem.h"
#import "sendToCell.h"
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
    
    NSLog(@"in my new table view");
    
    validContacts = [[NSMutableArray alloc] initWithCapacity:1000];
    
    [self performSelector:@selector(displayValidContacts)];
    
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
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"userAccepted" equalTo:@"YES"];
    [query orderByAscending:@"contact"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            validContacts = [[NSMutableArray alloc] initWithArray:objects];
            
        }
        
        NSLog(@"Valid contacts %@",validContacts);
        
        [validContactsTable reloadData];
        
    }];
    
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
    
    NSLog(@"contact is: %@",cell.sendToTitle.text);
    
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

-(void) sendPushToContact:(NSString *)pushRecipient
{
    
     NSString *pushMessage = [NSString stringWithFormat:@"%@ sent you a Trace!", [PFUser currentUser].username];

     PFQuery *userQuery = [PFUser query];
     [userQuery whereKey:@"username" equalTo:pushRecipient];
     PFUser *user = (PFUser *)[userQuery getFirstObject];
        
     // Define a text message
     NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:pushMessage, @"alert", nil];
     
     // Prepare to send the push notification
     
     PFQuery *pushQuery = [PFInstallation query];
     [pushQuery whereKey:@"user" equalTo:user];
     
     // Send push notification to query
     PFPush *push = [[PFPush alloc] init];
     [push setQuery:pushQuery]; // Set our installation query
     [push setData:data];
     [push sendPushInBackground];
    
     NSLog(@"Just saved the installation - push going to %@",pushRecipient);
    
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
    
    PFObject *tempObject = [validContacts objectAtIndex:indexPath.row];
    NSString *tempContact = [tempObject objectForKey:@"contact"];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            PFObject *imageObject = [PFObject objectWithClassName:@"TracesObject"];
            
            [imageObject setObject:file forKey:@"image"];
            [imageObject setObject:[PFUser currentUser].username forKey:@"fromUser"];
            [imageObject setObject:[PFUser currentUser].username forKey:@"lastSentBY"];
            [imageObject setObject:tempContact forKey:@"toUser"];
            [imageObject setObject:@"NO"forKey:@"deliveredToUser"];
            
            [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    
                    [self sendPushToContact:tempContact];
                    [self.navigationController popViewControllerAnimated:YES];
                    
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
        
        NSLog(@"Uploaded: %d %%", percentDone);
        
    }];

    return nil;
    
}

@end



