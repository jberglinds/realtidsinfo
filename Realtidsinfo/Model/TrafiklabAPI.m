//
//  TrafiklabAPI.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-29.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "TrafiklabAPI.h"
#import "AFNetworking.h"

@interface TrafiklabAPI ()
@property (strong, nonatomic) AFHTTPSessionManager *manager;

@property (strong, nonatomic) NSString *LOOKUP_API_KEY;
@property (strong, nonatomic) NSString *REALTIME_API_KEY;
@property (strong, nonatomic) NSString *NEARBY_API_KEY;
@end

@implementation TrafiklabAPI

#pragma mark - Initialization
- (instancetype)init {
    self = [super init];

    if (self) {
        [self setAPIKeys];
        self.manager = [AFHTTPSessionManager manager];
    }

    return self;
}

- (void)setAPIKeys {
    NSDictionary *keys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"API-keys" ofType:@"plist"]];

    self.LOOKUP_API_KEY   = keys[@"typeahead"];
    self.REALTIME_API_KEY = keys[@"realtimedeparturesV4"];
    self.NEARBY_API_KEY   = keys[@"nearbystops"];
}

#pragma mark - SL Platsuppslag
NSString *const LOOKUP_API_ENDPOINT = @"http://api.sl.se/api2/typeahead.json?key=%@&searchstring=%@&maxresults=30";

- (void)getStopsMatchingString:(NSString *)searchString completion:(void (^)(NSDictionary *))completion {
    NSString *percentEscapedString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *url                  = [NSString stringWithFormat:LOOKUP_API_ENDPOINT, self.LOOKUP_API_KEY, percentEscapedString];

    [self getFromUrl:url completion:completion];
}

#pragma mark - SL Realtidsinformation 4
NSString *const REALTIME_API_ENDPOINT = @"http://api.sl.se/api2/realtimedeparturesV4.json?key=%@&siteid=%ld&timewindow=60";

- (void)getRealtimeForStop:(NSInteger)siteID completion:(void (^)(NSDictionary *))completion {
    NSString *url = [NSString stringWithFormat:REALTIME_API_ENDPOINT, self.REALTIME_API_KEY, (long)siteID];

    [self getFromUrl:url completion:completion];
}

#pragma mark - SL Närliggande hållplatser
NSString *const NEARBY_API_ENDPOINT = @"http://api.sl.se/api2/nearbystops.json?key=%@&originCoordLat=%f&originCoordLong=%f&maxresults=30&radius=2000";

- (void)getNearbyStopsForLat:(float)latitude Long:(float)longitude completion:(void (^)(NSDictionary *))completion {
    NSString *url = [NSString stringWithFormat:NEARBY_API_ENDPOINT, self.NEARBY_API_KEY, latitude, longitude];

    [self getFromUrl:url completion:completion];
}

#pragma mark - Networking
- (void)getFromUrl:(NSString *)url completion:(void (^)(NSDictionary *))completion {
    [self.manager GET:url
           parameters:nil
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"Success: (GET %@)", url);
        completion(responseObject);
    }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Failure: (GET %@) \nReason: %@", url, error);
        completion(nil);
    }];
}

@end
