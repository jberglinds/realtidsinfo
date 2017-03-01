//
//  RealtimeSite.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-02-27.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "RealtimeSite.h"
#import "AFNetworking.h"

@interface RealtimeSite()
@property (nonatomic) NSInteger siteID;

@property (strong, nonatomic, readwrite) NSString *locationName;
@property (strong, nonatomic, readwrite) NSString *busName;
@property (strong, nonatomic, readwrite) NSString *busDestination;
@property (strong, nonatomic, readwrite) NSDate *expectedAt;
@property (strong, nonatomic, readwrite) NSDate *updatedAt;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSTimer *updateTimer;
@end

NSString const *REALTIME_API_KEY;
NSString const *API_ENDPOINT = @"http://api.sl.se/api2/realtimedeparturesV4.json";
CGFloat const UPDATE_FREQ = 15.0;

@implementation RealtimeSite

# pragma mark - Initialization
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    return _dateFormatter;
}

- (void)setAPIKey {
    NSDictionary *keys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"API-keys" ofType:@"plist"]];
    REALTIME_API_KEY = keys[@"realtimedeparturesV4"];
}

- (instancetype)initWithSiteID:(NSInteger)ID {
    self = [super init];
    
    if (self) {
        self.siteID = ID;
        [self setAPIKey];
        [self updateRealTime];
    }
    
    return self;
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
    NSString *urlString = [API_ENDPOINT stringByAppendingString:[NSString stringWithFormat:@"?key=%@&siteid=%ld&timewindow=60",
                                                                 REALTIME_API_KEY, (long)self.siteID]];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseData = responseObject[@"ResponseData"];
        
        NSDate *latestUpdate = [self.dateFormatter dateFromString:responseData[@"LatestUpdate"]];
        
        // Only update if response has newer update, API is not very good at giving latest at all times.
        if (!self.updatedAt || [latestUpdate timeIntervalSinceDate:self.updatedAt] > 0) {
            self.updatedAt = latestUpdate;
            for (NSDictionary *bus in responseData[@"Buses"]) {
                if ([bus[@"JourneyDirection"] isEqual: @2]) {
                    self.locationName = bus[@"StopAreaName"];
                    self.busName = bus[@"LineNumber"];
                    self.busDestination = bus[@"Destination"];
                    self.expectedAt = [self.dateFormatter dateFromString:bus[@"ExpectedDateTime"]];
                    return;
                }
            }
            // None found
            self.busName = @"Inga avgångar";
            self.expectedAt = nil;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //TODO: Deal with error in a better way
        NSLog(@"RealtimeSite updateRealTime(): %@", error);
    }];
}

@end
