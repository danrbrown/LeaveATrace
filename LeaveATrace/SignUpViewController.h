//
//  SignUpViewController.h
//  Checklists
//
//  Created by Ricky Brown on 10/26/13.
//  Copyright (c) 2013 Hollance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *userSignUpTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordSignUpTextField;

-(IBAction)signUpUserPressed:(id)sender;

@end
