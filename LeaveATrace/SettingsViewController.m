//
//  SettingsViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 12/23/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "SettingsViewController.h"
#import "FirstPageViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    
    NSString *usernameString = [[PFUser currentUser] username];
    NSString *emailString = [[PFUser currentUser] email];
    NSDate *createdAt = [[PFUser currentUser] createdAt];
    
    NSDateFormatter *displayDayAndTimeFormat = [[NSDateFormatter alloc] init];
    [displayDayAndTimeFormat setDateFormat:@"MMM dd, YYYY h:mm a"];
    NSString *createdAtString = [NSString stringWithFormat:@"%@", [displayDayAndTimeFormat stringFromDate:createdAt]];
    
    self.acountInfo = [@[@"Username", @"Email", @"Leave A Trace user since"] mutableCopy];
    self.acountInfoDetail = [@[usernameString, emailString, createdAtString] mutableCopy];
    
    self.actions = [@[@"Log out", @"Clear my traces"] mutableCopy];
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0)
    {
    
        return self.acountInfo.count;
    
    }
    else
    {
    
        return self.actions.count;
    
    }
    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;

}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        
        return @"Acount";
    
    }
    else
    {
    
        return @"Actions";
    
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    
    if (section == 0)
    {
        
        label.frame = CGRectMake(20, 30, 320, 20);
    
    }
    else
    {
        
        label.frame = CGRectMake(20, 12, 320, 20);
        
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
    
}

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"Do you really want to log out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        
        [errorAlertView show];
        
    }

    if (indexPath.section == 1 && indexPath.row == 1)
    {
     
        PFObject *userTraces = [PFObject objectWithClassName:@"TracesObject"];
        [userTraces setObject:[PFUser currentUser].username forKey:@"fromUser"];
        
        [userTraces deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded)
            {
                
                [self deleteMyTraces];
                NSLog(@"'delete all traces'");  //Dan
                
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:nil message:@"You cleared your traces." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                
                [errorAlertView show];
            
            }
            else
            {
                
                NSString *errorString = [[error userInfo] objectForKey:@"error"];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:  errorString delegate:nil cancelButtonTitle:@"Ok"    otherButtonTitles:nil, nil];
                
                [errorAlertView show];
                
            }
            
        }];

    }
    
    return nil;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
 
    if (buttonIndex == 1)
    {
        
        NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
        [traceDefaults setObject:@"" forKey:@"username"];
        [traceDefaults setObject:@"" forKey:@"password"];
        [traceDefaults synchronize];
        
        (APP).tracesArray = nil;
        (APP).contactsArray = nil;
        (APP).requestsArray = nil;
        
        (APP).TRACES_DATA_LOADED = NO;
        (APP).CONTACTS_DATA_LOADED = NO;
        (APP).REQUESTS_DATA_LOADED = NO;
        
        [PFUser logOut];
        
        [self performSegueWithIdentifier:@"LogOutSuccesful" sender:self];
        
    }
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsItem"];
    
    NSString *text;
    NSString *detail;
    
    if (indexPath.section == 0)
    {
        
        text = self.acountInfo[indexPath.row];
        detail = self.acountInfoDetail[indexPath.row];
    
    }
    else
    {
    
        text = self.actions[indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    }
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detail;

    return cell;

}

-(IBAction) done:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) deleteMyTraces
{
    
    NSString *tmpCurrentUser = [[PFUser currentUser] username];
    NSInteger idx = 0;
    
    for (PFObject *obj in (APP).tracesArray)
    {
        
        NSString *tmpFromUser = [obj objectForKey:@"fromUser"];
        NSString *tmpToUser = [obj objectForKey:@"toUser"];
        
        if ([tmpCurrentUser isEqualToString:tmpFromUser])
            [obj setObject:@"NO" forKey:@"fromUserDisplay"];
        
        if ([tmpCurrentUser isEqualToString:tmpToUser])
            [obj setObject:@"NO" forKey:@"toUserDisplay"];
        
        //  See if the row should be deleted or updated. If both users deleted
        //  then delete from parse.  Else just update the delete flag
        
        NSString *tmpFromUserDisplay = [obj objectForKey:@"fromUserDisplay"];
        NSString *tmpToUserDisplay = [obj objectForKey:@"toUserDisplay"];
        
        if ([tmpFromUserDisplay isEqualToString:@"NO"] && [tmpToUserDisplay isEqualToString:@"NO"])
        {
            
            [obj deleteInBackground];
            
            NSLog(@"Delete row in parse");
            
        }
        else
        {
            
            [obj saveInBackground];
            
            NSLog(@"Delete one trace by updating");
            
        }
        
        [(APP).tracesArray removeObjectAtIndex:idx];
        idx++;
        
    }
    
}

@end
