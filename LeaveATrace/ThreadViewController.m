//
//  ThreadViewController.m
//  LeaveATrace
//
//  Created by RICKY BROWN on 11/27/13.
//  Copyright (c) 2013 15and50. All rights reserved.
//

#import "ThreadViewController.h"

#import "CanvasViewController.h"
#import "tracesViewController.h"

@interface ThreadViewController ()

@end

@implementation ThreadViewController

@synthesize mainThreadImage, currentColorImage, red, green, blue;

- (void)viewDidLoad
{
    
    NSString *userWhoSentTrace = [traceObject objectForKey:@"fromUser"];
    NSLog(@"User who sent trace --> %@, objectId --> %@",userWhoSentTrace,traceObjectId);
    [self getThreadTrace:userWhoSentTrace];
    
    self.title = userWhoSentTrace;
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    
    brush = 11.0;
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
    
    NSLog(@"about to load trace");

    
}

-(void) getThreadTrace:(NSString *)userWhoSentTrace {
    
    // REVIEW HOW THIS IS BEING DONE
    
    PFQuery *traceQuery = [PFQuery queryWithClassName:@"TracesObject"];
    
//    [traceQuery whereKey:@"fromUser" equalTo:userWhoSentTrace];
//    [traceQuery whereKey:@"deliveredToUser" equalTo:@"NO"];
//    [traceQuery orderByDescending:@"createdAt"];   // or sort by orderByAscending
//    [traceQuery setLimit:1];

    [traceQuery whereKey:@"objectId" equalTo:traceObjectId];
    
    [traceQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"The find in getThreadTrace succeeded %lu", (unsigned long)objects.count);
            for (PFObject *myImages in objects) {
                PFFile *imageFile = [myImages objectForKey:@"image"];
                imageFile = [myImages objectForKey:@"image"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {

                        NSLog(@"Hope this works!");
                        UIImage *image = [UIImage imageWithData:data];
                        mainThreadImage.image = image;
                        
                        // Now update the database that this image was delivered to the user
                        [myImages setObject:@"YES"forKey:@"deliveredToUser"];
                        [myImages saveInBackground];
                    }
                }];
                NSLog(@"%@",myImages.objectId);
            }
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    mouseSwiped = NO;
    
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self.view];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(!mouseSwiped) {
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

- (UIImage*)convertToMask:(UIImage *)image {
    
    if (image != nil) {
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
        CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
    
        CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 0.9f);
        CGContextFillRect(ctx, imageRect);
        
        [image drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
        UIImage* outImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return outImage;
        
    } else {
        
        return image;
        
    }
}

-(void) uploadThreadTrace {
    
    NSLog(@"in uploadThreadTrace");
    NSString *userWhoSentTrace = [traceObject objectForKey:@"fromUser"];
    NSLog(@"user who sent trace in upload --> %@",userWhoSentTrace);
    
    UIGraphicsBeginImageContextWithOptions(mainThreadImage.bounds.size, NO, 0.0);
    [mainThreadImage.image drawInRect:CGRectMake(0, 0, mainThreadImage.frame.size.width, mainThreadImage.frame.size.height)];
    UIImage *saveThreadImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *threadPictureData = UIImageJPEGRepresentation(saveThreadImage, 1.0);
    UIGraphicsEndImageContext();
    
    PFFile *imageFile  = [PFFile fileWithName:@"img" data:threadPictureData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded){
            
            [traceObject setObject:imageFile forKey:@"image"];
          //  [traceObject setObject:[PFUser currentUser].username forKey:@"fromUser"];
          //  [traceObject setObject:userWhoSentTrace forKey:@"toUser"];
            [traceObject setObject:@"NO"forKey:@"deliveredToUser"];
            
            [traceObject saveInBackground];
                        
            [traceObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded){
                    
                    NSString *userWhoSentTrace = [traceObject objectForKey:@"fromUser"];
        
                    NSString *sentMessage = [NSString stringWithFormat:@"Trace was sent to %@", userWhoSentTrace];
                    
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Nice drawing..." message:sentMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                    
                    
                } else {
                    
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [errorAlertView show];
                    
                    
                }
            }];
        } else {
            
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            
        }
        
    } progressBlock:^(int percentDone) {
        
        NSLog(@"Uploaded return trace: %d %%", percentDone);
        
    }];

}

-(IBAction)send:(id)sender {
    
    [self uploadThreadTrace];
}

-(IBAction)eraser:(id)sender {
    
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    brush = 28.0;
    opacity = 1.0;
    
    UIGraphicsBeginImageContext(self.currentColorImage.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 35);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), self.red, self.green, self.blue, 1.0);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(),45, 45);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.currentColorImage.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

-(IBAction)undo:(id)sender {
    
    
    
}

-(IBAction)clear:(id)sender {
    
    if (self.mainThreadImage.image != nil) {
        
        [UIView beginAnimations:@"suckIt" context:NULL];
        [UIView setAnimationTransition:108 forView:mainThreadImage cache:NO];
        [UIView setAnimationDuration:0.9f];
        [UIView commitAnimations];
        
        self.mainThreadImage.image = nil;
        
    }
    
    self.mainThreadImage.image = nil;
    
}

- (IBAction)save:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save to Camera Roll", @"Cancel", nil];
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        
        UIGraphicsBeginImageContextWithOptions(mainThreadImage.bounds.size, NO, 0.0);
        [mainThreadImage.image drawInRect:CGRectMake(0, 0, mainThreadImage.frame.size.width, mainThreadImage.frame.size.height)];
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

@end









