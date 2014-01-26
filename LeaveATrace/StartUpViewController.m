//
//  StartUpViewController.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/18/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "StartUpViewController.h"
#import "LoadTraces.h"
#import "AppDelegate.h"

@interface StartUpViewController ()

@end

@implementation StartUpViewController

-(void)viewDidLoad
{
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadNotification:)
                                                 name:@"LoadTracesNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadNotification:)
                                                 name:@"LoadContactsNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadNotification:)
                                                 name:@"LoadRequestsNotification"
                                               object:nil];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    
    [self performSelector:@selector(defaults)];
    
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
        [loadTraces loadRequestsArray];
        
        [self performSegueWithIdentifier:@"userAlreadyLoggedIn" sender:self];
        
    }
    else
    {
        
        NSLog(@"user needs to log in");
        
        [self performSegueWithIdentifier:@"userNeedsToLogIn" sender:self];
        
    }
    
}

- (void) receiveLoadNotification:(NSNotification *) notification
{
    
    if ([[notification name] isEqualToString:@"LoadTracesNotification"])
    {
        
        NSLog (@"Successfully received the traces load notification!");
        (APP).TRACES_DATA_LOADED = YES;
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SendTraceNotification"
         object:self];
        
    }
    
    if ([[notification name] isEqualToString:@"LoadContactsNotification"])
    {
        
        NSLog (@"Successfully received the contacts load notification!");
        (APP).CONTACTS_DATA_LOADED = YES;
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"ContactsLoadedNotification"
         object:self];
        
    }
    
    if ([[notification name] isEqualToString:@"LoadRequestsNotification"])
    {
        
        NSLog (@"Successfully received the requests load notification!");
        (APP).REQUESTS_DATA_LOADED = YES;
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"RequestsLoadedNotification"
         object:self];
        
    }
    
}

@end
