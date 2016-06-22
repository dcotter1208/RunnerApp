//
//  Weather.h
//  RunnerApp
//
//  Created by Jeremy Lilje on 6/20/16.
//  Copyright © 2016 DetroitLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property (nonatomic) NSString *temperature;
@property (nonatomic) NSString *precipitation;
@property (nonatomic) NSString *humidity;

//-(id)initWithNSDictionary:(NSDictionary *)weatherInfo_;

@end
