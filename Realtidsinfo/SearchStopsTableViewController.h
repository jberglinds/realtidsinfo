//
//  SearchStopsTableViewController.h
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-29.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol SearchStopsTableViewControllerDelegate

- (void)addNewStopWithName:(NSString *)stopName;

@end

@interface SearchStopsTableViewController : UITableViewController <UISearchResultsUpdating, CLLocationManagerDelegate>

@property (strong, nonatomic) id <SearchStopsTableViewControllerDelegate> delegate;

@end
