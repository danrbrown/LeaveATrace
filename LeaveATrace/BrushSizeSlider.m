//
//  BrushSizeSlider.m
//  LeaveATrace
//
//  Created by Ricky Brown on 1/31/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "BrushSizeSlider.h"

@implementation BrushSizeSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
         [self constructSlider];
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self constructSlider];
    }
    return self;
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    // Fade in and update the popup view
    CGPoint touchPoint = [touch locationInView:self];
    
    // Check if the knob is touched. If so, show the popup view
    if(CGRectContainsPoint(CGRectInset(self.thumbRect, -12.0, -12.0), touchPoint))
    {
        
        [self positionAndUpdatePopupView];
        [self fadePopupViewInAndOut:YES];
        
    }
    
    return [super beginTrackingWithTouch:touch withEvent:event];
    
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    // Update the popup view as slider knob is being moved
    [self positionAndUpdatePopupView];
    return [super continueTrackingWithTouch:touch withEvent:event];
    
}

-(void)cancelTrackingWithEvent:(UIEvent *)event
{
    
    [super cancelTrackingWithEvent:event];
    
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    // Fade out the popup view
    [self fadePopupViewInAndOut:NO];
    [super endTrackingWithTouch:touch withEvent:event];
    
}

-(void)constructSlider
{
    
    _popup = [[PopoverView alloc] initWithFrame:CGRectZero];
    _popup.backgroundColor = [UIColor clearColor];
    _popup.alpha = 0.0;
    [self addSubview:_popup];
    
}

-(void)fadePopupViewInAndOut:(BOOL)aFadeIn
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    if (aFadeIn)
    {
        
        _popup.alpha = 1.0;
        
    }
    else
    {
        
        _popup.alpha = 0.0;
        
    }
    
    [UIView commitAnimations];
    
}

-(void) positionAndUpdatePopupView
{
    
    CGRect zeThumbRect = self.thumbRect;
    CGRect popupRect = CGRectOffset(zeThumbRect, 0, -floor(zeThumbRect.size.height * 1.5));
    _popup.frame = CGRectInset(popupRect, -20, -10);
    _popup.value = self.value;
    
}

-(CGRect)thumbRect
{
    
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbR = [self thumbRectForBounds:self.bounds trackRect:trackRect value:self.value];
    return thumbR;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
