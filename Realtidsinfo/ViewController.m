//
//  ViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-02-24.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesCountdownLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsCountDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *busLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (nonatomic) NSInteger locationID;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *busName;
@property (strong, nonatomic) NSDate *expectedTime;
@property (nonatomic) NSDate *updatedAt;
@end

@implementation ViewController

NSString *const LOCATION = @"Riksten";
NSString *LOOKUP_API_KEY;
NSString *REALTIME_API_KEY;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setAPIKeys];
    [self setup];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateRealTime) userInfo:nil repeats:YES];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
    return _dateFormatter;
}

- (void)setAPIKeys {
    NSDictionary *keys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"API-keys" ofType:@"plist"]];
    LOOKUP_API_KEY = keys[@"typeahead"];
    REALTIME_API_KEY = keys[@"realtimedeparturesV4"];
}

- (void)setup {
    NSString *urlString = [NSString stringWithFormat:@"http://api.sl.se/api2/typeahead.json?key=%@&searchstring=%@", LOOKUP_API_KEY, LOCATION];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *firstHit = responseObject[@"ResponseData"][0];
        self.locationName = firstHit[@"Name"];
        self.locationID = [firstHit[@"SiteId"] integerValue];
        [self updateRealTime];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.locationName = @"Network Error";
        self.locationID = -1;
        [self updateUI];
    }];
    
}

- (void)updateUI {
    self.locationLabel.text = self.locationName;
    
    double timeLeft = [self.expectedTime timeIntervalSinceNow];
    self.minutesCountdownLabel.text = [NSString stringWithFormat:@"%d min", [self getMinutesFromInterval:timeLeft]];
    self.secondsCountDownLabel.text = [NSString stringWithFormat:@"%d sek", [self getSecondsFromInterval:timeLeft]];
    self.busLabel.text = self.busName;
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Uppdaterad för %d sekunder sedan", (int)-[self.updatedAt timeIntervalSinceNow]];
    
    [self updateBackgroundToMinutesLeft:[self getMinutesFromInterval:timeLeft] secondsLeft:[self getSecondsFromInterval:timeLeft]];
}

- (void)updateBackgroundToMinutesLeft:(int)minutes secondsLeft:(int)seconds {
    [UIView animateWithDuration:0.9f animations:^{
        if (minutes <= 0) {
            // Pulsate
            if ((seconds % 2) == 0) {
                self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0145 blue:0.0 alpha:1.0];
            } else {
                self.view.backgroundColor = [UIColor blackColor];
            }
        } else if (minutes <=2) {
            self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0145 blue:0.0 alpha:1.0];
        } else if (minutes <= 5) {
            self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.6372 blue:0.0 alpha:1.0];
        } else if (minutes <= 10) {
            self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.877 blue:0.2838 alpha:1.0];
        } else {
            self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.46 blue:1.0 alpha:1.0];
        }
    }];
    
}

- (int)getMinutesFromInterval:(NSTimeInterval)interval {
    return floor(interval/60);
}

- (int)getSecondsFromInterval:(NSTimeInterval)interval {
    return (int) interval % 60;
}


- (void)updateRealTime {
    NSString *urlString = [NSString stringWithFormat:@"http://api.sl.se/api2/realtimedeparturesV4.json?key=%@&siteid=%ld&timewindow=60",
                           REALTIME_API_KEY, (long)self.locationID];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseData = responseObject[@"ResponseData"];
        
        NSDate *latestUpdate = [self.dateFormatter dateFromString:responseData[@"LatestUpdate"]];
        // Only update if response has newer update, API is not very good at giving latest at all times.
        if (!self.updatedAt || [latestUpdate timeIntervalSinceDate:self.updatedAt] > 0) {
            self.updatedAt = latestUpdate;
            for (NSDictionary *bus in responseData[@"Buses"]) {
                if ([bus[@"JourneyDirection"] isEqual: @2]) {
                    self.busName = bus[@"LineNumber"];
                    self.expectedTime = [self.dateFormatter dateFromString:bus[@"ExpectedDateTime"]];
                    return;
                }
            }
            // None found
            self.busName = @"Inga avgångar";
            self.expectedTime = nil;
        }
    } failure:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
