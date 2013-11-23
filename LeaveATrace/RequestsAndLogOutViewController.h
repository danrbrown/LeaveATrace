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
    
    NSMutableArray *requests;
    NSString *userAccepted;
    NSString *userContact;
    PFQuery *query;

    
}

-(IBAction)logOut:(id)sender;




@property (nonatomic, strong) NSMutableArray *usersRequsts;

@end
