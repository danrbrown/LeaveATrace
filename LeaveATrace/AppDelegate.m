//
//  AppDelegate.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "ThreadViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    _tracesArray = [[NSMutableArray alloc] init];
    _contactsArray = [[NSMutableArray alloc] init];
    _requestsArray = [[NSMutableArray alloc] init];
    
    _unopenedTraceCount = 0;
    _friendRequestsCount = 0;
    
    _TRACES_DATA_LOADED = NO;
    _CONTACTS_DATA_LOADED = NO;
    _REQUESTS_DATA_LOADED = NO;
    
    [Parse setApplicationId:@"cK6TMBbNDsdNFsE1vSckhEQDrCQjztAxURMKPHXL"
                  clientKey:@"8n0WuaSXapCrRAH1HRNL7bbSxIOBQxbjZHWLIrHr"];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload)
    {
        
        NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
        NSString *traceUsername = [traceDefaults objectForKey:@"username"];
        NSLog(@"username in defaults %@",traceUsername);
        NSLog(@"notificationPayload = %@",notificationPayload);
        NSString *pushReceiver = [notificationPayload objectForKey:@"r"];
        
        if ([traceUsername isEqualToString:pushReceiver])
        {
        
        }
        
        UIAlertView *pushR = [[UIAlertView alloc] initWithTitle:@"Value of pushReceiver is..." message:pushReceiver delegate:nil cancelButtonTitle:@"close" otherButtonTitles:nil];
        [pushR show];
        
    }
    
    application.applicationSupportsShakeToEdit = YES;
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
   // [PFPush handlePush:userInfo];
    
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *traceUsername = [traceDefaults objectForKey:@"username"];
    NSString *p = [userInfo objectForKey:@"p"]; //ObjectId
    NSString *r = [userInfo objectForKey:@"r"]; //Who the push notification is going to
    
    NSLog(@"p = %@",p);
    NSLog(@"r = %@",r);
    NSLog(@"userinfo = %@",userInfo);

    // Only deal with the push if the user is logged in, and the logged in user
    // is the one receiving the push
    
    if (([traceUsername length] > 0) && [r isEqualToString:traceUsername])
    {

        NSLog(@"We're good to go.");
    
        PFQuery *pushQuery = [PFQuery queryWithClassName:@"TracesObject"];
        [pushQuery whereKey:@"objectId" equalTo:p];
        
        [pushQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error)
            {
                for (PFObject *obj in objects)
                {
                    
                    [_tracesArray addObject:obj];
                    _unopenedTraceCount++;
                    
                }
                
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastSentByDateTime" ascending:NO];
                [_tracesArray sortUsingDescriptors:[NSArray arrayWithObject:sort]];
                
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"PushTraceNotification"
                 object:self];
                
            }
            else
            {
                
                NSLog(@"There was an error loading the pushed trace.");
                
            }
            
        }];
        
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
