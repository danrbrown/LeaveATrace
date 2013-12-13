//
//  ContactsViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddItemViewController.h"
#import <Parse/Parse.h>

@interface ContactsViewController : UITableViewController <AddItemViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    //Variables
    NSMutableArray *items;
    NSMutableArray *results;
    NSString *userAccepted;
    NSString *userContact;
    PFQuery *query;
    NSArray *indices;
    
}

//Propertys
@property (weak, nonatomic) IBOutlet UITableView *contactsView;
@property (strong, nonatomic) NSDictionary *names;
@property (strong, nonatomic) NSArray *keys;
@property IBOutlet UISearchBar *SearchBar;
@property (nonatomic, weak) id <AddItemViewControllerDelegate> delegate;

//Methods
-(void) displayContacts;
-(void) refreshView:(UIRefreshControl *)sender;
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(void) configureCheckmarkForCell:(UITableViewCell *)cell withChecklistItem:(NSString *)isAFriend;
-(void) configureTextForCell:(UITableViewCell *)cell withChecklistItem:(LeaveATraceItem *)item;
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPathindexPath;
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
-(void) addItemViewControllerDidCancel:(AddItemViewController *)controller;
-(void) addItemViewController:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item;
-(void) addItemViewControllerNoDismiss:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item;
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
