//
//  Run.m
//  RunnerApp
//
//  Created by Jeremy Lilje on 6/14/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import "Run.h"

@implementation Run

-(instancetype)initRun:(float)duration distance:(float)distance date:(NSDate *)date
{
    self = [super init];
    
    if (self)
    {
        _duration = duration;
        _distance = distance;
        _date = date;
    }
    return self;
}

@end