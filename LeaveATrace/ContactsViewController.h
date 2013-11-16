//
//  ContactsViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddItemViewController.h"

@interface ContactsViewController : UITableViewController <AddItemViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong,nonatomic) NSMutableArray *filteredArray;
@property IBOutlet UISearchBar *SearchBar;
@property (nonatomic, weak) id <AddItemViewControllerDelegate> delegate;

@end
