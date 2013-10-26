//
//  LeaveATraceItem.h
//  LeaveATrace
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaveATraceItem : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL checked;

- (void)toggleChecked;

@end
