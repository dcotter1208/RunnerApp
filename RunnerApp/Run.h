//
//  Run.h
//  RunnerApp
//
//  Created by Jeremy Lilje on 6/14/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

/*
 MVP Class:
 - duration
 - distance
 - date
 
 Later:
 - RunnerID
 
 Stretch:
 - startTime
 - endTime
 - startLocation
 - endLocation
 - weather
 -
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Run : NSObject

@property (nonatomic) float *duration;
@property (nonatomic) float *distance;
@property (nonatomic) NSDate *date;

-(instancetype)initRun:(float *)duration distance:(float *)distance date:(NSDate *)date;

@end