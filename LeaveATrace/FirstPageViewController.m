//----------------------------------------------------------------
//
//  FirstPageViewController.m
//  LeaveATrace
//
//  Created by Ricky Brown on 11/12/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//
//  Perpose: this file of class ViewController is the first screen
//  that the user sees if he logs out or is the first time using
//  the app. It has two options log in & sign up. 
//
//----------------------------------------------------------------

#import "FirstPageViewController.h"
#import "CanvasViewController.h"

@interface FirstPageViewController () <CommsDelegate>

@property (nonatomic, strong) IBOutlet UIButton *btnLogin;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityLogin;

@end

@interface FirstPageViewController ()

@end

@implementation FirstPageViewController

@synthesize red,blue,green,brush,mainImage;

//---------------------------------------------------------
//
// Name: logInUsingDefaults
//
// Purpose: Log into Parse based on user defaults
//
//---------------------------------------------------------

-(void) logInUsingDefaults:(NSString *)parseUserDef parsePasswordDef:(NSString *)parsePasswordDef
{
    
    NSLog(@"username from defaults --> %@",parseUserDef);
    NSLog(@"password from defaults --> %@",parsePasswordDef);

//    [PFUser logInWithUsernameInBackground:self.userNameTextField.text password:self.passWordTextField.text block:^(PFUser *user, NSError *error) {
   
    [PFUser logInWithUsernameInBackground:parseUserDef password:parsePasswordDef block:^(PFUser *user, NSError *error) {
        
        if (user)
        {
            
            if (![[user objectForKey:@"emailVerified"] boolValue])
            {
                
                [user refresh];
                
                if (![[user objectForKey:@"emailVerified"] boolValue])
                {
                    
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You must verify your email before logging in." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    
                    [errorAlertView show];
                    
                }
                
            }
            else
            {
                
                [self performSegueWithIdentifier:@"userAlreadyLoggedIn" sender:self];
                
            }
            
        }
        else
        {
            
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Try again" message:@"There was a error loging in" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [errorAlertView show];
            
        }
        
    }];
    
}

//---------------------------------------------------------
//
// Name: viewDidAppear
//
// Purpose: when the screen opens and you are logged in
// it will skip this screen and go to the drawing screen
// in the app.
//
//---------------------------------------------------------

- (void) viewDidAppear:(BOOL)animated
{
        
    NSUserDefaults *traceDefaults = [NSUserDefaults standardUserDefaults];
    NSString *tmpUsername = [traceDefaults objectForKey:@"username"];
    NSString *tmpPassword = [traceDefaults objectForKey:@"password"];
    NSLog(@"username from defaults --> %@",tmpUsername);
    NSLog(@"password from defaults --> %@",tmpPassword);
    
    //TMP ONLY REMOVE THIS ONCE IT WORKS DB
    [traceDefaults setObject:@"" forKey:@"username"];
    [traceDefaults setObject:@"" forKey:@"password"];
    [traceDefaults synchronize];
    
    if ([tmpUsername length] != 0)
    {
        
        NSLog(@"user is already logged in");
        
        // DB - need to determine if log in was successful or failure and then act according;
        // Right now it assumes the user logs in.
        [self logInUsingDefaults:tmpUsername parsePasswordDef:tmpPassword];
        
        [self performSegueWithIdentifier:@"userAlreadyLoggedIn" sender:self];
        
    }
    else
    {
        
        NSLog(@"user needs to log in");
        
        //[PFUser logOut];
        
    }
    
}

//---------------------------------------------------------
//
// Name: viewDidLoad
//
// Purpose: when the screen opens and you are logged in
// it will skip this screen and go to the drawing screen
// in the app.
//
//---------------------------------------------------------

- (void)viewDidLoad
{
    
    red = (CGFloat)random()/(CGFloat)RAND_MAX;
    green = (CGFloat)random()/(CGFloat)RAND_MAX;
    blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    brush = 13;
    opacity = 1.0;

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
    
    red = (CGFloat)random()/(CGFloat)RAND_MAX;
    green = (CGFloat)random()/(CGFloat)RAND_MAX;
    blue = (CGFloat)random()/(CGFloat)RAND_MAX;
    
    [self performSelector:@selector(fade) withObject:nil afterDelay:4.0];
    
}

//----------------------------------------------------------------------------------
//
// Name: fade
//
// Purpose:
//
//----------------------------------------------------------------------------------

-(void) fade
{
    
    [UIView beginAnimations:@"suck" context:NULL];
    [UIView setAnimationTransition:108 forView:mainImage cache:NO];
    [UIView setAnimationDuration:1.0f];
    [UIView commitAnimations];
    
    mainImage.image = nil;
    
}

// Outlet for FBLogin button
- (IBAction) loginPressed:(id)sender
{
	// Disable the Login button to prevent multiple touches
	[_btnLogin setEnabled:NO];
	
	// Show an activity indicator
	[_activityLogin startAnimating];
	
	// Do the login
	[commonLogin login:self];
    
}

- (void) commsDidLogin:(BOOL)loggedIn {
	// Re-enable the Login button
	[_btnLogin setEnabled:YES];
    
	// Stop the activity indicator
	[_activityLogin stopAnimating];
    
	// Did we login successfully ?
	if (loggedIn) {
		// Seque to the Image Wall
		[self performSegueWithIdentifier:@"userAlreadyLoggedIn" sender:self];
	} else {
		// Show error alert
		[[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:@"Facebook Login failed. Please try again"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
	}
}

@end


