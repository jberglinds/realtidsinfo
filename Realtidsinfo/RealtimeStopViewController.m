//
//  ViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-02-24.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "RealtimeStopViewController.h"
#import "RealtimeSite.h"
#import "TrafiklabAPI.h"

@interface RealtimeStopViewController ()
@property (strong, nonatomic) TrafiklabAPI *API;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UIView *countdownView;
@property (weak, nonatomic) IBOutlet UILabel *busLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@property (strong, nonatomic) RealtimeSite *site;
@property (strong, nonatomic) NSTimer *UIUpdateTimer;
@end

@implementation RealtimeStopViewController

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setup];
    // Add border around countdown view, only for the looks.
    self.countdownView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.countdownView.layer.borderWidth = 10;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
- (TrafiklabAPI *)API {
    if (!_API) _API = [[TrafiklabAPI alloc] init];
    return _API;
}

- (void)setup {
    [self.API getStopsMatchingString:self.location completion:^(NSDictionary *response) {
        if (response) {
            NSDictionary *firstHit = response[@"ResponseData"][0];
            NSInteger siteID = [firstHit[@"SiteId"] integerValue];
            self.site = [[RealtimeSite alloc] initWithSiteID:siteID];
            [self.site startUpdates];
        }
    }];
}

#pragma mark - UI Updates
- (void)updateUI {
    self.locationLabel.text = self.site.locationName;
    
    double timeLeft = [self.site.expectedAt timeIntervalSinceNow];
    if (timeLeft > 0) {
        self.countdownLabel.text = [NSString stringWithFormat:@"%d minuter och %d sekunder", [self getMinutesFromInterval:timeLeft], [self getSecondsFromInterval:timeLeft]];
    } else {
        self.countdownLabel.text = @"Nu";
    }
    
    self.busLabel.text = [NSString stringWithFormat:@"%@ mot %@", self.site.busName, self.site.busDestination];
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