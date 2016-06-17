//
//  LoginSignUpViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/17/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

@import FirebaseAuth;
#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self validateCurrentUser];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)validateCurrentUser {
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *auth,
                                                    FIRUser *user) {
        if (user != nil) {
            [self performSegueWithIdentifier:@"enterAppSegue" sender:self];
        } else {
            NSLog(@"Please sign in with your email and password");
        }
    }];
}

-(void)signUpAlertView {
    UIAlertController *alertController =[UIAlertController
                                         alertControllerWithTitle:@"Welcome!"
                                         message:@"Please sign up with an email and password."
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    UITextField *email = alertController.textFields.firstObject;
    UITextField *password = alertController.textFields.lastObject;
    
    
    
}

- (IBAction)loginButtonPressed:(id)sender {
    
}

- (IBAction)signUpButtonPressed:(id)sender {
    
}


@end
