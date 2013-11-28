//
//  AddItemViewController.m
//  Checklists
//
//  Created by Matthijs Hollemans on 03-06-12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//

#import "AddItemViewController.h"
#import "LeaveATraceItem.h"
#import "ContactsViewController.h"
#import "CanvasViewController.h"
#import <Parse/Parse.h>

@interface AddItemViewController ()

@end

@implementation AddItemViewController {
    
}

@synthesize textField;
@synthesize doneBarButton;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    textField.autocorrectionType = FALSE;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    [self.textField becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancel
{
    [self.delegate addItemViewControllerDidCancel:self];
}
 
- (IBAction)done
{          
    LeaveATraceItem *item = [[LeaveATraceItem alloc] init];
    item.text = self.textField.text;
    item.checked = NO;
    item.userAccepted = @"NO";
    
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:item.text];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {

            PFObject *userContact = [PFObject objectWithClassName:@"UserContact"];
            [userContact setObject:[PFUser currentUser].username forKey:@"username"];
            [userContact setObject:item.text forKey:@"contact"];
            [userContact setObject:@"NO" forKey:@"userAccepted"];
    
            [userContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
                if (succeeded){
            
                    [self.delegate addItemViewController:self didFinishAddingItem:item];
            
            
                } else {
            
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:  errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [errorAlertView show];
            
            
                }
            }];
            
        } else {
            
            NSString *errorString = @"User not found";
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errorString message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }
    }];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    return nil;
}

- (BOOL)textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
    self.doneBarButton.enabled = ([newText length] > 0);
    return YES;
}


@end
