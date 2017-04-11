//
//  StopInfo.h
//  Realtidsinfo
//  All possible info about a stop that we might care about
//
//  Created by Jonathan Berglind on 2017-04-08.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StopInfo : NSObject

@property (nonatomic)           NSInteger   stopID;
@property (strong, nonatomic)   NSString    *stopName;
@property (strong, nonatomic)   NSString    *areaName;
@property (nonatomic)           NSInteger   journeyDirection;
@property (nonatomic)           float       latitude;
@property (nonatomic)           float       longitude;
@property (nonatomic)           NSInteger   distance; // from some location

@end
