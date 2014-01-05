//
//  canvasImage.h
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/2/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface canvasImage : UIImageView {
    
    NSMutableArray *pathArray;
    NSMutableArray *bufferArray;
    UIBezierPath *myPath;

}

@property(nonatomic,assign) NSInteger undoSteps;

-(void) undoButtonClicked;

@end
