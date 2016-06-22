//
//  Themer.m
//  RunnerApp
//
//  Created by tstone10 on 6/18/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Themer.h"
#import "MapViewController.h"

@implementation Themer

-(void)themeButtons:(NSArray *)buttons {
    //NSLog(@"button count = %lu", (unsigned long)buttons.count);
    for (UIButton *btn in buttons) {
        //btn.titleLabel.font = [UIFont fontWithName:@"System" size:18.0];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        //btn.layer.masksToBounds = YES;
        btn.layer.borderWidth = 1.0f;
        btn.layer.borderColor = [[UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0] CGColor];
        //btn.backgroundColor = [UIColor orangeColor];
        btn.layer.backgroundColor = [[UIColor colorWithRed:10.0f/255.0f green:122.0f/255.0f blue:1.0 alpha:1.0] CGColor];

        [btn.layer setShadowOffset:CGSizeMake(2, 2)];
        [btn.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [btn.layer setShadowOpacity:0.5];
    }
}

-(void)themeLabels:(NSArray *)labels {
    for (UILabel *lbl in labels) {
        lbl.font = [UIFont systemFontOfSize:22];
        lbl.textColor = [UIColor blackColor];
    }
}

-(void)themeTextFields:(NSArray *)textFields {
    for (UITextField *tf in textFields) {
        tf.font = [UIFont systemFontOfSize:20];
        tf.layer.cornerRadius = 5;
        tf.layer.masksToBounds = YES;
        tf.layer.borderWidth = 1.0f;
        tf.layer.borderColor = [[UIColor colorWithRed:190.0f/255.0f green:190.0f/255.0f blue:190.0f/255.0f alpha:1.0] CGColor];
    }
}

-(void)themeMaps:(NSArray *)maps {
    //NSLog(@"maps count = %lu", (unsigned long)maps.count);
}

@end
