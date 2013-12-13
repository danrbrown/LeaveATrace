//
//  commonLogin.h
//  LeaveATrace
//
//  Created by Ricky Brown on 12/12/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol CommsDelegate <NSObject>

@optional

-(void) commsDidLogin:(BOOL)loggedIn;

@end


@interface commonLogin : NSObject

+(void) login:(id<CommsDelegate>)delegate;

@end
