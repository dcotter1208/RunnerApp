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
    
    //WILL DELETE THIS after authentication is fixed...
    [self performSegueWithIdentifier:@"enterAppSegue" sender:self];
    
    [self isUserCurrentlyLoggedIn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)isUserCurrentlyLoggedIn {
    [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth *auth,
                                                    FIRUser *user) {
        if (user != nil) {
            [self performSegueWithIdentifier:@"enterAppSegue" sender:self];
        } else {
            NSLog(@"Please sign in with your email and password");
        }
    }];
}

-(void)loginFailedAlertView {
    UIAlertController *alertController =[UIAlertController
                                         alertControllerWithTitle:@"Whoops!"
                                         message:@"Please check your email or password. No account? Sign up!"
                                         preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:true completion:nil];
    
}

-(void)validateUserLoginInfo {
    [[FIRAuth auth] signInWithEmail:_emailTF.text password:_passwordTF.text completion:^(FIRUser *user, NSError *error) {
             if (error) {
                 [self loginFailedAlertView];
                 NSLog(@"Error: %@", error.description);
             } else {
                 [self performSegueWithIdentifier:@"enterAppSegue" sender:self];
             }
        }];
}

- (IBAction)loginButtonPressed:(id)sender {

    [self validateUserLoginInfo];
}

- (IBAction)signUpButtonPressed:(id)sender {
    
}


@end
