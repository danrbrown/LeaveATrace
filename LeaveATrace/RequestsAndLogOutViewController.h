//
//  RequestsAndLogOutViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface RequestsAndLogOutViewController : UITableViewController {

    NSString *userAccepted;
    NSString *userContact;
    PFQuery *query;
    
}

-(IBAction)logOut:(id)sender;
-(IBAction)Accept:(id)sender;
-(IBAction)Decline:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *requestsTable;

@end
