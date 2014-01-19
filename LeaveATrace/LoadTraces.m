//
//  LoadTraces.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/18/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "LoadTraces.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@implementation LoadTraces

-(void) loadTracesArray
{
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [toUserQuery whereKey:@"toUser" equalTo:[[PFUser currentUser]username]];
    [toUserQuery whereKey:@"toUserDisplay" equalTo:@"YES"];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    [fromUserQuery whereKey:@"fromUser" equalTo:[[PFUser currentUser]username]];
    [fromUserQuery whereKey:@"fromUserDisplay" equalTo:@"YES"];
    
    PFQuery *tracesQuery = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    
    [tracesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            (APP).tracesArray = [[NSMutableArray alloc] initWithArray:objects];
            
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastSentByDateTime" ascending:NO];
            
            [(APP).tracesArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
            
            NSLog(@"displayTraces: count of traces %lu",(APP).tracesArray.count);
            
        }
        
    }];
    
}

-(void) loadContactsArray
{
    
    PFQuery *contactsQuery = [PFQuery queryWithClassName:@"UserContact"];
    
    [contactsQuery whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    
    [contactsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            (APP).contactsArray = [[NSMutableArray alloc] initWithArray:objects];
            
            NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"contact" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            [(APP).contactsArray sortUsingDescriptors:[NSArray arrayWithObject:sort1]];
                        
        }
        else
        {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            
        }
        
    }];
    
    

}

@end
