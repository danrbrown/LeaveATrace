//
//  LeaveATraceRequest.h
//  LeaveATrace
//
//  Created by Ricky Brown on 11/21/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaveATraceRequest : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, copy) NSString *userAccepted;

@end
