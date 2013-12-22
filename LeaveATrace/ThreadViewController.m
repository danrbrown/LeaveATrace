//----------------------------------------------------------------------------------
//
//  ThreadViewController.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 11/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Purpose: This class file of ViewController is for drawing back to a user that sent
//  you a drawing, in a thread convo.
//
//----------------------------------------------------------------------------------

#import "ThreadViewController.h"
#import "CanvasViewController.h"
#import "tracesViewController.h"

@interface ThreadViewController ()

@end

@implementation ThreadViewController

@synthesize mainThreadImage, currentColorImage, red, green, blue;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
// 
// Purpose: First screen where the user will update a trace that was sent to them
// This first gets from our global object the name of the user that sent the trace.
// Then we do generate graphics including a dot that shows the current color.
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{
    
    NSString *userWhoSentTrace = [traceObject objectForKey:@"fromUser"];
    
    self.title = userWhoSentTrace;
 
    sendingProg.hidden = YES;
    
    [self getThreadTrace:userWhoSentTrace];
    
    red = 255.0;
    green = 0.0;
    blue = 0.0;
    brush = 11.0;
    opacity = 1.0;
    
    NSLog(@"About to load trace in ThreadViewController");
    NSLog(@"User who sent trace --> %@, objectId --> %@",userWhoSentTrace,traceObjectId);

}

//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) getThreadTrace:(NSString *)userWhoSentTrace
{
    
    PFQuery *traceQuery = [PFQuery queryWithClassName:@"TracesObject"];

    [traceQuery whereKey:@"objectId" equalTo:traceObjectId];
    
    [traceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            NSLog(@"The find in getThreadTrace succeeded %lu", (unsigned long)objects.count);
            
            for (PFObject *myImages in objects)
            {
            
                PFFile *imageFile = [myImages objectForKey:@"image"];
                imageFile = [myImages objectForKey:@"image"];
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    if (!error)
                    {

                        UIImage *image = [UIImage imageWithData:data];
                        mainThreadImage.image = image;
                        
                        NSString *tmpCurrentUser = [[PFUser currentUser]username];
                        NSString *tmpLastSentBy = [myImages objectForKey:@"lastSentBy"];
                        NSDate *currentDateTime = [NSDate date];
                        
                        if (![tmpCurrentUser isEqualToString:tmpLastSentBy])
                        {
                            [myImages setObject:@"YES"forKey:@"deliveredToUser"];
                            [myImages setObject:currentDateTime forKey:@"lastSentByDateTime"];
                            [myImages saveInBackground];
                        }
                    }
                    
                }];
                
                NSLog(@"%@",myImages.objectId);
                
            }
            
        }
        else
        {
            
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    }];
    
}

//----------------------------------------------------------------------------------
//
// Name: touchesBegan
//
// Purpose: when the user touches the screen but does not drag.
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
// Purpose: when the user drags his finger around the screen. Sets the color and the
// size.
//
//----------------------------------------------------------------------------------

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    mouseSwiped = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.view];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.mainThreadImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.mainThreadImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.mainThreadImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
    
}

//----------------------------------------------------------------------------------
//
// Name: touchesEnded
//
// Purpose: when the user picks up his finger from the screen. Keeps the graphics
// that he drew on the image that he draws on.
//
//----------------------------------------------------------------------------------

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if (!mouseSwiped) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.mainThreadImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.mainThreadImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainThreadImage.frame.size);
    [self.mainThreadImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.mainThreadImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainThreadImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

//----------------------------------------------------------------------------------
//
// Name: convertToMask
//
// Purpose: this method doesent give us a warning when the user draws.
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
        
        UIImage *outImage = UIGraphicsGetImageFromCurrentImageContext();
        
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
// Name: send
//
// Purpose: calls a method uploadThreadTrace.
//
//----------------------------------------------------------------------------------

-(IBAction) send:(id)sender
{
    
    [self uploadThreadTrace];
    
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
        
        UIColor *theColor = [UIColor colorWithHue:changedSlider.value saturation:1.0 brightness:1.0 alpha:1.0];
        
        CGColorRef colorRef = [theColor CGColor];
        
        const CGFloat *_components = CGColorGetComponents(colorRef);
        red     = _components[0];
        green = _components[1];
        blue   = _components[2];
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: uploadThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) uploadThreadTrace
{
    
    NSLog(@"in uploadThreadTrace");
    
    NSString *userWhoSentTrace = [traceObject objectForKey:@"fromUser"];
    
    NSLog(@"user who sent trace in upload --> %@",userWhoSentTrace);
    
    UIGraphicsBeginImageContextWithOptions(mainThreadImage.bounds.size, NO, 0.0);
    [mainThreadImage.image drawInRect:CGRectMake(0, 0, mainThreadImage.frame.size.width, mainThreadImage.frame.size.height)];
    
    UIImage *saveThreadImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *threadPictureData = UIImageJPEGRepresentation(saveThreadImage, 1.0);
    UIGraphicsEndImageContext();
    
    PFFile *imageFile  = [PFFile fileWithName:@"img" data:threadPictureData];
    NSDate *currentDateTime = [NSDate date];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            [traceObject setObject:imageFile forKey:@"image"];
            [traceObject setObject:@"NO"forKey:@"deliveredToUser"];
            [traceObject setObject:[PFUser currentUser].username forKey:@"lastSentBy"];
            [traceObject setObject:currentDateTime forKey:@"lastSentByDateTime"];
            [traceObject saveInBackground];
            [traceObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    
                    NSString *userWhoSentTrace = [traceObject objectForKey:@"fromUser"];
        
                    NSString *sentMessage = [NSString stringWithFormat:@"Trace was sent to %@", userWhoSentTrace];
                    
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Nice drawing..." message:sentMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [errorAlertView show];
                    
                    sendingProg.hidden = YES;
                    
                }
                else
                {
                    
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [errorAlertView show];
                    
                }
                
            }];
            
        }
        else
        {
            
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
        }
        
    }
    progressBlock:^(int percentDone)
    {
        
        NSLog(@"Uploaded return trace: %d %%", percentDone);
        
        if (sendingProg.progress < 100)
        {
            
            sendingProg.hidden = NO;
            
            sendingProg.progress = percentDone;
            
        }
        else if (sendingProg.progress >= 100)
        {
         
            sendingProg.hidden = YES;
            
        }
        
    }];

}

//----------------------------------------------------------------------------------
//
// Name: eraser
//
// Purpose: sets the color of what the user is drawing to white.
//
// NOTE: I might get rid of this and replace it with a undo button, either way I
// will implement a undo button.
//
//----------------------------------------------------------------------------------

-(IBAction) eraser:(id)sender
{
    
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    opacity = 1.0;
    
}

//----------------------------------------------------------------------------------
//
// Name: undo
//
// Purpose: It will undo the last line the user drew.
//
//----------------------------------------------------------------------------------

-(IBAction) undo:(id)sender {
    
    //DTRB
    
}

//----------------------------------------------------------------------------------
//
// Name: clear
//
// Purpose: clears the whole drawing that the user drew.
//
//----------------------------------------------------------------------------------

-(IBAction) clear:(id)sender
{
    
    [UIView beginAnimations:@"suckIt" context:NULL];
    [UIView setAnimationTransition:108 forView:mainThreadImage cache:NO];
    [UIView setAnimationDuration:0.9f];
    [UIView commitAnimations];
        
    self.mainThreadImage.image = nil;
    
}

//----------------------------------------------------------------------------------
//
// Name: save
//
// Purpose: brings up a action sheet with a option to save to the camra roll.
//
//----------------------------------------------------------------------------------

-(IBAction) save:(id)sender
{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Close", nil];
    
    [actionSheet showInView:self.view];
    
}

//----------------------------------------------------------------------------------
//
// Name: actionSheet
//
// Purpose: if the user picks the option to "save to camra roll", it will call a method
// to save to the the drawing to the users camra roll.
//
//----------------------------------------------------------------------------------

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
        
        UIGraphicsBeginImageContextWithOptions(mainThreadImage.bounds.size, NO, 0.0);
        [mainThreadImage.image drawInRect:CGRectMake(0, 0, mainThreadImage.frame.size.width, mainThreadImage.frame.size.height)];
        UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageWriteToSavedPhotosAlbum(SaveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: image
//
// Purpose: saves the drawing to the users camra roll. If it saved with no problem,
// it will alert you that it saved successfully. If there was a error, it will
// alert you about it.
//
//----------------------------------------------------------------------------------

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image could not be saved. Please try again"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        
        [alert show];
        
    }
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image was successfully saved in photoalbum"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        
        [alert show];
        
    }
}

@end









