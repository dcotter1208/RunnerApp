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
            if (error.code == 17007) {
                [self signUpFailedAlertView:@"Sign Up Failed" message:@"This email is already in use."];
            } else if (error.code == 17020) {
                [self signUpFailedAlertView:@"Sign Up Failed" message:@"Please check your network and try again."];
            }
        }
     }];
}

-(BOOL)validateEmail:(NSString *)email {
    
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"self matches %@", emailRegEx];
    BOOL result = [emailTest evaluateWithObject:email];
    
    return result;
}

-(BOOL)validatePassword:(NSString *)password {
    NSString    *regex = @"^(?=.*[a-zA-Z])(?=.*[0-9])[a-zA-Z0-9]*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidPassword = [predicate evaluateWithObject:password];
    return isValidPassword;
}

-(void)signUpFailedAlertView:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController =[UIAlertController
                                         alertControllerWithTitle:title
                                         message:message
                                         preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:true completion:nil];
    
}

- (IBAction)signUpPressed:(id)sender {
    
        //email valid but password fields don't match
    if ([self validateEmail:_emailTF.text] && ![_passwordTF.text isEqualToString:_repeatPasswordTF.text]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"Please make sure your passwords match."];
        //email is not valid but password fields match
    }else if (![self validateEmail:_emailTF.text] && [_passwordTF.text isEqualToString:_repeatPasswordTF.text]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"Please make sure you put in a valid email."];
        //BOTH email and password are not validated
    } else if (![self validateEmail:_emailTF.text] && ![self validatePassword:_passwordTF.text]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"Your email and password aren't valid"];
        //email is valid but password is not.
    } else if ([self validateEmail:_emailTF.text] && ![self validatePassword:_passwordTF.text]) {
        [self signUpFailedAlertView:@"Sign Up Failed" message:@"password must contain letters and numbers"];
    } else {
        [self signUpUserWithFirebase];
    }

}


@end
