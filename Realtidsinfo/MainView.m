//
//  ViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-04.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "MainView.h"
#import "RealtimeStopView.h"
#import "ConfigureStopView.h"

@interface MainView ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeStopButton;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *stopViewControllers; // of RealtimeStopView
@end

@implementation MainView

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set navbar to be transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    // Set up pageview controller that will hold all the RealtimeStopViews
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimePageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    // Load stop locations from persistent storage and init pageviews for them
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSDictionary *stop in [defaults objectForKey:@"stops"]) {
        RealtimeStopView *stopVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeStopView"];
        stopVC.locationName = stop[@"name"];
        stopVC.stopID = [stop[@"id"] integerValue];
        stopVC.journeyDirection = [stop[@"direction"] integerValue];
        [self.stopViewControllers addObject:stopVC];
    }
    
    // Start pageviewcontroller with first stopviewcontroller
    if ([self.stopViewControllers count]) {
        [self.pageViewController setViewControllers:@[[self.stopViewControllers firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    // Add pageview to view
    self.pageViewController.view.frame = self.view.frame;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    // Get statusbar style from first page in pageview
    return self.pageViewController.viewControllers[0];
}

#pragma mark - Initialization
- (NSMutableArray *)stopViewControllers {
    if (!_stopViewControllers) _stopViewControllers = [[NSMutableArray alloc] init];
    return _stopViewControllers;
}

#pragma mark - UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.stopViewControllers indexOfObject:viewController];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    } else {
        index--;
        return self.stopViewControllers[index];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.stopViewControllers indexOfObject:viewController];
    
    if ((index == [self.stopViewControllers count]-1) || (index == NSNotFound)) {
        return nil;
    } else {
        index++;
        return self.stopViewControllers[index];
    }
}

// How many dots for indicator
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.stopViewControllers count];
}

// Which dot should be active in indicator
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return [self.stopViewControllers indexOfObject:[pageViewController.viewControllers firstObject]];
}

#pragma mark - Navigation
- (IBAction)unwindAndSaveSegue:(UIStoryboardSegue *)segue {
    ConfigureStopView *sourceVC = [segue sourceViewController];
    StopInfo *stop = sourceVC.stop;
    [self addNewStopWithID:stop.stopID andName:stop.stopName withDirection:stop.journeyDirection];
}

#pragma mark -

- (void)addNewStopWithID:(NSInteger)stopID andName:(NSString *)stopName withDirection:(NSInteger)journeyDirection {
    RealtimeStopView *stopVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeStopView"];
    stopVC.stopID = stopID;
    stopVC.locationName = stopName;
    stopVC.journeyDirection = journeyDirection;
    [self.stopViewControllers addObject:stopVC];
    
    // Due to bug in UIPageViewController which causes it to use cached pages that should have been removed.
    // Bug only present when using animation so we disable it for the first page to clear cache.
    // http://stackoverflow.com/questions/14220289/removing-a-view-controller-from-uipageviewcontroller#17330606
    if ([self.stopViewControllers count] == 1) {
        [self.pageViewController setViewControllers:@[stopVC] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else {
        [self.pageViewController setViewControllers:@[stopVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    // Always add pageviewcontroller to view. Might have been removed by removeButtonPressed if empty.
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    self.removeStopButton.enabled = YES;
    
    // Write to persistent storage
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *stops = [[defaults arrayForKey:@"stops"] mutableCopy];
    if (!stops) stops = [[NSMutableArray alloc] init];
    [stops addObject:@{
                        @"name": stopName,
                        @"id": @(stopID),
                        @"direction": @(journeyDirection)
                       }];
    [defaults setObject:stops forKey:@"stops"];
    [defaults synchronize];
}

#pragma mark - Actions
- (IBAction)removeButtonPressed:(UIBarButtonItem *)sender {
    // Ask for confirmation with dialog before removing stop
    UIAlertController *confirmController = [UIAlertController alertControllerWithTitle:@"Ta bort hållplats" message:@"Vill du verkligen ta bort hållplatsen?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"Ta bort" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // Remove from array with controllers for pageview
        RealtimeStopView *currentVC = [self.pageViewController.viewControllers firstObject];
        NSInteger index = [self.stopViewControllers indexOfObject:currentVC];
        [self.stopViewControllers removeObject:currentVC];
        
        // Handle transition to new page or hiding of pageviewcontroller in case it should be empty
        if ([self.stopViewControllers count] == 0) {
            [self.pageViewController removeFromParentViewController];
            [self.pageViewController.view removeFromSuperview];
            self.removeStopButton.enabled = NO;
        } else if ([self.stopViewControllers count] <= index) {
            [self.pageViewController setViewControllers:@[[self.stopViewControllers lastObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        } else {
            [self.pageViewController setViewControllers:@[self.stopViewControllers[index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }
        
        // Write to persistent storage
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *stops = [[defaults arrayForKey:@"stops"] mutableCopy];
        [stops removeObjectAtIndex:index];
        [defaults setObject:stops forKey:@"stops"];
        [defaults synchronize];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Avbryt" style:UIAlertActionStyleCancel handler:nil];
    
    [confirmController addAction:actionCancel];
    [confirmController addAction:actionConfirm];
    
    [self presentViewController:confirmController animated:YES completion:nil];
}

@end
