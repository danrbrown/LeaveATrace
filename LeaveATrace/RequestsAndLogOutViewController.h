//
//  RequestsAndLogOutViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RequestsAndLogOutViewController : UITableViewController <UIAlertViewDelegate> {

    NSMutableArray *requests;
    NSString *userAccepted;
    NSString *userContact;
    PFQuery *query;
    
}

@property (weak, nonatomic) IBOutlet UITableView *requestsTable;

//Actions
-(IBAction)logOut:(id)sender;
-(IBAction)Accept:(id)sender;
-(IBAction)Decline:(id)sender;

//Methods
-(void) refreshView:(UIRefreshControl *)sender;
-(void) displayRequests;
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end
