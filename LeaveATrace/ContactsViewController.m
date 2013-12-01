//----------------------------------------------------------------------------------
//
//  ContactsViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Purpose: This file of class tableView displays each
//  contact associated with this user.
//
//----------------------------------------------------------------------------------

#import "ContactsViewController.h"
#import "CanvasViewController.h"
#import "AddItemViewController.h"
#import "LeaveATraceItem.h"
#import <Parse/Parse.h>

@interface ContactsViewController ()

@end

@implementation ContactsViewController

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
    
    items = [[NSMutableArray alloc] initWithCapacity:1000];
    
    [self displayContacts];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor redColor];
    self.refreshControl = refreshControl;
    
}

//----------------------------------------------------------------------------------
//
// Name: displayContacts
//
// Purpose: This method retrieves the list of contacts for this user from Parse and
// displays them on the screen. It also loads up our array of contacts.
// DB - redo this method more efficiently by following the example in
// ThreadViewController.m
//
//----------------------------------------------------------------------------------

-(void) displayContacts
{
    
    LeaveATraceItem *item = [[LeaveATraceItem alloc] init];
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [query orderByAscending:@"contact"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            NSLog(@"The find succeeded!");
            
            for (PFObject *myContacts in objects)
            {
                
                userContact = [myContacts objectForKey:@"contact"];
                userAccepted = [myContacts objectForKey:@"userAccepted"];
                
                item.text = userContact;
                item.userAccepted = userAccepted;
                    
                [self addItemViewControllerNoDismiss:nil didFinishAddingItem:item];
                
                NSLog(@"%@",userContact);
                
            }
            
        }
        else
        {
    
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name: refreshView
//
// Purpose: This is called when the user "pulls down" to refresh the view.
// However this current version (12/1/2013) is not working.
//
//----------------------------------------------------------------------------------

-(void) refreshView:(UIRefreshControl *)sender
{
    
    NSUInteger x = [items count];
    
    x = [items count];
    
    [items removeAllObjects];

    [sender endRefreshing];
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView numberOfRowsInSection
//
// Purpose: Method is one of the many called for navigating around the tableview.
// It runs the number of items in the array.
//
//----------------------------------------------------------------------------------

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [items count];
    
}

//----------------------------------------------------------------------------------
//
// Name: configureCheckmarkForCell
//
// Purpose: Determines if the user is a 'friend' or if the request is still
// 'pending' and appends the appropriate text next to the contact name.
//
//----------------------------------------------------------------------------------

-(void) configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(LeaveATraceItem *)item
{
    
    cell.textLabel.enabled = YES;
    
    if ([item.userAccepted isEqualToString:@"NO"])
    {
        
        cell.detailTextLabel.text = @"Pending";
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
        
    }
    else
    {
        
        cell.detailTextLabel.text = @"Friend";
        cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana Bold Italic" size:15.0f];
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.textLabel.enabled = YES;
        cell.userInteractionEnabled = YES;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: configureTextForCell withChecklistItem
//
// Purpose: Method is one of the many called for navigating around the tableview.
// This method updates a cell with a contact name.
//
//----------------------------------------------------------------------------------

-(void) configureTextForCell:(UITableViewCell *)cell withChecklistItem:(LeaveATraceItem *)item
{
    
    cell.textLabel.text = item.text;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView cellForRowAtIndexPath
//
// Purpose: Method is one of the many called for navigating around the tableview.
// This method updates a given cell on the table view.
//
//----------------------------------------------------------------------------------

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    LeaveATraceItem *item = [items objectAtIndex:indexPath.row];
    
    [self configureTextForCell:cell withChecklistItem:item];
    
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    
    return cell;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView willSelectRowAtIndexPath
//
// Purpose: Method is one of the many called for navigating around the tableview.
// We don't want any action to take place when the user touches a row, so we
// simply return nil.
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
    
}

//----------------------------------------------------------------------------------
//
// Name: tableView commitEditingStyle
//
// Purpose: Method for deleting a contact from the array and the database.
//
//----------------------------------------------------------------------------------

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [items removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    // DB. Need code to delete from the contact from Parse.
    
}

//----------------------------------------------------------------------------------
//
// Name: addItemViewControllerDidCancel
//
// Purpose: This is called if a user goes to add a new contact, but then hits
// cancel.
//
//----------------------------------------------------------------------------------

-(void) addItemViewControllerDidCancel:(AddItemViewController *)controller
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name: addItemViewController
//
// Purpose: This method is used when a user is adding a new contact. It will take
// the content from the pop-up screen and add it to our array. It also closes
// the pop-up screen and leaves the user on the tableview screen.
//
//----------------------------------------------------------------------------------

-(void) addItemViewController:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item
{
    
    NSUInteger newRowIndex = [items count];
    
    [items addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose: Method is one of the many called for navigating around the tableview.
// This is used to display contacts from the database on the tableview. We called
// it 'noDismiss' because it's the same as the method above, but we're not
// dismissing a screen.
//
//----------------------------------------------------------------------------------

-(void) addItemViewControllerNoDismiss:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item
{
    
    NSUInteger newRowIndex = [items count];
    
    [items addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

//----------------------------------------------------------------------------------
//
// Name: prepareForSegue
//
// Purpose: Method to segue to the screen to add a new contact.
//
//----------------------------------------------------------------------------------

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"AddItem"])
    {
        
        UINavigationController *navigationController = segue.destinationViewController;
        AddItemViewController *controller = (AddItemViewController *)navigationController.topViewController;
        controller.delegate = self;
        
    }
    
}


@end
