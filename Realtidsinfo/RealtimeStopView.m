//
//  ViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-02-24.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "RealtimeStopView.h"
#import "RealtimeSite.h"
#import "TrafiklabAPI.h"
#import "Departure.h"
#import "LightsController.h"

@interface RealtimeStopView ()
@property (strong, nonatomic) TrafiklabAPI *API;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;
@property (weak, nonatomic) IBOutlet UIView *countdownView;
@property (weak, nonatomic) IBOutlet UILabel *busLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@property (strong, nonatomic) RealtimeSite *site;
@property (strong, nonatomic) NSTimer *UIUpdateTimer;

@property (strong, nonatomic) LightsController *lightsController;
@end

@implementation RealtimeStopView

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationLabel.text = self.locationName;

    // Create Realtime object and start updates
    self.site = [[RealtimeSite alloc] initWithSiteID:self.stopID];
    [self.site startUpdates];
    [self updateUI];
    
    // Add border around countdown view, only for the looks.
    self.countdownView.layer.borderColor = UIColor.whiteColor.CGColor;
    self.countdownView.layer.cornerRadius = 10;
    self.countdownView.layer.borderWidth = 5;
    
    self.lightsController = [LightsController sharedInstance];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//TODO: Not sure if removing timers when disappearing is needed.
- (void)viewWillDisappear:(BOOL)animated {
    // Remove observing to avoid crash
    [self.view removeObserver:self forKeyPath:@"backgroundColor"];
    
    [self.site stopUpdates];
    [self.UIUpdateTimer invalidate];
    self.UIUpdateTimer = nil;
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.site startUpdates];
    self.UIUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    [super viewWillAppear:animated];
    
    // Observe changes to background color to be able to change HomeKit lights accordingly
    [self.view addObserver:self forKeyPath:@"backgroundColor" options:NSKeyValueObservingOptionOld context:nil];
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

#pragma mark - UI Updates
- (void)updateUI {
    Departure *nextDeparture = nil;

    for (Departure *departure in self.site.departures) {
        if (!self.journeyDirection || departure.journeyDirection == self.journeyDirection) {
            nextDeparture = departure;
            break;
        }
    }

    if (nextDeparture) {
        self.locationLabel.text = nextDeparture.stopArea;
        self.busLabel.text      = [NSString stringWithFormat:@"Buss %@ mot %@", nextDeparture.line, nextDeparture.destination];

        double timeLeft = [nextDeparture.expectedAt timeIntervalSinceNow];

        if (timeLeft > 0) {
            int minutes = [self getMinutesFromInterval:timeLeft];
            NSString *minutesString = minutes == 1 ? @"minut" : @"minuter";
            int seconds = [self getSecondsFromInterval:timeLeft];
            NSString *secondsString = seconds == 1 ? @"sekund" : @"sekunder";
            if (minutes == 0) {
                self.countdownLabel.text = [NSString stringWithFormat:@"%d %@", seconds, secondsString];
            } else {
                self.countdownLabel.text = [NSString stringWithFormat:@"%d %@ och %d %@", minutes, minutesString, seconds, secondsString];
            }
        } else {
            self.countdownLabel.text = @"Nu";
        }

        [self updateBackgroundToTimeLeft:timeLeft];
    } else {
        self.locationLabel.text   = self.locationName;
        self.busLabel.text        = @"";
        self.countdownLabel.text  = @"Inga avgångar";
        self.view.backgroundColor = [UIColor grayColor];
    }

    self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Uppdaterad för %d sekunder sedan", (int)-[self.site.updatedAt timeIntervalSinceNow]];
}

// Set different background colors for view depending on time left to departure
- (void)updateBackgroundToTimeLeft:(NSTimeInterval)timeLeft {
    [UIView animateWithDuration:0.9f
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
        int minutesLeft = [self getMinutesFromInterval:timeLeft];
        int secondsLeft = [self getSecondsFromInterval:timeLeft];

        if (minutesLeft <= 0) {
            // Pulsate
            if ((secondsLeft % 2) != 0) {
                self.view.backgroundColor = [UIColor colorWithRed:1.0
                                                            green:0.2958
                                                             blue:0.25
                                                            alpha:1.0];

            } else {
                self.view.backgroundColor = [UIColor whiteColor];
            }
        } else if (minutesLeft <= 2) {
            // Red
            self.view.backgroundColor = [UIColor colorWithRed:1.0
                                                        green:0.2958
                                                         blue:0.25
                                                        alpha:1.0];
        } else if (minutesLeft <= 5) {
            // Orange
            self.view.backgroundColor = [UIColor colorWithRed:1.0
                                                        green:0.7603
                                                         blue:0.3005
                                                        alpha:1.0];
        } else if (minutesLeft <= 10) {
            // Green
            self.view.backgroundColor = [UIColor colorWithRed:0.0
                                                        green:0.8286
                                                         blue:0.3972
                                                        alpha:1.0];
        } else {
            // Blue
            self.view.backgroundColor = [UIColor colorWithRed:0.0
                                                        green:0.5541
                                                         blue:0.8847
                                                        alpha:1.0];
        }
    }
                     completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"backgroundColor"]) {
        if (![self.view.backgroundColor isEqual:self.lightsController.currentColor]) {
            [self.lightsController setLightsToColor:self.view.backgroundColor];
        }
    }
}

- (int)getMinutesFromInterval:(NSTimeInterval)interval {
    return floor(interval / 60);
}

- (int)getSecondsFromInterval:(NSTimeInterval)interval {
    return (int)interval % 60;
}

@end
