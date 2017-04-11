//
//  ConfigureStopViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-04-04.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "ConfigureStopView.h"
#import <MapKit/MapKit.h>
#import "TrafiklabAPI.h"

@interface ConfigureStopView ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableViewCell *firstDirectionSelectionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *secondDirectionSelectionCell;


@property (strong, nonatomic) TrafiklabAPI    *API;
@end

@implementation ConfigureStopView

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.stop.stopName;
    
    // Create pin on map with stop location and name
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = CLLocationCoordinate2DMake(self.stop.latitude, self.stop.longitude);
    pin.title = self.stop.stopName;
    pin.subtitle = @"Hållplats";
    [self.mapView addAnnotation:pin];
    
    // Zoom in map around newly added pin
    [self.mapView setRegion:MKCoordinateRegionMake(pin.coordinate, MKCoordinateSpanMake(0.003, 0.003)) animated:YES];
    
    // Get realtime for stop to find different directions and fill selection cells
    [self.API getRealtimeForStop:self.stop.stopID completion:^(NSDictionary *response) {
        // One set of destinations for each journey direction
        NSMutableSet *one = [[NSMutableSet alloc] init];
        NSMutableSet *two = [[NSMutableSet alloc] init];
        for (NSDictionary *departure in response[@"ResponseData"][@"Buses"]) {
            if ([departure[@"JourneyDirection"] isEqual:@1]) {
                [one addObject:departure[@"Destination"]];
            } else {
                [two addObject:departure[@"Destination"]];
            }
        }
        // Set cell labels to destinations from result and reload to resize cells
        if ([one count]) self.firstDirectionSelectionCell.textLabel.text = [[one allObjects] componentsJoinedByString:@", "];
        if ([two count]) self.secondDirectionSelectionCell.textLabel.text = [[two allObjects] componentsJoinedByString:@", "];
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension; // Resize to content (AutoLayout)
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44; // or whatever
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    // Change checkmark state to counterpart
    cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryNone ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Initialization
- (TrafiklabAPI *)API {
    if (!_API) _API = [[TrafiklabAPI alloc] init];
    return _API;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Set journeydirection depending on which cells has checkmarks
    if (self.firstDirectionSelectionCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        if (self.secondDirectionSelectionCell.accessoryType != UITableViewCellAccessoryCheckmark) {
            self.stop.journeyDirection = 1;
        }
    } else if (self.secondDirectionSelectionCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        self.stop.journeyDirection = 2;
    }
}

@end
