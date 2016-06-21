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












































- (void) getWeatherInfo{//:(id)sender
    {
        //Weather API Key = ed2eda62a0bc8673, inserted into URL below
        NSString *weatherUrlString = @"http://api.wunderground.com/api/ed2eda62a0bc8673/conditions/q/48138.json";
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
                        NSLog(@"%@", weatherJSON);
                        
                        //I have a vehicle class that I'm going to make with the returned JSON.
//                        Vehicle *while = [Vehicle initWithMake:[vehicleJSON valueForKeyPath:@"make.name"]];
//                        vehicle.model = [vehicleJSON valueForKeyPath:@"model.name"];
//                        vehicle.baseMSRP = [[vehicleJSON valueForKeyPath:@"price.baseMSRP"]stringValue];
//                        NSArray *yearsDict = [vehicleJSON valueForKeyPath:@"years"];
//                        vehicle.year = [yearsDict[0][@"year"]stringValue];
//                        vehicle.VIN = [VINNumber uppercaseString];
//                        
                        //disptch_async updates my labels with the vehicle info when it is returned from the API provider.
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            
//                            self.makeLabel.text = [NSString stringWithFormat:@"  %@", vehicle.make];
//                            self.modelLabel.text = [NSString stringWithFormat:@"  %@", vehicle.model];
//                            self.yearLabel.text = [NSString stringWithFormat:@"  %@", vehicle.year];
//                            self.baseMSRPLabel.text = [NSString stringWithFormat:@"  $%@", vehicle.baseMSRP];
//                            
//                        });
                    }
                }
            }
        }];
    //This starts the network call.
    [weatherDataTask resume];
}

        
        
//        //create a mutable HTTP request
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
//        //sets the receiver’s timeout interval, in seconds
//        [urlRequest setTimeoutInterval:30.0f];
//        //sets the receiver’s HTTP request method
//   //     [urlRequest setHTTPMethod:@"POST"];
//        //sets the request body of the receiver to the specified data.
//  //      [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        //allocate a new operation queue
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        //Loads the data for a URL request and executes a handler block on an
//        //operation queue when the request completes or fails.
//        [NSURLConnection
//         sendAsynchronousRequest:urlRequest
//         queue:queue
//         completionHandler:^(NSURLResponse *response,
//                             NSData *data,
//                             NSError *error) {
//             if ([data length] >0 && error == nil){
//                 //process the JSON response
//                 //use the main queue so that we can interact with the screen
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     [self parseResponse:data];
//                 });
//             }
//             else if ([data length] == 0 && error == nil){
//                 NSLog(@"Empty Response, not sure why?");
//             }
//             else if (error != nil){
//                 NSLog(@"Not again, what is the error = %@", error);
//             }
//         }];
//    NSLog(@"==========================================================================================================================");
//
//    NSLog(@"urlRequest is %@", urlRequest);
//    NSLog(@"==========================================================================================================================");
//    
//   // NSLog(@"urlResponse is %@", NSURLResponseUnknownLength);
//     NSLog(@"");
//     NSLog(@"");
//     NSLog(@"");
//}
//
//- (void) parseResponse:(NSData *) data {
//    
//    NSString *myData = [[NSString alloc] initWithData:data
//                                             encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"==========================================================================================================================");
//    NSLog(@"JSON data = %@", myData);
//    NSError *error = nil;
//    
//    //parsing the JSON response
//    id jsonObject = [NSJSONSerialization
//                     JSONObjectWithData:data
//                     options:NSJSONReadingAllowFragments
//                     error:&error];
//    if (jsonObject != nil && error == nil){
//        NSLog(@"Successfully deserialized...");
//        
//        //check if the country code was valid
//        NSNumber *success = [jsonObject objectForKey:@"success"];
//        if([success boolValue] == YES){
////            
////            //if the second view controller doesn't exists create it
////            if(self.mapViewController == nil){
////                DisplayViewController *displayView = [[DisplayViewController alloc] init];
////                self.displayViewController = displayView;
////            }
////            
////            //set the country object of the second view controller
////            [self.mapViewController setJsonObject:[jsonObject objectForKey:@"countryInfo"]];
////            
////            //tell the navigation controller to push a new view into the stack
////            [self.navigationController pushViewController:self.displayViewController animated:YES];
////        }
////        else {
////            self.myLabel.text = @"Country Code is Invalid...";
//        }
//        
//    }
//    
//}
//
//








//NSString *edmundsAPIKey = @"5xgdf7jpeu9wkgnq6f5rave4";
//NSString *VINNumber = [self.VINTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//
////URL STRING
//NSString *urlString = [NSString stringWithFormat:@"https://api.edmunds.com/api/vehicle/v2/vins/%@?fmt=json&api_key=%@", VINNumber, edmundsAPIKey];
//
////Create URL
//NSURL *url = [NSURL URLWithString:urlString];
//
////Set the config
//NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
////Create the session
//NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
////Perform the Session with dataTask
//NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    //If there is no error...
//    if (!error) {
//        //Cast the NSURLResponse to a NSHTTPURLResponse so we can get access to the 'status code'
//        NSHTTPURLResponse *urlResponse = (NSHTTPURLResponse*) response;
//        
//        //If that status code is 200 - meaning the response was good
//        if (urlResponse.statusCode == 200) {
//            
//            //Make a NSError to hold a domain error if one ends up existing.
//            NSError *jsonError;
//            
//            //turn the returned JSON into a NSDictionary and pass in the jsonError error that we created (&jsonError).
//            NSDictionary *vehicleJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
//            
//            //If there is no jsonError
//            if (!jsonError) {
//                //Print the NSDictionary we just made that should have the data.
//                NSLog(@"%@", vehicleJSON);
//                
//                //I have a vehicle class that I'm going to make with the returned JSON.
//                Vehicle *vehicle = [Vehicle initWithMake:[vehicleJSON valueForKeyPath:@"make.name"]];
//                vehicle.model = [vehicleJSON valueForKeyPath:@"model.name"];
//                vehicle.baseMSRP = [[vehicleJSON valueForKeyPath:@"price.baseMSRP"]stringValue];
//                NSArray *yearsDict = [vehicleJSON valueForKeyPath:@"years"];
//                vehicle.year = [yearsDict[0][@"year"]stringValue];
//                vehicle.VIN = [VINNumber uppercaseString];
//                
//                //disptch_async updates my labels with the vehicle info when it is returned from the API provider.
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    
//                    self.makeLabel.text = [NSString stringWithFormat:@"  %@", vehicle.make];
//                    self.modelLabel.text = [NSString stringWithFormat:@"  %@", vehicle.model];
//                    self.yearLabel.text = [NSString stringWithFormat:@"  %@", vehicle.year];
//                    self.baseMSRPLabel.text = [NSString stringWithFormat:@"  $%@", vehicle.baseMSRP];
//                    
//                });
//            }
//        }
//    }
//}];
////This starts the network call.
//[dataTask resume];
//}

























































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

//- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url
//                        completionHandler:(void (^)(NSData *data,
//                                                    NSURLResponse *response,
//                                                    NSError *error))completionHandler
//
//};


- (void)viewDidLoad {
    [self.navigationController setNavigationBarHidden:true];
    [super viewDidLoad];
    _accumulatedDistance = 0;
    //NSLog(@"weather querry returns: %@", weatherQuerryResponse);
    
    
//    NSURL *u = [NSURL URLWithString:@"http://api.wunderground.com/api/ed2eda62a0bc8673/conditions/q/48138.json"];
//    NSURLRequest *r = [NSURLRequest requestWithURL:u];
//    [webView loadRequest:r];
//    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.r ];
//    NSLog(@"==========================================================================================================================");
//    NSLog(@"URL is: %@", u);
//    NSLog(@"URL Request is: %@",r);
//    NSLog(@"URL Response is: %@",resp);
    
    // NSString *body =  [NSString stringWithFormat:@"countryCode=%@", countryCode.text];
//    
//    NSURL *myUrl = [NSURL URLWithString:@"http://api.wunderground.com/api/ed2eda62a0bc8673/conditions/q/48138.json"];
//    //NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//    //[urlSessionConfig setURL
//    //NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfig];
//    
//    NSURLSession *urlSession;
//    urlSession = [NSURLSession sharedSession];
//    [urlSession dataTaskWithURL:myUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
//    {
//    }];
//    [urlSession]
//     //create a mutable HTTP request
  //  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:myUrl];
    //sets the receiver’s timeout interval, in seconds
    //[urlRequest setTimeoutInterval:30.0f];
    //sets the receiver’s HTTP request method
    //[urlRequest setHTTPMethod:@"POST"];
    //sets the request body of the receiver to the specified data.
    //[urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //allocate a new operation queue
  //  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //Loads the data for a URL request and executes a handler block on an
//    //operation queue when the request completes or fails.
//    [NSURLSession sharedS//ession];
//    [NSURLConnection
//     sendAsynchronousRequest:urlRequest
//     queue:queue
//     completionHandler:^(NSURLResponse *response,
//                         NSData *data,
//                         NSError *error) {
//         if ([data length] >0 && error == nil){
//             //process the JSON response
//             //use the main queue so that we can interact with the screen
//             dispatch_async(dispatch_get_main_queue(), ^{
//       //          [self parseResponse:data];
//             });
//         }
//         else if ([data length] == 0 && error == nil){
//             NSLog(@"Empty Response, not sure why?");
//         }
//         else if (error != nil){
//             NSLog(@"Not again, what is the error = %@", error);
//         }
//     }];

//        NSLog(@"==========================================================================================================================");
//        NSLog(@"URL is: %@", myUrl);
//        NSLog(@"urlSession is: %@", urlSession);
//        //NSLog(@"URL Request is: %@", urlRequest);
//        NSLog(@"URL Response is: %@", urlSession.);


//    NSLog(@"URL Response is: %@",[(NSHTTPURLResponse*)resp.response allHeaderFields]);
//    NSLog(@"URL Response is: %@",[(NSHTTPURLResponse*)resp.response allHeaderFields]);

    [self getWeatherInfo];
    
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
