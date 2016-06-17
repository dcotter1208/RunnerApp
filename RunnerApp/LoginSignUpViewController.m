//
//  LoginSignUpViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/17/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

@import FirebaseAuth;
#import "LoginSignUpViewController.h"

@interface LoginSignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation LoginSignUpViewController

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

- (IBAction)loginButtonPressed:(id)sender {
    
}

- (IBAction)signUpButtonPressed:(id)sender {
    
}


@end
