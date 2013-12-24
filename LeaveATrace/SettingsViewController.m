//
//  SettingsViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 12/23/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    
    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 3;
    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;

}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    NSString *sectionName;
    
    if (section == 0)
    {
        
        sectionName = @"Account";
        
    }
    
    return sectionName;
    
}

//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
//    label.text = @"Section Header Text Here";
//    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
//    label.backgroundColor = [UIColor clearColor];
//    return label;
//    
//}

-(NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return nil;
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsItem"];
    
    NSString *usernameString = [[PFUser currentUser] username];
    NSString *emailString = [[PFUser currentUser] email];
    NSDate *createdAt = [[PFUser currentUser] createdAt];
    
    NSDateFormatter *displayDayAndTimeFormat = [[NSDateFormatter alloc] init];
    [displayDayAndTimeFormat setDateFormat:@"MMM dd, YYYY h:mm a"];
    NSString *createdAtString = [NSString stringWithFormat:@"%@", [displayDayAndTimeFormat stringFromDate:createdAt]];
    
    if (indexPath.row == 0)
    {
        
        cell.textLabel.text = @"Username";
        cell.detailTextLabel.text = usernameString;
        
    }
    else if (indexPath.row == 1)
    {
        
        cell.textLabel.text = @"Email";
        cell.detailTextLabel.text = emailString;
        
    }
    else if (indexPath.row == 2)
    {
        
        cell.textLabel.text = @"Leave A Trace user since...";
        cell.detailTextLabel.text = createdAtString;
        
    }


    return cell;

}

-(IBAction) done:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
