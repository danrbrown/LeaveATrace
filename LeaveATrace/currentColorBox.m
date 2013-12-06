//
//  currentColorBox.m
//  LeaveATrace
//
//  Created by Ricky Brown on 12/5/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "currentColorBox.h"
#import "CanvasViewController.h"

@implementation currentColorBox

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, theColor.CGColor);
    CGContextFillRect(context, self.bounds);
    
    CGRect paperRect = self.bounds;
    
    UIColor *black = [UIColor blackColor];
    
    CGRect strokeRect = CGRectInset(paperRect, 1.0, 1.0);
    CGContextSetStrokeColorWithColor(context, black.CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeRect(context, strokeRect);
    
}


@end
