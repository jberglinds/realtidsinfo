//
//  RealtimeSite.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-02-27.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "RealtimeSite.h"
#import "TrafiklabAPI.h"
#import "Departure.h"

@interface RealtimeSite()
@property (strong, nonatomic, readwrite) NSDate *updatedAt;
@property (strong, nonatomic, readwrite) NSArray *departures; // of Departure

@property (strong, nonatomic) TrafiklabAPI *API;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSTimer *updateTimer;
@end

float const UPDATE_FREQ = 15.0;

@implementation RealtimeSite

# pragma mark - Initialization
- (instancetype)initWithSiteID:(NSInteger)ID {
    self = [super init];
    
    if (self) {
        self.siteID = ID;
        [self updateRealTime];
    }
    
    return self;
}

- (NSArray *)departures {
    if (!_departures) _departures = [[NSArray alloc] init];
    return _departures;
}

- (TrafiklabAPI *)API {
    if (!_API) _API = [[TrafiklabAPI alloc] init];
    return _API;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    return _dateFormatter;
}

# pragma mark - Updates
- (void)startUpdates {
    if (!self.updateTimer) {
        // Start a timer if none exists
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_FREQ target:self selector:@selector(updateRealTime) userInfo:nil repeats:YES];
    }
}

- (void)stopUpdates {
    [self.updateTimer invalidate];
    self.updateTimer = nil;
}

- (void)updateRealTime {
    [self.API getRealtimeForStop:self.siteID completion:^(NSDictionary *response) {
        NSDictionary *responseData = response[@"ResponseData"];
        
        NSDate *latestUpdate = [self.dateFormatter dateFromString:responseData[@"LatestUpdate"]];
        
        // Only update if response has newer update, API is not very good at giving latest at all times.
        if (!self.updatedAt || [latestUpdate timeIntervalSinceDate:self.updatedAt] > 0) {
            self.updatedAt = latestUpdate;
            
            // Loop over response and add to Departures array, only buses for now.
            NSMutableArray *departures = [[NSMutableArray alloc] init];
            for (NSDictionary *bus in responseData[@"Buses"]) {
                Departure *departure = [[Departure alloc] init];
                departure.stopArea = bus[@"StopAreaName"];
                departure.line = bus[@"LineNumber"];
                departure.journeyDirection = [bus[@"JourneyDirection"] integerValue];
                departure.destination = bus[@"Destination"];
                departure.expectedAt = [self.dateFormatter dateFromString:bus[@"ExpectedDateTime"]];
                departure.timeTabledAt = [self.dateFormatter dateFromString:bus[@"TimeTabledDateTime"]];
                [departures addObject:departure];
            }
            // Copy over an immutable copy to public var
            self.departures = [departures copy];
        }
    }];
}

@end
