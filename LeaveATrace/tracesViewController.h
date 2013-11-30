//
//  tracesViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

extern PFObject *traceObject;
extern NSString *traceObjectId;
extern PFQuery *query;
extern NSString *deliveredToUser;

@interface tracesViewController : UITableViewController {
    
    PFQuery *query;
    
    IBOutlet UIBarButtonItem *editButton;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tracesTable;

-(IBAction)Edit;

@end
