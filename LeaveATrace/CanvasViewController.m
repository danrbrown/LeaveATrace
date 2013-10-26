//
//  CanvasViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/19/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "CanvasViewController.h"

#import <Twitter/Twitter.h>

#import <Parse/Parse.h>

@interface CanvasViewController ()

@end

@implementation CanvasViewController

@synthesize mainImage;

- (void)viewDidLoad
{
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
     
    brush = 11.0;
    opacity = 1.0;
        
    DrawAnything.hidden = YES;
        
    SendToAnyone.hidden = YES;
    
}

-(IBAction)clear:(id)sender {
    
    if (self.mainImage.image != nil) {

        [UIView beginAnimations:@"suck" context:NULL];
        [UIView setAnimationTransition:103 forView:mainImage cache:NO];
        [UIView setAnimationDuration:1.5f];
        [UIView commitAnimations];
    
        self.mainImage.image = nil;
        
        //[DrawAnything setHidden:YES];
        //[SendToAnyone setHidden:YES];
        
    }
    
    self.mainImage.image = nil;
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = NO;
    
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self.view];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
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
    
    //[SendToAnyone setHidden:YES];
    //[DrawAnything setHidden:YES];
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(!mouseSwiped) {
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
    
    //[SendToAnyone setHidden:NO];

}

-(IBAction)undo:(id)sender {
    

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SettingsViewController * settingsVC = (SettingsViewController *)segue.destinationViewController;
    settingsVC.delegate = self;
    settingsVC.red = red;
    settingsVC.green = green;
    settingsVC.blue = blue;
    settingsVC.brush = brush;
    
}

#pragma mark - SettingsViewControllerDelegate methods

- (void)closeSettings:(id)sender {
    
    red = ((SettingsViewController*)sender).red;
    green = ((SettingsViewController*)sender).green;
    blue = ((SettingsViewController*)sender).blue;
    brush = ((SettingsViewController*)sender).brush;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save to Camera Roll", @"Tweet it!", @"Cancel", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
        Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
        
        if(tweeterClass != nil) {   // check for Twitter integration
            
            // check Twitter accessibility and at least one account is setup
            if([TWTweetComposeViewController canSendTweet]) {
                
                UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO,0.0);
                [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
                UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
                // set initial text
                [tweetViewController setInitialText:@"Check out this drawing I made from a tutorial on raywenderlich.com:"];
                
                // add image
                [tweetViewController addImage:SaveImage];
                tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                    if(result == TWTweetComposeViewControllerResultDone) {
                        // the user finished composing a tweet
                    } else if(result == TWTweetComposeViewControllerResultCancelled) {
                        // the user cancelled composing a tweet
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                };
                
                [self presentViewController:tweetViewController animated:YES completion:nil];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You can't send a tweet right now, make sure you have at least one Twitter account setup and your device is using iOS5" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You must upgrade to iOS5.0 in order to send tweets from this application" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
    } else if(buttonIndex == 0) {
        
        UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
        [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
        UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageWriteToSavedPhotosAlbum(SaveImage, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Image could not be saved.Please try again"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image was successfully saved in photoalbum"  delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    }
}

-(IBAction)send:(id)sender {
    
    UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
    [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
    UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *pictureData = UIImageJPEGRepresentation(SaveImage, 1.0);
    UIGraphicsEndImageContext();
    
    PFFile *file = [PFFile fileWithName:@"img" data:pictureData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded){
            //2
            //Add the image to the object, and add the comment and the user
            PFObject *imageObject = [PFObject objectWithClassName:@"WallImageObject"];
            [imageObject setObject:file forKey:@"image"];
            [imageObject setObject:[PFUser currentUser].username forKey:@"user"];
            //3
            
            NSLog(@"u did it");
            [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //4
                if (succeeded){
                    //Go back to the wall
                    [self.navigationController popViewControllerAnimated:YES];
                    NSLog(@"u did it");
                }
                else{
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    NSLog(@"u suck");
                }
            }];
        }
        else{
            //5
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            NSLog(@"u suck");
        }
    } progressBlock:^(int percentDone) {
        NSLog(@"Uploaded: %d %%", percentDone);
    }];
    
}

@end





