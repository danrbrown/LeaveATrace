//
//  CanvasViewController.m
//  Checklists
//
//  Created by Ricky Brown on 10/19/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import "CanvasViewController.h"

#import "LoginViewController.h"

#import <Twitter/Twitter.h>

#import <Parse/Parse.h>

@interface CanvasViewController ()

@end

@implementation CanvasViewController {
    
    int menuInt;
    NSArray *imagesArray;
    
    NSMutableArray *pathArray;
    NSMutableArray *bufferArray;
    UIBezierPath *myPath;
    
}

@synthesize mainImage;

- (void)viewDidLoad
{
    
    imagesArray = [[NSArray alloc]initWithObjects:@"menuB.png",@"closeMenuB.png", nil];
    
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
     
    brush = 11.0;
    opacity = 1.0;
    
    getB.hidden = YES;
    
    trashB.center = CGPointMake(35, -100);
    undoB.center = CGPointMake(111, -100);
    eraseB.center = CGPointMake(189, -100);
    colorsB.center = CGPointMake(275, -100);
    menuB.center = CGPointMake(285, 46);
    
    DrawAnything.hidden = YES;
        
    SendToAnyone.hidden = YES;
    
    [super viewDidLoad];
}

-(IBAction)clear:(id)sender {
    
    if (self.mainImage.image != nil) {

        [self dropUp];
        
        menuInt = 0;
        
        [UIView beginAnimations:@"suck" context:NULL];
        [UIView setAnimationTransition:108 forView:mainImage cache:NO];
        [UIView setAnimationDuration:0.9f];
        [UIView commitAnimations];
    
        self.mainImage.image = nil;
        
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
    
    [self dropUp];
    
}

#pragma mark - SettingsViewControllerDelegate methods

- (void)closeSettings:(id)sender {
    
    red = ((SettingsViewController*)sender).red;
    green = ((SettingsViewController*)sender).green;
    blue = ((SettingsViewController*)sender).blue;
    brush = ((SettingsViewController*)sender).brush;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    menuInt = 0;
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
    
    /* ----Start DRB ---------------------------------------
    // Get the user we want to push the notification to
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:@"danrbrown"];
    PFUser *user = (PFUser *)[query getFirstObject];
    
    // Define a text message
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"some text..", @"alert", nil];
    
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
    //----End DRB ---------------------------------------*/
    
    UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
    [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
    UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *pictureData = UIImageJPEGRepresentation(SaveImage, 1.0);
    
    UIGraphicsEndImageContext();
    
    PFFile *file = [PFFile fileWithName:@"img" data:pictureData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded){

            PFObject *imageObject = [PFObject objectWithClassName:@"WallImageObject"];
            [imageObject setObject:file forKey:@"image"];
            [imageObject setObject:[PFUser currentUser].username forKey:@"user"];
            [imageObject setObject:@"N"forKey:@"deliveredToUser"];
            
            [imageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
              
                if (succeeded){
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
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
        NSLog(@"Uploaded: %d %%", percentDone);
    }];
    
}

-(IBAction)getImage:(id)sender {
    
//    UIGraphicsBeginImageContextWithOptions(mainImage.bounds.size, NO, 0.0);
//    [mainImage.image drawInRect:CGRectMake(0, 0, mainImage.frame.size.width, mainImage.frame.size.height)];
//    UIImage *SaveImage = UIGraphicsGetImageFromCurrentImageContext();
//    NSData *pictureData = UIImageJPEGRepresentation(SaveImage, 1.0);
//    
//    UIImage *userimage = [UIImage imageNamed:@"FrameColors.png"];
//    NSData *pictureData2 = UIImageJPEGRepresentation(userimage, 1.0);
//    
//    PFQuery *query = [PFQuery queryWithClassName:@"WallImageObject"];
//    
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        
//        if (!object) {
//            return NSLog(@"%@", error);
//        }
//        
//        PFFile *imageFile = object[@"imageFile"];
//        
//        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            if (!data) {
//                return NSLog(@"%@", error);
//            }
//            
//            // Do something with the image
//            return NSLog(@"Doing something with the image");
//            UIImage *getImage = [UIImage imageWithData:pictureData];
//            mainImage.image = getImage;
//            
//        }];
//    }];
//    
//    return NSLog(@"Doing something with the image");
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"WallImageObject"];
    
    [query whereKey:@"user" equalTo:@"danrbrown"];
    [query whereKey:@"deliveredToUser" equalTo:@"No"];
    [query orderByDescending:@"createdAt"];   // or sort by orderByAscending
    [query setLimit:1];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"The find succeeded!");
            for (PFObject *myImages in objects) {
                PFFile *imageFile = [myImages objectForKey:@"image"];
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *image = [UIImage imageWithData:data];
                         mainImage.image = image;
                        
                        // Now update the database that this image was delivered to the user
                        [myImages setObject:@"Yes"forKey:@"deliveredToUser"];
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

-(IBAction)eraser:(id)sender {
    
    red = 255.0/255.0;
    green = 255.0/255.0;
    blue = 255.0/255.0;
    
    brush = 28.0;
    opacity = 1.0;
    
    [self dropUp];
    
    menuInt = 0;
    
}

-(IBAction)dropDownMenu:(id)sender {
    
    if (menuInt == 0){
    
        [self dropDown];
        
    }
    else if (menuInt == 1){
        
        [self dropUp];
        
        menuInt = 0;
        
    }
    
}

-(void)dropDown {
    
    [UIView animateWithDuration:0.5 animations:^{
        trashB.center = CGPointMake(35, 46);
        undoB.center = CGPointMake(111, 48);
        eraseB.center = CGPointMake(189, 46);
        colorsB.center = CGPointMake(275, 48);
        menuB.center = CGPointMake(285, 110);
        sendB.center = CGPointMake(267, 480);
        saveB.center = CGPointMake(40, 483);
        
        UIImage *buttonImage = [UIImage imageNamed:@"closeMenuB.png"];
        [menuB setImage:buttonImage forState:UIControlStateNormal];
    }];
    
    menuInt = 1;
    
    [menuB setAlpha:0.0];
    [UIView beginAnimations:@"animateTableView" context:nil];
    [UIView setAnimationDuration:0.6];
    [menuB setAlpha:1.0];
    [UIView commitAnimations];
    
}

-(void)dropUp {
    
    [UIView animateWithDuration:0.5 animations:^{
        trashB.center = CGPointMake(35, -100);
        undoB.center = CGPointMake(111, -100);
        eraseB.center = CGPointMake(189, -100);
        colorsB.center = CGPointMake(275, -100);
        menuB.center = CGPointMake(285, 46);
        sendB.center = CGPointMake(267, 600);
        saveB.center = CGPointMake(40, 600);

        UIImage *buttonImage = [UIImage imageNamed:@"menuB.png"];
        [menuB setImage:buttonImage forState:UIControlStateNormal];
    }];
    
    [menuB setAlpha:0.0];
    [UIView beginAnimations:@"animateTableView" context:nil];
    [UIView setAnimationDuration:0.6];
    [menuB setAlpha:1.0];
    [UIView commitAnimations];
    
}

@end













