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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ContactsViewController ()

@end

@implementation ContactsViewController

@synthesize contactsView;

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
    
    items = [[NSMutableArray alloc] initWithCapacity:100];
    
    alphabetsArray =[[NSMutableArray alloc]initWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil];

    
    [self performSelector:@selector(displayContacts)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blackColor];
    self.refreshControl = refreshControl;
    
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
    
    [self performSelector:@selector(displayContacts)];
    
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
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            [items addObject:@"default"];
            
            items = [[NSMutableArray alloc] initWithArray:objects];
            
            NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"contact" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [items sortUsingDescriptors:[NSArray arrayWithObject:sort1]];
            
        }
        else
        {
    
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
        
        [contactsView reloadData];
        
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
    
    [self displayContacts];
    
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
    
    return items.count;
    
}

//----------------------------------------------------------------------------------
//
// Name: configureCheckmarkForCell
//
// Purpose: Determines if the user is a 'friend' or if the request is still
// 'pending' and appends the appropriate text next to the contact name.
//
//----------------------------------------------------------------------------------

-(void) configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(NSString *)isAFriend
{
    
    cell.textLabel.enabled = YES;
    
    if ([isAFriend isEqualToString:@"NO"])
    {
        
        cell.detailTextLabel.text = @"Pending";
        cell.detailTextLabel.enabled = NO;
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
        
    }
    else
    {
        
        cell.detailTextLabel.text = @"Friend";
        cell.detailTextLabel.enabled = YES;
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
    // break here
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    PFObject *item = [items objectAtIndex:indexPath.row];
    NSString *tmpUserContact = [item objectForKey:@"contact"];
    NSString *tmpUserAccepted = [item objectForKey:@"userAccepted"];
    
    cell.textLabel.text = tmpUserContact;
    
    [self configureCheckmarkForCell:cell withChecklistItem:tmpUserAccepted];
    
    return cell;
    
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
    
    //  Need a better way to do this. Right now we're going to the database. But we really should simply
    //  add a PFObject to our array. How do you do this? DB
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self displayContacts];

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
        controller.stuff = items;
    }
    
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

//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//    return [alphabetsArray count];
//    
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    
//    return alphabetsArray;
//    
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    
//    return [alphabetsArray objectAtIndex:section];
//    
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//
////    return <yourSectionIndexForTheSectionForSectionIndexTitle >;
//    NSLog(@"title %@, indexpath %ld", title, (long)index);
//
//    return index;
//
//}

@end




