//------------------------------------------------------------
//
//  traceCell.h
//  LeaveATrace
//
//  Created by Ricky Brown on 11/24/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Purpose: these are the labels and the images on the
//  cells and we decide what they are in the tableView class
//  called tracesViewController.
//
//------------------------------------------------------------

#import <UIKit/UIKit.h>

@interface traceCell : UITableViewCell

//Labels on the cell
@property (weak, nonatomic) IBOutlet UILabel *usernameTitle;
@property (weak, nonatomic) IBOutlet UILabel *dateAndTimeLabel;

//Images on the cell
@property (weak, nonatomic) IBOutlet UIImageView *didNotOpenImage;

@end
