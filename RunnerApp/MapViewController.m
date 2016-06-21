//
//  MapViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/13/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

@import Firebase;
@import FirebaseDatabase;
@import FirebaseAuth;
#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Run.h"
#import "Themer.h"

@interface MapViewController ()
//Outlets
@property (weak, nonatomic) IBOutlet UIButton *startAndPauseButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

//Properties
@property (nonatomic, strong) NSMutableArray *recordedLocations;
@property (nonatomic) float distance;
@property (nonatomic) float accumulatedDistance;
@property (nonatomic) int seconds;

@end

CLLocation *newLocation;
MKCoordinateRegion userLocation;
@implementation MapViewController

- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:true];
    [super viewDidLoad];
    
    _accumulatedDistance = 0;

    [self mapSetup];
    [self initDesignElements];
    [self customUISetup];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Save Run Options Methods

-(void)saveRun {
    [_startAndPauseButton setTitle:@"Start" forState:UIControlStateNormal];
    [_timer invalidate];
    
    //Grab the current date and turn it into a string.
    NSDate* now = [NSDate date];
    NSString *timeStamp = [self formattedDate:now];
    
    Run *run = [[Run alloc]initWithRunner:[FIRAuth auth].currentUser.uid duration:_seconds distance:_accumulatedDistance date:timeStamp];
    
    [self saveRunToFirebase:run];
    
    //will update conditionally based on dialog in future -- alert field
    _accumulatedDistance = 0;
}

-(void)discardRun {
    [_startAndPauseButton setTitle:@"Start" forState:UIControlStateNormal];
    [_timer invalidate];
    
    _seconds = 0;
    _accumulatedDistance = 0;
    _durationLabel.text = [NSString stringWithFormat:@"Time:"];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance (miles):"];
}


#pragma mark Timer Methods

-(void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                              target:self
                                            selector:@selector(eachSecond)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)eachSecond {
    _seconds++;
    _accumulatedDistance += _distance;
    //NSLog(@"Accumulated Distance: %@", [self formatRunDistance:_accumulatedDistance]);
    _durationLabel.text = [NSString stringWithFormat:@"Time: %@", [self formatRunTime:_seconds]];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance (miles): %@", [self formatRunDistance:_accumulatedDistance]];
}


#pragma mark Save To Firebase

-(void)saveRunToFirebase:(Run *)run {
    float miles = run.distance/1609.344;
    
    FIRDatabaseReference *fbDataService = [[FIRDatabase database] reference];
    
    FIRDatabaseReference *runsRef = [fbDataService child:@"runs"].childByAutoId;
    
    NSDictionary *runToAdd = @{@"runner": run.runner, @"duration": [NSNumber numberWithInt:run.duration],
                               @"distance": [NSNumber numberWithFloat:miles],
                               @"date": run.date};
    
    [runsRef setValue:runToAdd];
}

#pragma mark Helper Methods

-(void)alertMessage:(NSString*)message {
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Alert"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* saveAction = [UIAlertAction
                                 actionWithTitle:@"Save" style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [self saveRun];
                                 }];
    UIAlertAction* discardAction = [UIAlertAction
                                    actionWithTitle:@"Discard" style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self discardRun];
                                    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:saveAction];
    [alert addAction:discardAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)customUISetup {
    Themer *mvcTheme = [[Themer alloc]init];
    [mvcTheme themeButtons: _buttons];
    [mvcTheme themeLabels: _labels];
    [mvcTheme themeMaps: _maps];
    _startAndPauseButton.backgroundColor = [UIColor colorWithRed:39.0f/255.0f green:196.0f/255.0f blue:36.0f/255.0f alpha:1.0];
    _stopButton.backgroundColor = [UIColor redColor];
}

//Puts the semi-translucent view in that the start/stop/distance/duration views sit on.
-(void)initDesignElements {
    CGRect screenRect = {{0, [[UIScreen mainScreen] bounds].size.height-170}, {CGRectGetWidth(self.view.bounds), 170}};
    UIView* coverView = [[UIView alloc] initWithFrame:screenRect];
    coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [self.view insertSubview:coverView atIndex:1];
}


//Formats the run time into hours, minutes, seconds.
-(NSString *)formatRunTime:(int)runTime {
    int seconds2 = runTime % 60;
    int minutes2 = (runTime / 60) % 60;
    int hours2 = (runTime / 3600);
    NSString *formattedTime = [NSString stringWithFormat:@"%02i:%02i:%02i", hours2, minutes2, seconds2];
    //NSLog(@"time formatter");
    return formattedTime;
}

//Formats the distance into miles.
-(NSString *)formatRunDistance:(float)runDistance {
    float miles = runDistance/1609.344;
    NSString *formattedDistance = [NSString stringWithFormat:@"%.2f", miles];
    
    return formattedDistance;
}

//Formats the date into MM/DD/YYYY format.
-(NSString *)formattedDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/YYYY"];
    NSString *formattedRunDate = [dateFormatter stringFromDate:date];
    
    return formattedRunDate;
}

//Sets up the MapView.
-(void)mapSetup {
    //check constraints on this as they seem to be causing map size errors on phones > 5
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:true];
    [self getUserLocation];
}

#pragma mark Location Methods

-(void)getUserLocation {
    
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc]init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [_locationManager setActivityType:CLActivityTypeFitness];
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager setDistanceFilter:10];
        [_locationManager startUpdatingLocation];
        newLocation = _locationManager.location;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    for (CLLocation *newLocation in locations) {
        if (newLocation.horizontalAccuracy < 20) {
            // update distance
            if (self.recordedLocations.count > 0) {
                _distance = [newLocation distanceFromLocation:self.recordedLocations.lastObject];
            }
            
            [self.recordedLocations addObject:newLocation];
            
            //Creates a region based on the user's new location.
            userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500.0, 500.0);
            
            //map's region is set using the region we made from the user's location. Each time the user's location changes this method is called and the new map region is set.
            [_mapView setRegion:userLocation animated:YES];
            
        }
    }
}


- (IBAction)stopButtonPressed:(id)sender {
    [self alertMessage:@"Are you ready to save your run?"];
}


- (IBAction)startAndPauseButtonPressed:(id)sender {

    //START
    if ([_startAndPauseButton.titleLabel.text isEqualToString:@"Start"]) {
        _seconds = 0;
        _distance = 0;
        _accumulatedDistance = 0;
        _recordedLocations = [NSMutableArray array];
        [self startTimer];
        [_startAndPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    //PAUSE
    else if ([_startAndPauseButton.titleLabel.text isEqualToString:@"Pause"]) {
        [_timer invalidate];
        [_startAndPauseButton setTitle:@"Resume" forState:UIControlStateNormal];
        _recordedLocations = [NSMutableArray array];
    }
    //RESUME
    else {
        [self startTimer];
        _distance = _accumulatedDistance;
        [_startAndPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    
}

@end
