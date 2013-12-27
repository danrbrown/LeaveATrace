//----------------------------------------------------------------------------------
//
//  CanvasViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/19/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//
//  Purpose:
//
//----------------------------------------------------------------------------------

#import "CanvasViewController.h"
#import "SelectAContactViewController.h"
#import "tracesViewController.h"
#import <Twitter/Twitter.h>
#import <Parse/Parse.h>

//Global variables
UIImage *SaveImage;
NSData *pictureData;
PFFile *file;
NSString *badgeString;
NSString *tracesBadgeString;
UIImageView *mainImage;
UIColor *theColor;
double hue;

@interface CanvasViewController ()

@end

@implementation CanvasViewController

@synthesize mainImage,red,green,blue,brush,currentColorImage,colorValue,brushSize;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{
    
    buttonPressed = NO;
    
    [self countRequests];
    [self countTraces];
    
    pathArray = [[NSMutableArray alloc] init];
    
    red = 255;
    green = 0;
    blue = 0;
    brush = 11.0;
    opacity = 1.0;
    
    colorValue.value = 0;
    brushSize.value = brush;
    
    theColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];

    currentColorImage.backgroundColor = theColor;
    currentColorImage.layer.cornerRadius = 7.0;
    currentColorImage.layer.borderColor = [UIColor blackColor].CGColor;
    currentColorImage.layer.borderWidth = 3.0;
    currentColorImage.frame = CGRectMake(141, 26, 38, 33);

}

//----------------------------------------------------------------------------------
//
// Name: viewWillAppear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidAppear:(BOOL)animated
{
    
    [self becomeFirstResponder];
    
    [super viewWillAppear:animated];
    
    if (clearImage)
    {
        
        mainImage.image = nil;
        
        [self.tabBarController setSelectedIndex:0];
        
    }
    
    clearImage = NO;
    
}

//----------------------------------------------------------------------------------
//
// Name: viewDidDisappear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidDisappear:(BOOL)animated
{
    
    [self resignFirstResponder];
    
    [super viewDidDisappear:animated];
    
}

//----------------------------------------------------------------------------------
//
// Name: canBecomeFirstResponder
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(BOOL) canBecomeFirstResponder
{
    
    return YES;
    
}

//----------------------------------------------------------------------------------
//
// Name: countRequests
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) countRequests
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserContact"];
    
    [query whereKey:@"contact" equalTo:[[PFUser currentUser]username]];
    [query whereKey:@"userAccepted" equalTo:@"NO"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            if (objects.count == 0)
            {
                
                [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:nil];
                
            }
            else if (objects.count >= 1 && [deliveredToUser isEqualToString:@"NO"])
            {
            
                badgeString = [NSString stringWithFormat:@"%lu",(unsigned long)objects.count];
            
                [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:badgeString];
            
            }
                
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name: countTraces
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) countTraces
{
    
    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    
    NSString *tmpCurrentUser = [[PFUser currentUser]username];
    
    [toUserQuery whereKey:@"toUser" equalTo:tmpCurrentUser];
    [toUserQuery whereKey:@"lastSentBy" notEqualTo:tmpCurrentUser];
    [toUserQuery whereKey:@"deliveredToUser" equalTo:@"NO"];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    
    [fromUserQuery whereKey:@"fromUser" equalTo:tmpCurrentUser];
    [fromUserQuery whereKey:@"lastSentBy" notEqualTo:tmpCurrentUser];
    [fromUserQuery whereKey:@"deliveredToUser" equalTo:@"NO"];
    
    query = [PFQuery orQueryWithSubqueries:@[toUserQuery,fromUserQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            if (objects.count == 0)
            {
                
                [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setBadgeValue:nil];
                
            }
            else
            {
                
                tracesBadgeString = [NSString stringWithFormat:@"%lu",(unsigned long)objects.count];
                
                [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setBadgeValue:tracesBadgeString];
                
            }
            
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name: convertToMask
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(UIImage*) convertToMask:(UIImage *)image
{
    
    if (image != nil)
    {
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        
        CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 0.9f);
        
        CGContextFillRect(ctx, imageRect);
    
        [image drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
        UIImage* outImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return outImage;
        
    }
    else
    {
        
        return image;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: clear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) clear:(id)sender
{
    
    if (self.mainImage.image != nil)
    {
        
        [UIView beginAnimations:@"suck" context:NULL];
        [UIView setAnimationTransition:108 forView:mainImage cache:NO];
        [UIView setAnimationDuration:0.9f];
        [UIView commitAnimations];
    
        self.mainImage.image = nil;
        
    }
    
    self.mainImage.image = nil;
    
}

-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        
        if (self.mainImage.image != nil)
        {
            
            [UIView beginAnimations:@"suck" context:NULL];
            [UIView setAnimationTransition:108 forView:mainImage cache:NO];
            [UIView setAnimationDuration:0.9f];
            [UIView commitAnimations];
            
            self.mainImage.image = nil;
            
        }
        
        self.mainImage.image = nil;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: touchesBegan
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    mouseSwiped = NO;
    
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self.view];
    
}

//----------------------------------------------------------------------------------
//
// Name: touchesMoved
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.mainImage setAlpha:opacity];
    
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
    
    [self hide];

}

//----------------------------------------------------------------------------------
//
// Name: touchesEnded
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(!mouseSwiped)
    {
    
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self show];

}

//----------------------------------------------------------------------------------
//
// Name: undo
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) undo:(id)sender
{

    
}

//----------------------------------------------------------------------------------
//
// Name: prepareForSegue
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"selectAContact"])
    {
        
        UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
        [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
        SaveImage = UIGraphicsGetImageFromCurrentImageContext();
        pictureData = UIImageJPEGRepresentation(SaveImage, 1.0);
        UIGraphicsEndImageContext();
        
        file = [PFFile fileWithName:@"img" data:pictureData];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: sliderChanged
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) sliderChanged:(id)sender
{
    
    UISlider * changedSlider = (UISlider*)sender;
    
    if(changedSlider == self.brushSize)
    {
        
        brush = self.brushSize.value;
        
    }
    
    if(changedSlider == self.colorValue)
    {
       
        hue = changedSlider.value;
        
        theColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
        
        CGColorRef colorRef = [theColor CGColor];
            
        const CGFloat *_components = CGColorGetComponents(colorRef);
        red     = _components[0];
        green = _components[1];
        blue   = _components[2];
        
        currentColorImage.backgroundColor = theColor;
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: save
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) save:(id)sender
{
    
    [loading startAnimating];
    
    UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
    [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
    UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(SaveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    
}

//----------------------------------------------------------------------------------
//
// Name: image
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    if (error != NULL)
    {
        
        [loading stopAnimating];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"Image could not be saved. Please try again"  delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        
        [alert show];
        
    }
    else
    {
        
        [loading stopAnimating];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Nice drawing! Image was saved."  delegate:nil cancelButtonTitle:@"Yay" otherButtonTitles:nil];
        
        [alert show];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name:
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) send:(id)sender
{
    
    [self performSegueWithIdentifier:@"selectAContact" sender:self];
    
}

//----------------------------------------------------------------------------------
//
// Name: eraser
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(IBAction) eraser:(id)sender
{
    
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    opacity = 1.0;
    
    currentColorImage.backgroundColor = [UIColor whiteColor];
    
}

-(void) show
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [trashB setAlpha:1];
    [undoB setAlpha:1];
    [saveB setAlpha:1];
    [colorValue setAlpha:1];
    [brushSize setAlpha:1];
    [undoB setAlpha:1];
    [sendB setAlpha:1];
    [eraseB setAlpha:1];
    [currentColorImage setAlpha:1];
    [UIView commitAnimations];
    
}

-(void) hide
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [trashB setAlpha:0];
    [undoB setAlpha:0];
    [saveB setAlpha:0];
    [colorValue setAlpha:0];
    [brushSize setAlpha:0];
    [undoB setAlpha:0];
    [sendB setAlpha:0];
    [eraseB setAlpha:0];
    [currentColorImage setAlpha:0];
    [UIView commitAnimations];
    
}

@end













