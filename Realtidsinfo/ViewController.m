//
//  ViewController.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-04.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "ViewController.h"
#import "RealtimeStopViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeStopButton;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *stopViewControllers; // of RealtimeStopViewController
@end

@implementation ViewController

#pragma mark - Initialization
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set navbar to transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimePageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    RealtimeStopViewController *test1 = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeStopViewController"];
    test1.location = @"Riksten";
    [self.stopViewControllers addObject:test1];
    
    [self.pageViewController setViewControllers:@[test1] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.pageViewController.view.frame = self.view.frame;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    // Get statusbar style from first page in pageview
    return self.pageViewController.viewControllers[0];
}

- (NSMutableArray *)stopViewControllers {
    if (!_stopViewControllers) _stopViewControllers = [[NSMutableArray alloc] init];
    return _stopViewControllers;
}

#pragma mark - UIPageViewController
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
}

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

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [self.stopViewControllers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return [self.stopViewControllers indexOfObject:[pageViewController.viewControllers firstObject]];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNewStopSegue"]) {
        UINavigationController *navigationVC = (UINavigationController *)segue.destinationViewController;
        SearchStopsTableViewController *destinationVC = (SearchStopsTableViewController *)navigationVC.topViewController;
        destinationVC.delegate = self;
    }
}

#pragma mark - SearchStopsTableViewControllerDelegate
- (void)addNewStopWithName:(NSString *)stopName {
    RealtimeStopViewController *newPage = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeStopViewController"];
    newPage.location = stopName;
    [self.stopViewControllers addObject:newPage];
    
    // Due to bug in UIPageViewController which causes it to use cached pages that should have been removed.
    // Bug only present when using animation so we disable it for the first page to clear cache.
    // http://stackoverflow.com/questions/14220289/removing-a-view-controller-from-uipageviewcontroller#17330606
    if ([self.stopViewControllers count] == 1) {
        [self.pageViewController setViewControllers:@[newPage] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    } else {
        [self.pageViewController setViewControllers:@[newPage] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    // Always add pageviewcontroller to view. Might have been removed by removeButtonPressed if empty.
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    self.removeStopButton.enabled = YES;
}

#pragma mark - Actions
- (IBAction)removeButtonPressed:(UIBarButtonItem *)sender {
    UIAlertController *confirmController = [UIAlertController alertControllerWithTitle:@"Ta bort hållplats" message:@"Vill du verkligen ta bort hållplatsen?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"Ta bort" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        RealtimeStopViewController *currentVC = [self.pageViewController.viewControllers firstObject];
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
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Avbryt" style:UIAlertActionStyleCancel handler:nil];
    
    [confirmController addAction:actionCancel];
    [confirmController addAction:actionConfirm];
    
    [self presentViewController:confirmController animated:YES completion:nil];
}

@end
