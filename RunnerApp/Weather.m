//
//  Weather.m
//  RunnerApp
//
//  Created by Jeremy Lilje on 6/20/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Weather.h"

@implementation Weather

@synthesize temperature;
@synthesize humidity;
@synthesize precipitation;

//-(id)initWithNSDictionary:(NSDictionary *)weatherInfo_
//{
//    self = [super init];
//    if (self) {
//        
//        NSDictionary *weatherInfo = weatherInfo_;
//        //NSLog(@"Weather Info = %@", weatherInfo);
//        self.temperature = [weatherInfo  valueForKey:@"temp_f"];
//        self.humidity = [weatherInfo  valueForKey:@"relative_humidity"];
//        self.precipitation = [weatherInfo  valueForKey:@"precip_1hr_in"];
//        
//    }
//    return self;
//}

- (void)dealloc
{
    self.temperature = nil;
    self.humidity = nil;
    self.precipitation = nil;
}

@end
