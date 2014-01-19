//
//  AppDelegate.m
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <Parse/Parse.h>
#import "LoginViewController.h"
//#import "CanvasViewController.h"
#import "AppDelegate.h"
#import "ThreadViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
     
    
    _tracesArray = [[NSMutableArray alloc] init];
    
    _contactsArray = [[NSMutableArray alloc] init];
    
    [Parse setApplicationId:@"cK6TMBbNDsdNFsE1vSckhEQDrCQjztAxURMKPHXL"
                  clientKey:@"8n0WuaSXapCrRAH1HRNL7bbSxIOBQxbjZHWLIrHr"];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    application.applicationSupportsShakeToEdit = YES;
    
    // new attempt to respond to push payload
//    
//    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
//    
//    // Create a pointer to the Photo object
//    NSString *imageId = [notificationPayload objectForKey:@"p"];
//    PFObject *targetTrace = [PFObject objectWithoutDataWithClassName:@"Photo"
//                                                            objectId:imageId];
//    
//    // Fetch photo object
//    [targetTrace fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        // Show photo view controller
//        if (!error && [PFUser currentUser]) {
////            PhotoVC *ThreadViewController = [[PhotoVC alloc] initWithPhoto:object];
////            [self.navController pushViewController:viewController animated:YES];
//            
//            NSLog(@"fetched the image %@",object);
//        }
//    }];
    
    // to be looked at later. DB
    
//    NSLog(@"In didFinishLaunchingWithOptions");
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    UIViewController *obj=[storyboard instantiateViewControllerWithIdentifier:@"haha"];
//    self.navigationController.navigationBarHidden=YES;
//    [self.navigationController pushViewController:obj animated:YES];
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [PFPush handlePush:userInfo];
    
    //UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    //tabBarController.selectedIndex = 1;
    
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
