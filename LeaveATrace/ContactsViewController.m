//
//  ContactsViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "ContactsViewController.h"
#import "CanvasViewController.h"
#import "AddItemViewController.h"
#import "LeaveATraceItem.h"
#import "Contact.h"
#import <Parse/Parse.h>

@interface ContactsViewController ()

@end

@implementation ContactsViewController {
    NSString *userAccepted;
    NSString *userContact;
    PFQuery *query;
}

- (void)viewDidLoad
{
    
    items = [[NSMutableArray alloc] initWithCapacity:1000];
    
    [super viewDidLoad];
    
    [self displayContacts];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    
    refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;
    
}

-(void) displayContacts {
    
    LeaveATraceItem *item = [[LeaveATraceItem alloc] init];
    
    //items = [[NSMutableArray alloc] initWithCapacity:1000];
    
    //Load users contacts
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [query orderByAscending:@"contact"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSLog(@"The find succeeded!");
            
            for (PFObject *myContacts in objects) {
                
                userContact = [myContacts objectForKey:@"contact"];
                userAccepted = [myContacts objectForKey:@"userAccepted"];
                
                item.text = userContact;
                item.userAccepted = userAccepted;
                
                if ([userAccepted isEqualToString:@"NO"]) {
                    
                    //item.text = [item.text stringByAppendingString:@"    (Pending)"];
                    
                }
                    
                [self addItemViewControllerNoDismiss:nil didFinishAddingItem:item];
                
                NSLog(@"%@",userContact);
                
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)refreshView:(UIRefreshControl *)sender {
    
    NSLog(@"Pulled down");
    
    NSUInteger x = [items count];
    NSLog(@"before removeAllObjects --> %lu",(unsigned long)x);
    
    [items removeAllObjects];

    x = [items count];
    NSLog(@"after removeAllObjects --> %lu",(unsigned long)x);

    //[self displayContacts];

    [sender endRefreshing];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger x = [items count];
    NSLog(@"here it is --> %lu",(unsigned long)x);
    
    return [items count];
}

- (void)configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(LeaveATraceItem *)item
{
    cell.textLabel.enabled = YES;
    if ([item.userAccepted isEqualToString:@"NO"]) {
        
        cell.detailTextLabel.text = @"Pending";
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = NO;
        
    } else {
        
        cell.detailTextLabel.text = @"Friend";
        cell.detailTextLabel.font = [UIFont fontWithName:@"Verdana Bold Italic" size:15.0f];
        cell.textLabel.enabled = YES;
        cell.detailTextLabel.textColor = [UIColor redColor];
        cell.userInteractionEnabled = YES;
        
    }
}

- (void)configureTextForCell:(UITableViewCell *)cell withChecklistItem:(LeaveATraceItem *)item
{
    cell.textLabel.text = item.text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChecklistItem"];
    
    LeaveATraceItem *item = [items objectAtIndex:indexPath.row];
    
    [self configureTextForCell:cell withChecklistItem:item];
    [self configureCheckmarkForCell:cell withChecklistItem:item];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [items removeObjectAtIndex:indexPath.row];
    
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)addItemViewControllerDidCancel:(AddItemViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addItemViewController:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item
{
    NSUInteger newRowIndex = [items count];
    [items addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addItemViewControllerNoDismiss:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item
{
    NSUInteger newRowIndex = [items count];
    [items addObject:item];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newRowIndex inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddItem"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        AddItemViewController *controller = (AddItemViewController *)navigationController.topViewController;
        controller.delegate = self;
    }
}


@end
