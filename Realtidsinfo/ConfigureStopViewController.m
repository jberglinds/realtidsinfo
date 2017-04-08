//
//  ConfigureStopViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-04-04.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "ConfigureStopViewController.h"
#import <MapKit/MapKit.h>

@interface ConfigureStopViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ConfigureStopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.stopInfo[@"name"];
    
    // Create pin on map with stop location and name
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = CLLocationCoordinate2DMake([self.stopInfo[@"lat"] doubleValue], [self.stopInfo[@"long"] doubleValue]);
    pin.title = self.stopInfo[@"name"];
    pin.subtitle = @"Hållplats";
    [self.mapView addAnnotation:pin];
    
    // Zoom in map around newly added pin
    [self.mapView setRegion:MKCoordinateRegionMake(pin.coordinate, MKCoordinateSpanMake(0.003, 0.003)) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
