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

//weather key for Weather Underground (Wunderground): ed2eda62a0bc8673

@interface MapViewController ()
//Outlets
@property (weak, nonatomic) IBOutlet UIButton *startAndPauseButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//Properties
@property (nonatomic, strong) NSMutableArray *recordedLocations;
@property (nonatomic) float distance;
@property (nonatomic) float accumulatedDistance;
@property (nonatomic) int seconds;

@end

NSString *weatherQuerry = @"http://api.wunderground.com/api/ed2eda62a0bc8673/conditions/q/48138.json";
//CFHTTPMessageRef http
UIWebView *webView;
NSHTTPURLResponse *weatherQuerryResponse;

CLLocation *newLocation;
MKCoordinateRegion userLocation;
@implementation MapViewController





//- (void)viewDidAppear:(BOOL)animated {
//    NSURL *u = [NSURL URLWithString:@"http://www.google.de"];
//    NSURLRequest *r = [NSURLRequest requestWithURL:u];
//    [self.webView loadRequest:r];
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
//    NSLog(@"%@",[(NSHTTPURLResponse*)resp.response allHeaderFields]);
//}







- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:true];
    [super viewDidLoad];
    _accumulatedDistance = 0;
    //NSLog(@"weather querry returns: %@", weatherQuerryResponse);
    
    
    NSURL *u = [NSURL URLWithString:@"http://api.wunderground.com/api/ed2eda62a0bc8673/conditions/q/48138.json"];
    NSURLRequest *r = [NSURLRequest requestWithURL:u];
    [webView loadRequest:r];
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSLog(@"==========================================================================================================================");
    NSLog(@"URL is: %@", u);
    NSLog(@"URL Request is: %@",r);
    NSLog(@"URL Response is: %@",resp);
//    NSLog(@"URL Response is: %@",[(NSHTTPURLResponse*)resp.response allHeaderFields]);
    NSLog(@"URL Response is: %@",[(NSHTTPURLResponse*)resp.response allHeaderFields]);

    [self mapSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

-(void)startTimer {
    _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                              target:self
                                            selector:@selector(eachSecond)
                                            userInfo:nil
                                             repeats:YES];
}

- (IBAction)stopButtonPressed:(id)sender {
    //
    [_startAndPauseButton setTitle:@"Start" forState:UIControlStateNormal];
    [_timer invalidate];
    
    //Grab the current date and turn it into a string.
    NSDate* now = [NSDate date];
    NSString *timeStamp = [self formattedDate:now];
    
    Run *run = [[Run alloc]initRun:_seconds distance:_accumulatedDistance date:timeStamp];
    
    [self saveRunToFirebase:run];
    
    //will update conditionally based on dialog in future -- alert field
    _accumulatedDistance = 0;
}

- (void)eachSecond {
    _seconds++;
    _accumulatedDistance += _distance;
    NSLog(@"Accumulated Distance: %@", [self formatRunDistance:_accumulatedDistance]);
    _durationLabel.text = [NSString stringWithFormat:@"Time: %@", [self formatRunTime:_seconds]];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance (miles): %@", [self formatRunDistance:_accumulatedDistance]];
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

-(NSString *)formattedDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/YYYY"];
    NSString *formattedRunDate = [dateFormatter stringFromDate:date];
    
    return formattedRunDate;
}

-(void)saveRunToFirebase:(Run *)run {
    float miles = run.distance/1609.344;
    
    FIRDatabaseReference *fbDataService = [[FIRDatabase database] reference];
    
    FIRDatabaseReference *runsRef = [fbDataService child:@"runs"].childByAutoId;
    
    NSDictionary *runToAdd = @{@"duration": [NSNumber numberWithInt:run.duration],
                               @"distance": [NSNumber numberWithFloat:miles],
                               @"date": run.date};

    [runsRef setValue:runToAdd];
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




@end
