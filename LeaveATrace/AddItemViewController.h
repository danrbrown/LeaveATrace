//
//  AddItemViewController.h
//  Checklists
//
//  Created by Matthijs Hollemans on 03-06-12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddItemViewController;
@class LeaveATraceItem;
 
@protocol AddItemViewControllerDelegate <NSObject>
 
-(void) addItemViewControllerDidCancel:(AddItemViewController *)controller;
 
-(void) addItemViewController:(AddItemViewController *)controller didFinishAddingItem:(LeaveATraceItem *)item;
 
@end

@interface AddItemViewController : UITableViewController <UITextFieldDelegate>

//Propertys
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (nonatomic, weak) id <AddItemViewControllerDelegate> delegate;
@property (nonatomic, weak) NSMutableArray *stuff;

//Actions
-(IBAction) cancel;
-(IBAction) done;

//Methods
-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL) textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
