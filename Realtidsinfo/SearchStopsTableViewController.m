//
//  SearchStopsTableViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-29.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "SearchStopsTableViewController.h"
#import "TrafiklabAPI.h"
#import "LeftAndRightTableViewCell.h"
#import "Regexer.h"

@interface SearchStopsTableViewController ()
@property (strong, nonatomic) TrafiklabAPI *API;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *locationResults;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *searchResults;
@end

@implementation SearchStopsTableViewController 

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get user location once for nearby stops
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestLocation];
    
    // Add search controller with searchbar for searching for stops, using existing tableview for results
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Sök efter hållplatser";
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialization
- (TrafiklabAPI *)API {
    if(!_API) _API = [[TrafiklabAPI alloc] init];
        return _API;
}

#pragma mark - CLLocationManagerDelegate
// Called when location was updated
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    
    // Lookup nearby stops using API and reload table to show results
    [self.API getNearbyStopsForLat:currentLocation.coordinate.latitude Long:currentLocation.coordinate.longitude completion:^(NSDictionary *response) {
        self.locationResults = response[@"LocationList"][@"StopLocation"];
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
    if(![self.searchController.searchBar.text isEqualToString:@""]) {
        // Get results from API and reload table to show them
        [self.API getStopsMatchingString:searchController.searchBar.text completion:^(NSDictionary *response) {
            self.searchResults = response[@"ResponseData"];
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
    if(self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        return [self.searchResults count];
    } else {
        return [self.locationResults count];
    }
}

// Section title depending on if we are searching or not
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // If search is active
    if(self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        return @"Sökresultat";
    } else {
        return @"Närliggande hållplatser";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"stopResult" forIndexPath:indexPath];
    NSString *stopName;
    
    // If search is active:
    if(self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        stopName = self.searchResults[indexPath.row][@"Name"];
        ((LeftAndRightTableViewCell *)cell).rightTextLabel.text = @"";
    } else {
        stopName = self.locationResults[indexPath.row][@"name"];
        ((LeftAndRightTableViewCell *)cell).rightTextLabel.text = [self.locationResults[indexPath.row][@"dist"] stringByAppendingString:@"m"];
    }
    
    // If the stopname ends with a name of the area in parentheses, extract it and show in detailLabel of cell.
    NSArray *matches = [self splitIntoLocationAndAreaNames:stopName];
    if (matches) {
        cell.textLabel.text = [matches[1] text];
        cell.detailTextLabel.text = [matches[2] text];
    } else {
        cell.textLabel.text = stopName;
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

// Returns an array of the name split into stopname and areaname if areaname is present, otherwise nil
// TODO: Make this better and cleaner. 
- (NSArray *)splitIntoLocationAndAreaNames:(NSString *)stopName {
    NSString *pattern = @"(.+)\\(([\\w\\s]+)\\)";
    NSArray *matches = [stopName rx_matchesWithPattern:pattern];
    if (([matches count] == 1) && ([[matches[0] captures] count] == 3)) {
        return [matches[0] captures];
    } else {
        return nil;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate addNewStopWithName:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions
- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
