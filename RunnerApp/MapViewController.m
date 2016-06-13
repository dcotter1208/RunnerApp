//
//  MapViewController.m
//  RunnerApp
//
//  Created by DetroitLabs on 6/13/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startAndPauseButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

CLLocation *newLocation, *oldLocation;
MKCoordinateRegion userLocation;

@implementation MapViewController 


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self mapSetup];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startAndPauseButtonPressed:(id)sender {
    
    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                selector:@selector(eachSecond) userInfo:nil repeats:YES];
//    [self startLocationUpdates];
    
}


- (IBAction)stopButtonPressed:(id)sender {
    
    
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
    
    newLocation = [locations lastObject];
    
    if (locations.count > 1) {
        NSUInteger newLocationIndex = [locations indexOfObject:newLocation];
        oldLocation = [locations objectAtIndex:newLocationIndex];
    } else {
        oldLocation = nil;
    }
    
    userLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 300.0, 300.0);
    [_mapView setRegion:userLocation animated:YES];
    
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
