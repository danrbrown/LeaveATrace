//
//  tracesViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface tracesViewController : UITableViewController {
    
    PFQuery *query;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tracesTable;


@end
