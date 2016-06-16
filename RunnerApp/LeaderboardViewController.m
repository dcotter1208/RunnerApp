//
//  LeaderboardViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/13/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "Run.h"
@import FirebaseDatabase;
@import Firebase;


@interface LeaderboardViewController ()

@property(nonatomic, strong) NSMutableArray *runArray;

@end

@implementation LeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self queryRunsFromFirebase];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)queryRunsFromFirebase {
    FIRDatabaseReference *fbDataService = [[FIRDatabase database] reference];
    FIRDatabaseReference *spotRef = [fbDataService.ref child:@"runs"];
    
    [spotRef observeEventType:FIRDataEventTypeChildAdded
                    withBlock:^(FIRDataSnapshot *snapshot) {
                        
                        NSLog(@"Snapshot: %@", snapshot.value);
                        
                        Run *run = [[Run alloc]initRun:[snapshot.value[@"duration"] intValue] distance:[snapshot.value[@"distance"] floatValue] date:snapshot.value[@"date"]];

                        NSLog(@"RUN: %@", run);
                        
                        [_runArray addObject:run];

        }];
}

- (IBAction)pressButton:(id)sender {
    
    [self queryRunsFromFirebase];
    
}


@end
