//
//  ConfigureLightsView.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-04-13.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "ConfigureLightsView.h"
#import "LightsController.h"

@interface ConfigureLightsView ()
@property (strong, nonatomic) LightsController *lightsController;
@end

@implementation ConfigureLightsView

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lightsController = [LightsController sharedInstance];
    
    // Observe changes to available lights in order to update table with them
    [self.lightsController addObserver:self forKeyPath:@"lights" options:0 context:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    // Remove observer before deallocating to avoid crash
    [self.lightsController removeObserver:self forKeyPath:@"lights"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"lights"]) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [self.lightsController.lights count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Synkronisera lampor";
    } else {
        return @"HomeKit-lampor";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"Synkronisera färgen på HomeKit-lampor till tid kvar för avgångar.";
    } else {
        return @"Välj de lampor som ska användas. Endast lampor som stöder ändring av färg genom HomeKit visas här.";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"killSwitchCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Aktiverad";
        cell.detailTextLabel.text = @"";
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        switchview.on = self.lightsController.activated;
        [switchview addTarget:self action:@selector(switchWasToggled:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchview;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"lightCell" forIndexPath:indexPath];
        HMService *light = self.lightsController.lights[indexPath.row];
        cell.textLabel.text = light.name;
        if ([self.lightsController.activatedLights containsObject:light]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)switchWasToggled:(UISwitch *)sender {
    self.lightsController.activated = sender.on;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        HMService *light = self.lightsController.lights[indexPath.row];
        if ([self.lightsController.activatedLights containsObject:light]) {
            [self.lightsController deactivateLight:light];
        } else {
            [self.lightsController activateLight:light];
        }
        [self.tableView reloadData];
    }
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
