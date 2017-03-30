//
//  SearchStopsTableViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-29.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "SearchStopsTableViewController.h"
#import "TrafiklabAPI.h"

@interface SearchStopsTableViewController ()
@property (strong, nonatomic) TrafiklabAPI *API;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *searchResults;
@end

@implementation SearchStopsTableViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Search stops";
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (TrafiklabAPI *)API {
    if(!_API) _API = [[TrafiklabAPI alloc] init];
        return _API;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        return [self.searchResults count];
    } else {
        return 0;
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // Get results from API
    [self.API getStopsMatchingString:searchController.searchBar.text completion:^(NSDictionary *response) {
        self.searchResults = response[@"ResponseData"];
        [self.tableView reloadData];
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResult" forIndexPath:indexPath];
    
    if(self.searchController.active && ![self.searchController.searchBar.text isEqualToString:@""]) {
        cell.textLabel.text = self.searchResults[indexPath.row][@"Name"];
    } else {
        
    }
    
    return cell;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
