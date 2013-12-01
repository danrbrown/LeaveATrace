//
//  SelectAContactViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 11/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "SelectAContactViewController.h"
#import "CanvasViewController.h"
#import "LeaveATraceItem.h"
#import "sendToCell.h"
#import <Parse/Parse.h>

BOOL clearImage;

@interface SelectAContactViewController ()

@end

@implementation SelectAContactViewController{
    NSString *userAccepted;
    NSString *userContact;
    PFQuery *query;
}

@synthesize validContactsTable;

- (void) viewDidLoad
{
    NSLog(@"in my new table view");
    
    validContacts = [[NSMutableArray alloc] initWithCapacity:1000];
    
    [self performSelector:@selector(displayValidContacts)];
}

-(void) viewWillAppear:(BOOL)animated {
        NSLog(@"in viewWillAppear");
}

-(void) displayValidContacts {
    
    query = [PFQuery queryWithClassName:@"UserContact"];
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"userAccepted" equalTo:@"YES"];
    [query orderByAscending:@"contact"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            validContacts = [[NSMutableArray alloc] initWithArray:objects];
        }
        NSLog(@"Valid contacts %@",validContacts);
        [validContactsTable reloadData];
    }];
    
}

- (IBAction)cancel
{
    NSLog(@"closed this view... kinda");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return validContacts.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ValidContactCell";
    
    sendToCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [validContacts objectAtIndex:indexPath.row];
    
    cell.sendToTitle.text = [tempObject objectForKey:@"contact"];
    NSLog(@"contact is: %@",cell.sendToTitle.text);
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"I pressed a cell");
    
    clearImage = YES;
    
    PFObject *tempObject = [validContacts objectAtIndex:indexPath.row];
    NSString *tempContact = [tempObject objectForKey:@"contact"];

    [self dismissViewControllerAnimated:YES completion:nil];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            PFObject *imageObject = [PFObject objectWithClassName:@"TracesObject"];
            [imageObject setObject:file forKey:@"image"];
            [imageObject setObject:[PFUser currentUser].username forKey:@"fromUser"];
            [imageObject setObject:tempContact forKey:@"toUser"];
            [imageObject setObject:@"NO"forKey:@"deliveredToUser"];
            
            [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                else
                {
                    
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                }
                
            }];
            
        }
        else
        {
            
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }
        
    }
    progressBlock:^(int percentDone)
    {
        
        NSLog(@"Uploaded: %d %%", percentDone);
        
    }];

    return nil;
}

@end



