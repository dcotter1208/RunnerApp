//
//  Run.h
//  RunnerApp
//
//  Created by Jeremy Lilje on 6/14/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Run : NSObject

@property (nonatomic) NSString *runner;
@property (nonatomic) int duration;
@property (nonatomic) float distance;
@property (nonatomic) NSString *date;
@property (nonatomic, strong) NSString *pace;
@property (nonatomic) NSString *temperature;
@property (nonatomic) NSString *humidity;
@property (nonatomic) NSString *precipitation;

-(instancetype)initWithRunner:(NSString *)runner duration:(int)duration distance:(float)distance date:(NSString *)date pace:(NSString *)pace temperature:(NSString *)temperature humidity:(NSString *)humidity precipitation:(NSString *)precipitation;

@end