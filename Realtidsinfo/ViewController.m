//
//  ViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-02-24.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "ViewController.h"
#import "RealtimeSite.h"
#import "AFNetworking.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *minutesCountdownLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsCountDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *busLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@property (strong, nonatomic) RealtimeSite *site;
@property (strong, nonatomic) NSTimer *UIUpdateTimer;
@end

@implementation ViewController

NSString const *LOCATION = @"Riksten";
NSString const *LOOKUP_API_KEY;
NSString const *LOOKUP_API_ENDPOINT = @"http://api.sl.se/api2/typeahead.json";

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setup];
}

//TODO: Not sure if removing timers when disappearing is needed.
- (void)viewWillDisappear:(BOOL)animated {
    [self.site stopUpdates];
    [self.UIUpdateTimer invalidate];
    self.UIUpdateTimer = nil;
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.site startUpdates];
    self.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization
- (void)setAPIKey {
    NSDictionary *keys = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"API-keys" ofType:@"plist"]];
    LOOKUP_API_KEY = keys[@"typeahead"];
}

- (void)setup {
    [self setAPIKey];
    NSString *urlString = [LOOKUP_API_ENDPOINT stringByAppendingString:[NSString stringWithFormat:@"?key=%@&searchstring=%@",
                                                                        LOOKUP_API_KEY, LOCATION]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *firstHit = responseObject[@"ResponseData"][0];
        NSInteger siteID = [firstHit[@"SiteId"] integerValue];
        self.site = [[RealtimeSite alloc] initWithSiteID:siteID];
        [self.site startUpdates];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //TODO: Deal with error in a better way
        NSLog(@"ViewController setup(): %@", error);
    }];
    
}

#pragma mark - UI Updates
- (void)updateUI {
    self.locationLabel.text = self.site.locationName;
    
    double timeLeft = [self.site.expectedAt timeIntervalSinceNow];
    if (timeLeft > 0) {
        self.minutesCountdownLabel.text = [NSString stringWithFormat:@"%d min", [self getMinutesFromInterval:timeLeft]];
        self.secondsCountDownLabel.text = [NSString stringWithFormat:@"%d sek", [self getSecondsFromInterval:timeLeft]];
    } else {
        self.minutesCountdownLabel.text = @"Nu";
        self.secondsCountDownLabel.text = @"";
    }
    
    self.busLabel.text = self.site.busName;
    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Uppdaterad för %d sekunder sedan", (int)-[self.site.updatedAt timeIntervalSinceNow]];
    
    [self updateBackgroundToTimeLeft:timeLeft];
}

- (void)updateBackgroundToTimeLeft:(NSTimeInterval)timeLeft {
    [UIView animateWithDuration:0.9f animations:^{
        int minutesLeft = [self getMinutesFromInterval:timeLeft];
        int secondsLeft = [self getSecondsFromInterval:timeLeft];
        if (minutesLeft <= 0) {
            // Pulsate
            if ((secondsLeft % 2) == 0) {
                self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0145 blue:0.0 alpha:1.0];
            } else {
                self.view.backgroundColor = [UIColor blackColor];
            }
        } else if (minutesLeft <=2) {
            self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0145 blue:0.0 alpha:1.0];
        } else if (minutesLeft <= 5) {
            self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.6372 blue:0.0 alpha:1.0];
        } else if (minutesLeft <= 10) {
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
    return (int)interval%60;
}

@end
