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
#import "tracesViewController.h"
#import "AppDelegate.h"

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
    
    undoThreadImageArray = [[NSMutableArray alloc] init];
    
    red = 0;
    green = 0;
    blue = 255;
    brush = 11.0;
    opacity = 1.0;
    
    self.colorValue.value = 0.640678;
    self.brushSize.value = brush;
    
    hue = 0.640678;
    
    theColor = [UIColor colorWithHue:hue saturation:1.0 brightness:1.0 alpha:1.0];
    
    currentColorImage.backgroundColor = theColor;
    currentColorImage.layer.cornerRadius = 2.0;
    currentColorImage.layer.borderColor = [UIColor blackColor].CGColor;
    currentColorImage.layer.borderWidth = 3.0;

    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * 1.5);
    self.brushSize.transform = trans;
    
    int smallScreen = 480;
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if(result.height == smallScreen)
    {
        
        sendB.frame = CGRectMake(246, 434, 64, 40);
        trashB.frame = CGRectMake(112, 431, 39, 45);
        undoB.frame = CGRectMake(61, 434, 45, 40);
        saveB.frame = CGRectMake(7, 432, 49, 43);
        
    }
    
    int bigScreen = 568;
    
    if(result.height == bigScreen)
    {
        
        sendB.frame = CGRectMake(sendB.frame.origin.x, sendB.frame.origin.y, 64, 40);
        trashB.frame = CGRectMake(trashB.frame.origin.x, trashB.frame.origin.y, 39, 45);
        undoB.frame = CGRectMake(undoB.frame.origin.x, undoB.frame.origin.y, undoB.frame.size.width, undoB.frame.size.height);
        saveB.frame = CGRectMake(saveB.frame.origin.x, saveB.frame.origin.y, 49, 43);
        
    }
    
}

-(BOOL) prefersStatusBarHidden
{

    return YES;
    
}

//----------------------------------------------------------------------------------

-(void) viewDidAppear:(BOOL)animated
{
    
    traceObject = [(APP).tracesArray objectAtIndex:traceObjectIdx];
    
    traceObjectId = [traceObject objectId];
    
    NSString *userWhoSentTrace = [traceObject objectForKey:@"toUser"];
    NSString *tmpStatus = [traceObject objectForKey:@"status"];
    
    otherUser.text = userWhoSentTrace;
    
    [self getThreadTrace:userWhoSentTrace traceObjectStatus:tmpStatus];

}


//----------------------------------------------------------------------------------
//
// Name: getThreadTrace
//
// Purpose:
//
//----------------------------------------------------------------------------------

//this should be done better - shouldn't loop since we're bringing back one image Dan DRB

-(void) getThreadTrace:(NSString *)userWhoSentTrace traceObjectStatus:(NSString *)traceStatus
{
    
    viewText = 1;
    
    [self loadingTrace];
    
    PFQuery *traceQuery = [PFQuery queryWithClassName:@"TracesObject"];

    [traceQuery whereKey:@"objectId" equalTo:traceObjectId];
    
    [traceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error)
        {
            
            for (PFObject *myImages in objects)
            {
            
                PFFile *imageFile = [myImages objectForKey:@"image"];
                imageFile = [myImages objectForKey:@"image"];
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    
                    if (!error)
                    {

                        UIImage *image = [UIImage imageWithData:data];
                        mainThreadImage.image = image;
                        
                        [loadingTrace stopAnimating];
                        [_hudView removeFromSuperview];
                        
                        NSString *tmpCurrentUser = [[PFUser currentUser]username];
                        NSString *tmpLastSentBy = [myImages objectForKey:@"lastSentBy"];
                        
                        if (![tmpCurrentUser isEqualToString:tmpLastSentBy])
                        {
                            
                            if (((APP).unopenedTraceCount > 0) && ([traceStatus isEqualToString:@"D"]))
                                (APP).unopenedTraceCount--;
                            
                            [myImages setObject:@"O"forKey:@"status"];
                            [traceObject setObject:@"O"forKey:@"status"];
                            [myImages saveInBackground];
                            
                        }
                    }
                    
                }];
                
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
    
    UIGraphicsBeginImageContextWithOptions(mainThreadImage.bounds.size, NO, 0.0);
    [mainThreadImage.image drawInRect:CGRectMake(0, 0, mainThreadImage.frame.size.width, mainThreadImage.frame.size.height)];
    undoThreadImage = UIGraphicsGetImageFromCurrentImageContext();
    [undoThreadImageArray addObject:undoThreadImage];
    
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
    
//    viewText = 2;
//    
//    [self loadingTrace];
//    
//    [sendB setEnabled:NO];
//    
//    [sendB setAlpha:0.5];
    
    [self uploadThreadTrace];
    
    [self close:nil];
    
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
    
    UISlider *changedSlider = (UISlider*)sender;
    
    if(changedSlider == self.brushSize)
    {
        
        brush = self.brushSize.value;
        
    }
    
    if(changedSlider == self.colorValue)
    {
        
        theColor = [UIColor colorWithHue:changedSlider.value saturation:1.0 brightness:1.0 alpha:1.0];
        
        CGColorRef colorRef = [theColor CGColor];
        
        const CGFloat *_components = CGColorGetComponents(colorRef);
        red     = _components[0];
        green = _components[1];
        blue   = _components[2];
        
        currentColorImage.backgroundColor = theColor;
        
        if (changedSlider.value <= -0.1)
        {
            
            red = 255;
            blue = 255;
            green = 255;
            
            currentColorImage.backgroundColor = [UIColor whiteColor];
            
        }
        
        if (changedSlider.value > 0.85)
        {
            
            
            red = 0;
            blue = 0;
            green = 0;
            
            currentColorImage.backgroundColor = [UIColor blackColor];
            
        }
        
    }
    
}

//----------------------------------------------------------------------------------
//
// Name: sendPushToContact
//
// Purpose: Will send a push to a specifc user. It gets the Installation record
// for this user and then sends the push.
//
// To debug this incase it isn't working. There should be a row in the
// Installation object and the deviceToken should have a value (some long string).
// The 'user' field for that Installation record should be the 'objectId' in
// the User object for that user.
//
//----------------------------------------------------------------------------------

-(void) sendPushToContact:(NSDictionary *)dataParms
{
    
    NSString *pushRecipient = [dataParms objectForKey:@"friend"];
    NSString *oldObjectId = [dataParms objectForKey:@"objectId"];

    NSString *pushMessage = [NSString stringWithFormat:@"%@ has responded to your Trace!", [PFUser currentUser].username];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"username" equalTo:pushRecipient];
    PFUser *user = (PFUser *)[userQuery getFirstObject];
    
    NSString *friendLoggedIn = [user objectForKey:@"LoggedIn"];
    
    if ([friendLoggedIn isEqualToString:@"Y"])
    {
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:pushMessage, @"alert",
                              @"Thread",@"msgType",
                              oldObjectId, @"objId",
                              [PFUser currentUser].username,@"sender",
                              pushRecipient, @"friend",nil];
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:user];
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
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
    
    UIGraphicsBeginImageContextWithOptions(mainThreadImage.bounds.size, NO, 0.0);
    [mainThreadImage.image drawInRect:CGRectMake(0, 0, mainThreadImage.frame.size.width, mainThreadImage.frame.size.height)];
    
    UIImage *saveThreadImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *threadPictureData = UIImageJPEGRepresentation(saveThreadImage, 1.0);
    UIGraphicsEndImageContext();
    
    PFFile *imageFile  = [PFFile fileWithName:@"img" data:threadPictureData];
    NSDate *currentDateTime = [NSDate date];
    
    NSString *tmpFriend;
    NSString *tmpFromUser = [traceObject objectForKey:@"fromUser"];
    NSString *tmpToUser = [traceObject objectForKey:@"toUser"];
    NSString *tmpCurrentUser = [PFUser currentUser].username;
    
    if ([tmpCurrentUser isEqualToString:tmpFromUser])
    {
        
        tmpFriend = tmpToUser;
        
    }
    else
    {
        
        tmpFriend = tmpFromUser;
        
    }
 
    [traceObject setObject:imageFile forKey:@"image"];
    [traceObject setObject:@"YES"forKey:@"fromUserDisplay"];
    [traceObject setObject:@"YES"forKey:@"toUserDisplay"];
    [traceObject setObject:[PFUser currentUser].username forKey:@"lastSentBy"];
    [traceObject setObject:currentDateTime forKey:@"lastSentByDateTime"];
    [traceObject setObject:@"P"forKey:@"status"];

    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded)
        {
            
            [traceObject setObject:@"S"forKey:@"status"];
            [traceObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded)
                {
                    
                    NSString *oldObjectId = [traceObject objectId];
                    
                    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:tmpFriend, @"friend",
                                          oldObjectId, @"objectId", nil];
                    
                    [self performSelectorInBackground:@selector(sendPushToContact:)
                                           withObject:data];

                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"SendTraceNotification"
                     object:self];
                    
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
        
        NSLog(@"%d %% done", percentDone);
        
    }];

}

//----------------------------------------------------------------------------------
//
// Name: close
//
// Purpose: closes the tread view.
//
//----------------------------------------------------------------------------------

-(IBAction) close:(id)sender
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

//----------------------------------------------------------------------------------
//
// Name: undo
//
// Purpose: It will undo the last line the user drew.
//
//----------------------------------------------------------------------------------

-(IBAction) undoThread:(id)sender
{
    
    if (undoThreadImageArray.count > 0)
    {
        
        undoThreadImage = [undoThreadImageArray lastObject];
        
        [undoThreadImageArray removeLastObject];
        
        mainThreadImage.image = undoThreadImage;
        
        NSLog(@"undo?");
        
    }
    
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
    
    viewText = 4;
    [self loadingTrace];
    
    UIGraphicsBeginImageContextWithOptions(mainThreadImage.bounds.size, NO, 0.0);
    [mainThreadImage.image drawInRect:CGRectMake(0, 0, mainThreadImage.frame.size.width, mainThreadImage.frame.size.height)];
    UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(SaveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    
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
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh-oh" message:@"Image could not be saved. Please try again"  delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        
        [alert show];
        
    }
    else
    {
        
        viewText = 5;
        
        [_hudView removeFromSuperview];
        
        [self loadingTrace];
        
    }
    
}

-(void) loadingTrace
{
    
    _hudView = [[UIView alloc] initWithFrame:CGRectMake(45, 180, 230, 50)];
    _hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _hudView.clipsToBounds = YES;
    _hudView.layer.cornerRadius = 10.0;
    
    loadingTrace = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingTrace.frame = CGRectMake(25, 16, loadingTrace.bounds.size.width, loadingTrace.bounds.size.height);
    [_hudView addSubview:loadingTrace];
    [loadingTrace startAnimating];
    
    _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 130, 22)];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.adjustsFontSizeToFitWidth = YES;
    _captionLabel.font = [UIFont fontWithName:@"verdana" size:15.0];
    
    if (viewText == 2)
    {
        
        _captionLabel.text = @"Sending trace...";
        
    }
    else if (viewText == 1)
    {
        
        _captionLabel.text = @"Loading trace...";
        
    }
    else if (viewText == 3)
    {
        
        [loadingTrace stopAnimating];
        
        _captionLabel.frame = CGRectMake(53, 15, 130, 22);
        _captionLabel.text = @"Trace was sent!";
        
        [sendB setEnabled:YES];
        
        [sendB setAlpha:1.0];
        
        [self fade];
        
    }
    else if (viewText == 4)
    {
        
        _captionLabel.text = @"Saving trace...";
        
    }
    else if (viewText == 5)
    {
        
        [loadingTrace stopAnimating];
        
        _captionLabel.frame = CGRectMake(53, 15, 130, 22);
        _captionLabel.text = @"Trace was saved!";
        
        [sendB setEnabled:YES];
        
        [sendB setAlpha:1.0];
        
        [self fade];
        
    }

    [_captionLabel setTextAlignment:NSTextAlignmentCenter];
    [_hudView addSubview:_captionLabel];
    
    [self.view addSubview:_hudView];
    
}

-(void) fade
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:5];
    [_hudView setAlpha:0];
    [UIView commitAnimations];
    [_hudView removeFromSuperview];
    
}

@end









