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
#import "Weather.h"

//==========================================================================================================
//Weather add ==============================================================================================
//==========================================================================================================
@import WebKit;
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
@property (nonatomic, strong) Weather *weather;

@end

CLLocation *newLocation;
MKCoordinateRegion userLocation;
@implementation MapViewController

//==========================================================================================================
//Weather add ==============================================================================================
//==========================================================================================================
//CFHTTPMessageRef http
//UIWebView *webView;
WKWebView *webView;

NSHTTPURLResponse *weatherQuerryResponse;

- (void) getWeatherInfo
{
    double lon = newLocation.coordinate.longitude;
    double lat = newLocation.coordinate.latitude;

    NSString *weatherUrlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/ed2eda62a0bc8673/conditions/q/%0.8f,%0.8f.json", lat, lon];
    NSURL *weatherUrl = [NSURL URLWithString:weatherUrlString];

    NSURLSessionConfiguration *weatherConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *weatherSession = [NSURLSession sessionWithConfiguration:weatherConfig];
    NSURLSessionDataTask *weatherDataTask = [weatherSession dataTaskWithURL:weatherUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (!error)
        {
            //Cast the NSURLResponse to a NSHTTPURLResponse so we can get access to the 'status code'
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*) response;
            //If that status code is 200 - meaning the response was good
            if (urlResponse.statusCode == 200)
            {
                //Make a NSError to hold a domain error if one ends up existing.
                NSError *jsonError;
                //turn the returned JSON into a NSDictionary and pass in the jsonError error that we created (&jsonError).
                NSDictionary *weatherJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                //If there is no jsonError
                if (!jsonError)
                {
                    //Print the NSDictionary we just made that should have the data.
                    //NSLog(@"%@", weatherJSON);
                    
                    //I have a weather class that I'm going to make with the returned JSON.
                    _weather = [[Weather alloc] init];
                    
                    _weather.temperature = [weatherJSON valueForKeyPath:@"current_observation.temp_f"];
                    _weather.humidity = [weatherJSON valueForKeyPath:@"current_observation.relative_humidity"];
                    _weather.precipitation = [weatherJSON valueForKeyPath:@"current_observation.precip_1hr_in"];
                    
                    //Print out info for confirmation of call
//                    NSLog(@"=========================================================================");
//                    NSLog(@"coordinates are %@ longitude and %@ latitude", [weatherJSON valueForKeyPath:@"current_observation.display_location.longitude"], [weatherJSON valueForKeyPath:@"current_observation.display_location.latitude"]);
//                    NSLog(@"location is %@", [weatherJSON valueForKeyPath:@"current_observation.display_location.full"]);
//                    NSLog(@"temperature is %@", weather.temperature);
//                    NSLog(@"humidity is %@", weather.humidity);
//                    NSLog(@"precipitation is %@", weather.precipitation);

                    
                    // disptch_async updates my labels with the weather info when it is returned from the API / data provider.
                    dispatch_async(dispatch_get_main_queue(), ^{
                    self.temperatureLabel.text = [NSString stringWithFormat:@"  %@", _weather.temperature];
                    self.humidityLabel.text = [NSString stringWithFormat:@"  %@", _weather.humidity];
                    self.precipitationLabel.text = [NSString stringWithFormat:@"  %@", _weather.precipitation];
                    });
                }
            }
        }
    }];

    //This starts the network call.
    [weatherDataTask resume];
}

- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:true];
    [super viewDidLoad];
    _accumulatedDistance = 0;
    
    [self mapSetup];
    [self getWeatherInfo];
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
    
    Run *run = [[Run alloc]initRun:_seconds distance:_accumulatedDistance date:timeStamp temperature:_weather.temperature humidity:_weather.humidity precipitation:_weather.precipitation];
    
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
    
    NSDictionary *runToAdd = @{
                               @"duration": [NSNumber numberWithInt:run.duration],
                               @"distance": [NSNumber numberWithFloat:miles],
                               @"date": run.date,
                               @"temperature": run.temperature,
                               @"humidity": run.humidity,
                               @"precipitation": run.precipitation,
                               };

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
