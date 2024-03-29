//
//  canvasImage.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 1/2/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "canvasImage.h"

@implementation canvasImage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        pathArray=[[NSMutableArray alloc]init];
        bufferArray=[[NSMutableArray alloc]init];
        
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    [[UIColor redColor] setStroke];
    for (UIBezierPath *_path in pathArray)
        [_path strokeWithBlendMode:kCGBlendModeNormal alpha:1.0];
    
}

#pragma mark - Touch Methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    myPath=[[UIBezierPath alloc]init];
    myPath.lineWidth=10;
    
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [myPath moveToPoint:[mytouch locationInView:self]];
    [pathArray addObject:myPath];
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *mytouch=[[touches allObjects] objectAtIndex:0];
    [myPath addLineToPoint:[mytouch locationInView:self]];
    [self setNeedsDisplay];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
}

-(void) undoButtonClicked
{
    
    NSLog(@"hello");
    
    if([pathArray count]>0){
        UIBezierPath *_path=[pathArray lastObject];
        [bufferArray addObject:_path];
        [pathArray removeLastObject];
        [self setNeedsDisplay];
        NSLog(@"clicked");
    }
    
}


@end
