//
//  Weather.m
//  RunnerApp
//
//  Created by Jeremy Lilje on 6/20/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Weather.h"

@implementation Weather

-(id)initWithWeatherTemp:(NSString *)temperature precipitation:(NSString *)precipitation humidity:(NSString *)humidity {
    self = [super init];
    
    if (self) {
        _temperature = temperature;
        _precipitation = precipitation;
        _humidity = humidity;
    }
    return self;
}

@end
