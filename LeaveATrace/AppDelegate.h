//
//  AppDelegate.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP (AppDelegate*)[[UIApplication sharedApplication] delegate]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, atomic) NSMutableArray *tracesArray;
@property (strong, atomic) NSMutableArray *contactsArray;
@property (strong, atomic) NSMutableArray *requestsArray;
@property (nonatomic, assign) NSInteger unopenedTraceCount;
@property (nonatomic, assign) NSInteger friendRequestsCount;

@end
