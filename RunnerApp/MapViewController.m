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
@property (nonatomic, strong) Weather *weather;

@end

NSMutableArray *currentPaceArray;
CLLocation *newLocation;
MKCoordinateRegion userLocation;
BOOL isTimerRunning;

@implementation MapViewController

- (void) getWeatherInfo {
    double lon = newLocation.coordinate.longitude;
    double lat = newLocation.coordinate.latitude;

    NSString *weatherUrlString = [NSString stringWithFormat:@"http://api.wunderground.com/api/ed2eda62a0bc8673/conditions/q/%0.8f,%0.8f.json", lat, lon];
    NSURL *weatherUrl = [NSURL URLWithString:weatherUrlString];

    NSURLSessionConfiguration *weatherConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *weatherSession = [NSURLSession sessionWithConfiguration:weatherConfig];
    NSURLSessionDataTask *weatherDataTask = [weatherSession dataTaskWithURL:weatherUrl completionHandler:
    ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            //Cast the NSURLResponse to a NSHTTPURLResponse so we can get access to the 'status code'
            NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*) response;
            //If that status code is 200 - meaning the response was good
            if (urlResponse.statusCode == 200) {
                //Make a NSError to hold a domain error if one ends up existing.
                NSError *jsonError;
                //turn the returned JSON into a NSDictionary and pass in the jsonError error that we created (&jsonError).
                NSDictionary *weatherJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                //If there is no jsonError
                if (!jsonError) {
                    
                    // disptch_async updates my labels with the weather info when it is returned from the API / data provider.
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _weather = [[Weather alloc]initWithWeatherTemp:[weatherJSON valueForKeyPath:@"current_observation.temp_f"] precipitation:[weatherJSON valueForKeyPath:@"current_observation.relative_humidity"] humidity:[weatherJSON valueForKeyPath:@"current_observation.precip_1hr_in"]];
//                        _weather.temperature = [weatherJSON valueForKeyPath:@"current_observation.temp_f"];
//                        _weather.humidity = [weatherJSON valueForKeyPath:@"current_observation.relative_humidity"];
//                        _weather.precipitation = [weatherJSON valueForKeyPath:@"current_observation.precip_1hr_in"];
                    });
                }
            } else {
                NSLog(@"RESPONSE ERROR: %@", urlResponse.description);
            }
        } else {
            NSLog(@"ERROR: %@", error.description);
        }
    }];

    //This starts the network call.
    [weatherDataTask resume];
}

- (void)viewDidLoad {
    _weather = [[Weather alloc]initWithWeatherTemp:@"Unavailable" precipitation:@"Unavailable" humidity:@"Unavailable"];
    [self.navigationController setNavigationBarHidden:true];
    [super viewDidLoad];
    [self getWeatherInfo];
    _accumulatedDistance = 0;
    currentPaceArray = [[NSMutableArray alloc]init];
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
    
    Run *run = [[Run alloc]initWithRunner:[FIRAuth auth].currentUser.uid
                                 duration:_seconds
                                 distance:_accumulatedDistance
                                 date:timeStamp
                                 pace: [self getOverallPace]
                                 temperature:_weather.temperature
                                 humidity:_weather.humidity
                                 precipitation:_weather.precipitation];
    
    [self saveRunToFirebase:run];
    _accumulatedDistance = 0;
}

-(void)discardRun {
    [_startAndPauseButton setTitle:@"Start" forState:UIControlStateNormal];
    [_timer invalidate];
    
    _seconds = 0;
    _accumulatedDistance = 0;
    _durationLabel.text = [NSString stringWithFormat:@"Time:"];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance (miles):"];
    _currentPaceLabel.text = [NSString stringWithFormat:@"Current Pace:"];
    _overallPaceLabel.text = [NSString stringWithFormat:@"Overall Pace:"];
}

#pragma mark Timer Methods

-(void)startTimer {
    
    if (isTimerRunning == TRUE) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                                  target:self
                                                selector:@selector(eachSecond)
                                                userInfo:nil
                                                 repeats:YES];
    }

}

- (void)eachSecond {
    _seconds++;
    _durationLabel.text = [NSString stringWithFormat:@"Time: %@", [self formatRunTime:_seconds]];
    _distanceLabel.text = [NSString stringWithFormat:@"Distance (miles): %@", [self formatRunDistance:_accumulatedDistance]];
    _currentPaceLabel.text = [NSString stringWithFormat:@"Current Pace: %@", [self getCurrentPace]];
    _overallPaceLabel.text = [NSString stringWithFormat:@"Overall Pace: %@", [self getOverallPace]];
}

#pragma mark Save To Firebase

-(void)saveRunToFirebase:(Run *)run {
    float miles = run.distance/1609.344;
    FIRDatabaseReference *fbDataService = [[FIRDatabase database] reference];
    FIRDatabaseReference *runsRef = [fbDataService child:@"runs"].childByAutoId;

    NSDictionary *runToAdd = @{
                                   @"runner" : run.runner,
                                   @"duration": [NSNumber numberWithInt:run.duration],
                                   @"distance": [NSNumber numberWithFloat:miles],
                                   @"overallPace": run.pace,
                                   @"date": run.date,
                                   @"temperature": run.temperature,
                                   @"humidity": run.humidity,
                                   @"precipitation": run.precipitation,
                                   };
        [runsRef setValue:runToAdd];
}

#pragma mark Helper Methods

-(void)alertMessage:(NSString*)message {
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:nil
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
    
    _currentPaceLabel.font = [UIFont systemFontOfSize:20];
    _overallPaceLabel.font = [UIFont systemFontOfSize:20];
    
    _startAndPauseButton.backgroundColor = [UIColor colorWithRed:39.0f/255.0f green:196.0f/255.0f blue:36.0f/255.0f alpha:1.0];
    _stopButton.backgroundColor = [UIColor redColor];
}

-(NSString *) getCurrentPace {
    NSString *currentPace;
    if (_seconds <= 21) {
        currentPace = @"calculating...";
        [currentPaceArray addObject:[NSNumber numberWithInt:_distance]];
//        NSLog(@"_distance = %@", [NSNumber numberWithInt:_distance]);
    } else {
        [currentPaceArray removeObjectAtIndex:0];
        [currentPaceArray addObject:[NSNumber numberWithInt:_distance]];
        float miles = (([currentPaceArray[1] intValue] + [currentPaceArray[20] intValue])/3218.688)*3600;
        currentPace = [NSString stringWithFormat:@"%.2f mph", miles];
    }
    return currentPace;
}

-(NSString *) getOverallPace {
    float miles = _accumulatedDistance/1609.344;
    NSString *overallPace = [NSString stringWithFormat:@"%.2f mph", (miles/_seconds)*3600];
    return overallPace;
}

//Puts the semi-translucent view in that the start/stop/distance/duration views sit on.
-(void)initDesignElements {
    CGRect screenRect = {{0, [[UIScreen mainScreen] bounds].size.height-230}, {CGRectGetWidth(self.view.bounds), 230}};
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
        MKCoordinateRegion initialLocation = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 500.0, 500.0);
        [_mapView setRegion:initialLocation animated:YES];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    for (CLLocation *newLocation in locations) {
        if (newLocation.horizontalAccuracy < 20) {
            // update distance
            if (self.recordedLocations.count > 0) {
                _distance = [newLocation distanceFromLocation:self.recordedLocations.lastObject];
                _accumulatedDistance += _distance;
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
        isTimerRunning = TRUE;
        _seconds = 0;
        _distance = 0;
        _accumulatedDistance = 0;
        _recordedLocations = [NSMutableArray array];
        [self startTimer];
        [_startAndPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    //PAUSE
    else if ([_startAndPauseButton.titleLabel.text isEqualToString:@"Pause"]) {
        isTimerRunning = FALSE;
        [_timer invalidate];
        [_startAndPauseButton setTitle:@"Resume" forState:UIControlStateNormal];
        _recordedLocations = [NSMutableArray array];
    }
    //RESUME
    else {
        if (isTimerRunning == FALSE) {
            isTimerRunning = TRUE;
            [self startTimer];
            _distance = _accumulatedDistance;
            [_startAndPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        } else {
            
        }
    }
    
}

@end
