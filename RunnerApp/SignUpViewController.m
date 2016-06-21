//
//  SignUpViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/17/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//
@import FirebaseAuth;
#import "SignUpViewController.h"
#import "Themer.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTF;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Themer *mvcTheme = [[Themer alloc]init];
    [mvcTheme themeButtons: _buttons];
    [mvcTheme themeTextFields: _textFields];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)signUpUserWithFirebase {
    [[FIRAuth auth] createUserWithEmail:_emailTF.text.lowercaseString password:_passwordTF.text completion:^(FIRUser *user, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        }
        NSLog(@"User Email: %@", user.email);
     }];
}

- (IBAction)signUpPressed:(id)sender {
    
    if (![_emailTF.text  isEqual: @""]
        && ![_passwordTF.text  isEqual: @""]
        && ![_repeatPasswordTF.text  isEqual: @""]
        && [_passwordTF.text isEqualToString:_repeatPasswordTF.text] ) {
        [self signUpUserWithFirebase];
    } else {
        NSLog(@"Please Check TextFields");
    }

}


@end
