//----------------------------------------------------------------------------------
//
//  AddItemViewController.m
//  Checklists
//
//  Created by Matthijs Hollemans on 03-06-12.
//  Copyright (c) 2012 Hollance. All rights reserved.
//
//  Purpose: This class is for the "pop-up" to add a new contact. The contact
//  entered by the user is validated to ensure that it already exists in our
//  database.
//
//----------------------------------------------------------------------------------


#import "AddItemViewController.h"
#import "LeaveATraceItem.h"
#import "ContactsViewController.h"
#import "CanvasViewController.h"
#import <Parse/Parse.h>

@interface AddItemViewController ()

@end

@implementation AddItemViewController

@synthesize textField, doneBarButton, delegate, stuff;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: First method to be called. Turn off autocorrection and
// turn off auto capitalization.
//
//----------------------------------------------------------------------------------

- (void) viewDidLoad
{
    
    textField.autocorrectionType = FALSE;
    
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
}

//----------------------------------------------------------------------------------
//
// Name: viewWillAppear
//
// Purpose: Called whenever the view is displayed.
//
//----------------------------------------------------------------------------------

- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
 
    [self.textField becomeFirstResponder];
    
}

//----------------------------------------------------------------------------------
//
// Name: cancel
//
// Purpose: Method called if the user presses cancel on the pop-up. It simply
// closes the screen and returns to the contact list.
//
//----------------------------------------------------------------------------------

-(IBAction) cancel
{
    
    [self.delegate addItemViewControllerDidCancel:self];
    
}

//----------------------------------------------------------------------------------
//
// Name: done
//
// Purpose: Method called if the user presses Done on the pop-up. We first query
// Parse to make sure the user that was entered exists in the database and will give
// an error if it doesn't. Otherwise we entered the row in our database.
//
//----------------------------------------------------------------------------------
 
-(IBAction) done
{
    
    [loadingContact startAnimating];
    
    BOOL isDuplicate = NO;
    
    LeaveATraceItem *item = [[LeaveATraceItem alloc] init];
    item.text = self.textField.text;
    
    //---------------------------------------------------------
    //Check to see if the user is trying to insert him/herself
    //---------------------------------------------------------
    
    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    if ([tmpCurrentUser isEqualToString:item.text])
    {
    
        [loadingContact stopAnimating];
        
        NSString *errorString = @"Can't add yourself as a contact Jackass";
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errorString message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [errorAlertView show];
        
    }
    else
    {
        //---------------------------------------------------------
        // See if the contact is already in our array.
        // Thanks to co-founder 15 for figuring this out.
        //---------------------------------------------------------
        
        NSUInteger contactIndex;
        PFObject *tmpObject;
        NSString *tmpContact;
        
        for (contactIndex = 0; contactIndex < stuff.count; contactIndex++)
        {
            
            tmpObject = [stuff objectAtIndex:contactIndex];
            
            tmpContact = [tmpObject objectForKey:@"contact"];
            
            if ([tmpContact isEqualToString:item.text])
            {
                isDuplicate = YES;
                break;
            }
            
        }

        if (isDuplicate)
        {
            
            [loadingContact stopAnimating];
            
            NSString *errorString = @"Contact is already in the list";
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errorString message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
        }
        else
        {
        
            //---------------------------------------------------------
            // Query to see if the person they're adding is a valid
            // LeaveATrace user.
            //---------------------------------------------------------

            item.userAccepted = @"NO";
    
            PFQuery *query= [PFUser query];
            [query whereKey:@"username" equalTo:item.text];
    
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
                if (!error)
                {
                
                    //---------------------------------------------------------
                    // If they're valid, then add to database.
                    //---------------------------------------------------------

                    PFObject *userContact = [PFObject objectWithClassName:@"UserContact"];
                    [userContact setObject:[PFUser currentUser].username forKey:@"username"];
                    [userContact setObject:item.text forKey:@"contact"];
                    [userContact setObject:@"NO" forKey:@"userAccepted"];
                    [userContact setObject:@"" forKey:@"nickname"];
    
                    [userContact saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
                        if (succeeded)
                        {
            
                            [loadingContact stopAnimating];
                            
                            [self.delegate addItemViewController:self didFinishAddingItem:item];
            
                        }
                        else
                        {
            
                            [loadingContact stopAnimating];
                            
                            NSString *errorString = [[error userInfo] objectForKey:@"error"];
                            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:  errorString delegate:nil cancelButtonTitle:@"Ok"    otherButtonTitles:nil, nil];
                    
                            [errorAlertView show];
                        
                        }
                
                    }];
            
                }
                else
                {
            
                    [loadingContact stopAnimating];
                    
                    NSString *errorString = @"User not found";
            
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:errorString message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
                    [errorAlertView show];
            
                }
        
            }];
        }
    }
}

//----------------------------------------------------------------------------------
//
// Name: tableView:willSelectRowAtIndexPath
//
// Purpose: The user can't "select" a row so we simply return nil if it's pressed.
//
//----------------------------------------------------------------------------------

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    return nil;
    
}

//----------------------------------------------------------------------------------
//
// Name: textField:shouldChangeCharactersInRange
//
// Purpose: Method makes sure there's a value in the field.
//
//----------------------------------------------------------------------------------

-(BOOL) textField:(UITextField *)theTextField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newText = [theTextField.text stringByReplacingCharactersInRange:range withString:string];
    
    self.doneBarButton.enabled = ([newText length] > 0);
    
    return YES;
    
}

@end
