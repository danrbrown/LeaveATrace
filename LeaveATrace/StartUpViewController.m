//
//  StartUpViewController.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/18/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "StartUpViewController.h"
#import "LoadTraces.h"

@interface StartUpViewController ()

@end

@implementation StartUpViewController

-(void)viewDidLoad
{
    
    tracesLoaded = NO;
    contactsLoaded = NO;

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"LoadTracesNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"LoadContactsNotification"
                                               object:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [self performSelector:@selector(defaults) withObject:nil afterDelay:1];
    
}

-(void) defaults
{
    
    LoadTraces *loadTraces = [[LoadTraces alloc] init];
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpUsername = [traceDefaults objectForKey:@"username"];
    
    NSLog(@"username in defaults %@",tmpUsername);
    
    if ([tmpUsername length] != 0)
    {
        
        [loadTraces loadTracesArray];
        [loadTraces loadContactsArray];
        
    }
    else
    {
        
        NSLog(@"user needs to log in");
        
        [self performSegueWithIdentifier:@"userNeedsToLogIn" sender:self];
        
    }
    
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"LoadTracesNotification"])
    {
        
        NSLog (@"Successfully received the traces load notification!");
        tracesLoaded = YES;
        
    }
    
    if ([[notification name] isEqualToString:@"LoadContactsNotification"])
    {
        
        NSLog (@"Successfully received the contacts load notification!");
        contactsLoaded = YES;
        
    }
    
    if (tracesLoaded && contactsLoaded)
    {
        
        [self performSegueWithIdentifier:@"userAlreadyLoggedIn" sender:self];
        
    }
    
}

@end
