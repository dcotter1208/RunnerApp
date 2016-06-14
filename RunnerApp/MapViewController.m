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
@property (nonatomic) float seconds;


@end

CLLocation *newLocation;
MKCoordinateRegion userLocation;
@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self mapSetup];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAndPauseButtonPressed:(id)sender {

    _seconds = 0;
    _distance = 0;
    _recordedLocations = [NSMutableArray array];
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                                  target:self
                                                selector:@selector(eachSecond)
                                                userInfo:nil
                                                 repeats:YES];
    
    
}

- (IBAction)stopButtonPressed:(id)sender {
    [_timer invalidate];
    NSDate* now = [NSDate date];
    Run *run = [[Run alloc]initRun:_seconds distance:_distance date:now];
    NSLog(@"Seconds: %f, Distance: %f, Date: %@", run.duration, run.distance, run.date);
}

- (void)eachSecond {
    _seconds++;
    _durationLabel.text = [NSString stringWithFormat:@"Time: %f", _seconds];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance: %f", _distance];
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

-(void)startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                selector:@selector(addSecond) userInfo:nil repeats:YES];
}

-(void)addSecond {
    _seconds++;
}

//- (void)startLocationUpdates
//{
//    // Create the location manager if this object does not
//    // already have one.
//    if (self.locationManager == nil) {
//        self.locationManager = [[CLLocationManager alloc] init];
//    }
//    
//    self.locationManager.delegate = self;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    self.locationManager.activityType = CLActivityTypeFitness;
//    
//    // Movement threshold for new events.
//    self.locationManager.distanceFilter = 10; // meters
//    
//    [self.locationManager startUpdatingLocation];
//}

@end
