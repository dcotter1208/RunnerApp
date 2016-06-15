//
//  MapViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/13/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "Run.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startAndPauseButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *recordedLocations;
@property (nonatomic) float distance;
@property (nonatomic) float accumulatedDistance;
@property (nonatomic) int accumulatedSeconds;
@property (nonatomic) int seconds;


@end

CLLocation *newLocation;
MKCoordinateRegion userLocation;
@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _accumulatedDistance = 0;
    _accumulatedSeconds = 0;

    [self mapSetup];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAndPauseButtonPressed:(id)sender {

    if ([_startAndPauseButton.titleLabel.text isEqualToString:@"Start"])
    {
        _seconds = 0;
        _distance = 0;
        _accumulatedDistance = 0;
        _recordedLocations = [NSMutableArray array];
        [self startTimer];
        [_startAndPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else if ([_startAndPauseButton.titleLabel.text isEqualToString:@"Pause"])
    {
        [_timer invalidate];
        [_startAndPauseButton setTitle:@"Resume" forState:UIControlStateNormal];
        _recordedLocations = [NSMutableArray array];
        _accumulatedDistance = _distance;
    }
    else //RESUME
    {
        [self startTimer];
        _distance = _accumulatedDistance;
        [_startAndPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    
    
}

-(void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                              target:self
                                            selector:@selector(eachSecond)
                                            userInfo:nil
                                             repeats:YES];
}

- (IBAction)stopButtonPressed:(id)sender {
    [_startAndPauseButton setTitle:@"Start" forState:UIControlStateNormal];
    [_timer invalidate];
    NSDate* now = [NSDate date];
    Run *run = [[Run alloc]initRun:_accumulatedSeconds distance:_accumulatedDistance date:now];
    //will update conditionally based on dialog in future -- alert field
    _accumulatedSeconds = 0;
    _accumulatedDistance = 0;
}

- (void)eachSecond {
    _seconds++;
    
    _durationLabel.text = [NSString stringWithFormat:@"Time: %@", [self formatRunTime:_seconds]];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance (miles): %@", [self formatRunDistance:_distance]];
}

-(NSString *)formatRunTime:(int)runTime {
    int seconds2 = runTime % 60;
    int minutes2 = (runTime / 60) % 60;
    int hours2 = (runTime / 3600);
    NSString *formattedTime = [NSString stringWithFormat:@"%02i:%02i:%02i", hours2, minutes2, seconds2];
    return formattedTime;
}

-(NSString *)formatRunDistance:(float)runDistance {
    float miles = runDistance/1609.344;
    NSString *formattedDistance = [NSString stringWithFormat:@"%.2f", miles];
    return formattedDistance;
}

-(void)mapSetup {
    [_mapView setDelegate:self];
    [_mapView setShowsUserLocation:true];
    [self getUserLocation];
}

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
                _distance += [newLocation distanceFromLocation:self.recordedLocations.lastObject];
            }
            
            [self.recordedLocations addObject:newLocation];

            //Creates a region based on the user's new location.
            userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500.0, 500.0);
            
            //map's region is set using the region we made from the user's location. Each time the user's location changes this method is called and the new map region is set.
            [_mapView setRegion:userLocation animated:YES];
            
            
        }
    }
}


@end
