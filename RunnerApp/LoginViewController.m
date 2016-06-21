//
//  LoginSignUpViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/17/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

@import FirebaseAuth;
#import "LoginViewController.h"
#import "MapViewController.h"
#import "Themer.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) IBOutlet UILabel *noAccountLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Themer *mvcTheme = [[Themer alloc]init];
    [mvcTheme themeButtons: _buttons];
    [mvcTheme themeLabels: _labels];
    [mvcTheme themeTextFields: _textFields];
    
    _noAccountLabel.font = [UIFont systemFontOfSize:15];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loginFailedAlertView:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController =[UIAlertController
                                         alertControllerWithTitle:title
                                         message:message
                                         preferredStyle:UIAlertControllerStyleAlert];


    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:true completion:nil];
    
}

-(void)validateUserLoginInfo {
    [[FIRAuth auth] signInWithEmail:_emailTF.text password:_passwordTF.text completion:^(FIRUser *user, NSError *error) {
             if (error) {
                 
                 if (error.code == 17999) {
                     [self loginFailedAlertView:@"Login Failed" message:[NSString stringWithFormat:@"%@ doesn't appear to be an existing email", _emailTF.text]];
                 } else if (error.code == 17009) {
                     [self loginFailedAlertView:@"Login Failed" message:@"Your password doesn't appear to be correct. Please try again."];
                 } else {
                     [self loginFailedAlertView:@"Login Failed" message:@"Please try again."];
                 }
             }
        }];
}

- (IBAction)loginButtonPressed:(id)sender {

    [self validateUserLoginInfo];
}

- (IBAction)signUpButtonPressed:(id)sender {
    
}


@end
