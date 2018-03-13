//
//  SearchStopsTableViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-29.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "SearchStopsView.h"
#import "LeftAndRightTableViewCell.h"
#import "ConfigureStopView.h"
#import "TrafiklabAPI.h"
#import "StopInfo.h"
#import "Regexer.h"

@interface SearchStopsView ()
@property (strong, nonatomic) TrafiklabAPI *API;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *locationResults;                 // of StopInfo

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *searchResults;                   // of StopInfo

@property (strong, nonatomic) StopInfo *stopInfoForSelectedCell;
@end

@implementation SearchStopsView

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    // Get user location once for nearby stops
    self.locationManager                 = [[CLLocationManager alloc] init];
    self.locationManager.delegate        = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestLocation];

    // Add search controller with searchbar for searching for stops, using existing tableview for results
    self.searchController                                  = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater             = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder            = @"Sök efter hållplatser";
    self.definesPresentationContext                        = YES;
    self.tableView.tableHeaderView                         = self.searchController.searchBar;
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

#pragma mark - CLLocationManagerDelegate
// Called when location was updated
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];

    // Lookup nearby stops using API and reload table to show results
    [self.API getNearbyStopsForLat:currentLocation.coordinate.latitude
                              Long:currentLocation.coordinate.longitude
                        completion:^(NSDictionary *response) {
        NSMutableArray *results = [[NSMutableArray alloc] init];

        // Loop over response and insert entries in results array
        for (NSDictionary *stop in response[@"LocationList"][@"StopLocation"]) {
            NSArray *splitted = [self splitIntoLocationAndAreaNames:stop[@"name"]];

            // ID comes prefixed with "30010" for nearby-stops API, removing prefix
            NSInteger stopID = [[stop[@"id"] substringFromIndex:5] integerValue];

            // Create StopInfo object and add to results array
            StopInfo *info = [[StopInfo alloc] init];
            info.stopID    = stopID;
            info.stopName  = splitted[0];
            info.areaName  = splitted[1];
            info.distance  = [stop[@"dist"] integerValue];
            info.latitude  = [stop[@"lat"] floatValue];
            info.longitude = [stop[@"lon"] floatValue];

            [results addObject:info];
        }

        self.locationResults = [results copy];
        [self.tableView reloadData];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    // TODO: Handle it like an adult
    NSLog(@"%@", error);
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // If search is active
    if (![self.searchController.searchBar.text isEqualToString:@""]) {
        // Get results from API and reload table to show them
        [self.API getStopsMatchingString:searchController.searchBar.text
                              completion:^(NSDictionary *response) {
            NSMutableArray *results = [[NSMutableArray alloc] init];

            // Loop over response and insert entries in results array
            for (NSDictionary *stop in response[@"ResponseData"]) {
                NSArray *splitted = [self splitIntoLocationAndAreaNames:stop[@"Name"]];

                // Coordinates are missing delimiter for typeahead-api. Insert manually between second and third digits
                NSMutableString *latitude = [stop[@"Y"] mutableCopy];
                [latitude insertString:@"."
                               atIndex:2];
                NSMutableString *longitude = [stop[@"X"] mutableCopy];
                [longitude insertString:@"."
                                atIndex:2];

                // Create StopInfo object and add to results array
                StopInfo *info = [[StopInfo alloc] init];
                info.stopID    = [stop[@"SiteId"] integerValue];
                info.stopName  = splitted[0];
                info.areaName  = splitted[1];
                info.latitude  = [latitude floatValue];
                info.longitude = [longitude floatValue];

                [results addObject:info];
            }

            self.searchResults = [results copy];
            [self.tableView reloadData];
        }];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - UITable​View​Data​Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // If search is active
    if (self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        return [self.searchResults count];
    } else {
        return [self.locationResults count];
    }
}

// Section title depending on if we are searching or not
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // If search is active
    if (self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        return @"Sökresultat";
    } else {
        return @"Närliggande hållplatser";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftAndRightTableViewCell *cell = (LeftAndRightTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"stopResult" forIndexPath:indexPath];
    StopInfo *stopInfo;

    // If search is active:
    if (self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        stopInfo = self.searchResults[indexPath.row];
    } else {
        stopInfo = self.locationResults[indexPath.row];
    }

    cell.textLabel.text       = stopInfo.stopName;
    cell.detailTextLabel.text = stopInfo.areaName;

    if (stopInfo.distance) {
        cell.rightTextLabel.text = [NSString stringWithFormat:@"%ldm", (long)stopInfo.distance];
    } else {
        cell.rightTextLabel.text = @"";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // If search is active:
    if (self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        self.stopInfoForSelectedCell = self.searchResults[indexPath.row];
    } else {
        self.stopInfoForSelectedCell = self.locationResults[indexPath.row];
    }

    [self performSegueWithIdentifier:@"showStopDetails" sender:self];
}

#pragma mark - Utility
// Returns an array of the name split into stopname and areaname.
// Example: "Tullinge Station (Botkyrka)" gets split into ["Tullinge Station", "Botkyrka"]
// TODO: Make this better and cleaner.
- (NSArray *)splitIntoLocationAndAreaNames:(NSString *)stopName {
    NSString *pattern = @"(.+)\\(([\\w\\s-]+)\\)";
    NSArray *matches  = [stopName rx_matchesWithPattern:pattern];

    if (([matches count] == 1) && ([[matches[0] captures] count] == 3)) {
        return @[[[matches[0] captures][1] text], [[matches[0] captures][2] text]];
    } else {
        return @[stopName, @""];
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showStopDetails"]) {
        ConfigureStopView *destinationVC = [segue destinationViewController];
        destinationVC.stop = self.stopInfoForSelectedCell;
    }
}

#pragma mark - Actions
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
