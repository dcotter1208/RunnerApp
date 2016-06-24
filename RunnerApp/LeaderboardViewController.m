//
//  LeaderboardViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/13/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "Run.h"
#import "RunTableViewCell.h"
@import FirebaseAuth;
@import FirebaseDatabase;
@import Firebase;

@interface LeaderboardViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *runTableView;
@property(nonatomic, strong) NSMutableArray *runArray;

@end

@implementation LeaderboardViewController

- (void)viewDidLoad {
    _runArray = [[NSMutableArray alloc]init];
    [self queryRunsFromFirebase];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)queryRunsFromFirebase {
        
    FIRDatabaseReference *fbDataService = [[FIRDatabase database] reference];
    FIRDatabaseReference *runsRef = [fbDataService.ref child:@"runs"];
    FIRDatabaseQuery *currentUserRunHistory = [[runsRef queryOrderedByChild:@"runner"] queryEqualToValue:[FIRAuth auth].currentUser.uid];
    
    [currentUserRunHistory observeEventType: FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        Run *run = [[Run alloc]initWithRunner:snapshot.value[@"runner"]
                                     duration:[snapshot.value[@"duration"]intValue]
                                     distance:[snapshot.value[@"distance"]floatValue]
                                     date:snapshot.value[@"date"]
                                     pace: snapshot.value[@"overallPace"]
                                     temperature:snapshot.value[@"temperature"]
                                     humidity:snapshot.value[@"humidity"]
                                     precipitation:snapshot.value[@"precipitation"]];
        
        [_runArray addObject:run];
        [_runTableView reloadData];
    }];
}

-(NSString *)formatRunTime:(int)runTime {
    int seconds2 = runTime % 60;
    int minutes2 = (runTime / 60) % 60;
    int hours2 = (runTime / 3600);
    NSString *formattedTime = [NSString stringWithFormat:@"%02ih:%02im:%02is", hours2, minutes2, seconds2];
    
    return formattedTime;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_runArray count];
}

-(RunTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"runCell" forIndexPath:indexPath];
    
    Run *run = [_runArray objectAtIndex:indexPath.row];
    
    cell.dateLabel.text = run.date;
    cell.durationLabel.text = [NSString stringWithFormat:@"Duration: %@", [self formatRunTime:run.duration]];
    cell.distanceLabel.text = [NSString stringWithFormat:@"Distance: %.2f", run.distance];
    cell.paceLabel.text = [NSString stringWithFormat:@"Pace: %@", run.pace];
    cell.weatherLabel.text = [NSString stringWithFormat:@"Weather: %@ \u00B0, %@ humidity, %@ precip.", run.temperature, run.humidity, run.precipitation];
    
    return cell;
    
}


@end
