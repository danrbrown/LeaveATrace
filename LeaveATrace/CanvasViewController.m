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
#import "currentColorBox.h"
#import <Twitter/Twitter.h>
#import <Parse/Parse.h>

//Global variables
UIImage *SaveImage;
NSData *pictureData;
PFFile *file;
NSString *userLoggedIn;
NSString *badgeString;
NSString *tracesBadgeString;
NSUserDefaults *defaults;
UIImageView *mainImage;
UIColor *theColor;
double hue;

@interface CanvasViewController ()

@end

@implementation CanvasViewController

@synthesize mainImage,red,green,blue,brush,currentColorImage;

//----------------------------------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewDidLoad
{
    
    userLoggedIn = @"LoggedIn";
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userLoggedIn forKey:@"theUser"];
    [defaults synchronize];
    
    [self countRequests];
    [self countTraces];
    
    red = 255;
    green = 0;
    blue = 0;
    brush = 11.0;
    opacity = 1.0;
    
    theColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
    
    UIGraphicsBeginImageContext(self.currentColorImage.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 25);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, 1.0);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.currentColorImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

//----------------------------------------------------------------------------------
//
// Name: viewWillAppear
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) viewWillAppear:(BOOL)animated
{
    
    [self becomeFirstResponder];
    
    if (clearImage)
    {
        
        mainImage.image = nil;
        
    }
    
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
    
    [self becomeFirstResponder];
    
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
// Name: motionBegan
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
    if (motion == UIEventSubtypeMotionShake)
    {
        
        [UIView beginAnimations:@"suck" context:NULL];
        [UIView setAnimationTransition:108 forView:mainImage cache:NO];
        [UIView setAnimationDuration:0.9f];
        [UIView commitAnimations];
        
        self.mainImage.image = nil;
        
        NSLog(@"shoke the app...");
        
        //DTRB - does not work....
        
    }
    

    
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
    
    [toUserQuery whereKey:@"toUser" equalTo:[[PFUser currentUser]username]];
    [toUserQuery whereKey:@"deliveredToUser" equalTo:@"NO"];
    
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"TracesObject"];
    
    [fromUserQuery whereKey:@"fromUser" equalTo:[[PFUser currentUser]username]];
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
                
                [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setBadgeValue:tracesBadgeString];
                
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
    
    //DTRB
    
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
        
        NSLog(@"selectAContact segue");
     
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
        
        UIGraphicsBeginImageContext(self.currentColorImage.frame.size);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 25);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, 1.0);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(),45, 45);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),45, 45);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.currentColorImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
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
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll", @"Cancel", nil];
    
    [actionSheet showInView:self.view];
    
}

//----------------------------------------------------------------------------------
//
// Name: actionSheet
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)
    {
        
        UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
        [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
        UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(SaveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }
    
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image could not be saved. Please try again"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        
        [alert show];
        
    }
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image was successfully saved in photoalbum"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        
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

-(void) uploadTrace
{
    
    NSLog(@"in uploadTrace");
    
    UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
    [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
    SaveImage = UIGraphicsGetImageFromCurrentImageContext();
    pictureData = UIImageJPEGRepresentation(SaveImage, 1.0);
    UIGraphicsEndImageContext();
    
    file = [PFFile fileWithName:@"img" data:pictureData];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            PFObject *imageObject = [PFObject objectWithClassName:@"TracesObject"];
            [imageObject setObject:file forKey:@"image"];
            [imageObject setObject:[PFUser currentUser].username forKey:@"fromUser"];
            [imageObject setObject:@"danrbrown" forKey:@"toUser"];
            [imageObject setObject:@"NO"forKey:@"deliveredToUser"];
            
            [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
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
     progressBlock:^(int percentDone) {
         
        NSLog(@"Uploaded: %d %%", percentDone);
         
    }];
    
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
    
    /* ----Start DRB ---------------------------------------
    // Get the user we want to push the notification to
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:@"danrbrown"];
    PFUser *user = (PFUser *)[query getFirstObject];
    
    // Define a text message
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Someone sent you a trace!", @"alert", nil];
    
    // Prepare to send the push notification
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our installation query
    [push setData:data];
    [push sendPushInBackground];
    
    NSLog(@"Just saved the installation");
    // End of the push sequence. Need to clean up later.
    ----End DRB ---------------------------------------*/
    
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
    
    UIGraphicsBeginImageContext(self.currentColorImage.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 29);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, 1.0);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.currentColorImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

@end













