//
//  tracesViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

//Global variables
extern PFObject *traceObject;
extern NSString *traceObjectId;
extern PFQuery *query;
extern NSString *deliveredToUser;
extern NSMutableArray *traces;

@interface tracesViewController : UITableViewController {
    
    PFQuery *query;
    
    NSMutableArray *traces;
    
    IBOutlet UIBarButtonItem *editButton;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tracesTable;

//Actions for view
-(IBAction) edit;

//Methods for view
-(void) refreshView:(UIRefreshControl *)sender;
-(void) displayTraces;
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
