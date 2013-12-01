//
//  SelectAContactViewController.h
//  LeaveATrace
//
//  Created by Ricky Brown on 11/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanvasViewController.h"

extern BOOL clearImage;

@interface SelectAContactViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate> {
    
    NSMutableArray *validContacts;
    
}

@property (strong,nonatomic) NSMutableArray *filteredArray;
@property IBOutlet UISearchBar *SearchBar;

@property (weak, nonatomic) IBOutlet UITableView *validContactsTable;
@property(nonatomic, assign) CanvasViewController *canvasViewController;


@end
