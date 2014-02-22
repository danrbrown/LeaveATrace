//
//  RageIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "RageIAPHelper.h"

@implementation RageIAPHelper

+ (RageIAPHelper *)sharedInstance
{
    
    static dispatch_once_t once;
    static RageIAPHelper *sharedInstance;
    
    dispatch_once(&once, ^{
    
        NSSet *productIdentifiers = [NSSet setWithObjects:
                                      
                                      @"com.15and50.LeaveATrace.100moreTraces",
                                      @"com.15and50.LeaveATrace.500moreTraces",
                                      
                                      nil];
        
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    
        NSLog(@"sharedInstand1 %@",sharedInstance);
       NSLog(@"productIdentifiers %@",productIdentifiers);
        
    });
    
    NSLog(@"sharedInstand2 %@",sharedInstance);
    
    return sharedInstance;
    
}

@end
