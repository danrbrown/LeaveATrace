//
//  SelectAContactViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 11/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "SelectAContactViewController.h"
#import "LeaveATraceItem.h"
#import "RequestCell.h"
#import <Parse/Parse.h>


@interface SelectAContactViewController ()

@end

@implementation SelectAContactViewController{
    NSString *userAccepted;
    NSString *userContact;
    PFQuery *query;
}

@synthesize validContactsTable;
@synthesize selectedButton, outputlabel;


- (void) viewDidLoad
{
    NSLog(@"in my new table view");
    
    validContacts = [[NSMutableArray alloc] initWithCapacity:1000];
    
    [self performSelector:@selector(displayValidContacts)];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor blueColor];
    self.refreshControl = refreshControl;



}

-(void) displayValidContacts {
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"userAccepted" equalTo:@"YES"];
    [query orderByAscending:@"contact"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            validContacts = [[NSMutableArray alloc] initWithArray:objects];
        }
        NSLog(@"Valid contacts %@",validContacts);
        [validContactsTable reloadData];
    }];
    
}

- (void)refreshView:(UIRefreshControl *)sender {
    
    [self displayValidContacts];
    [sender endRefreshing];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return validContacts.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ValidContactCell";
    
    RequestCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [validContacts objectAtIndex:indexPath.row];
    
    cell.cellTitle.text = [tempObject objectForKey:@"username"];
    NSLog(@"%@",cell.cellTitle.text);
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}



//****BELOW WAS HERE BY DEFAULT

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
