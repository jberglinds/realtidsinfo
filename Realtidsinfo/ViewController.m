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
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *stopViewControllers; // of RealtimeStopViewController
@end

@implementation ViewController

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
    
    RealtimeStopViewController *test2 = [self.storyboard instantiateViewControllerWithIdentifier:@"RealtimeStopViewController"];
    test2.location = @"Huddinge";
    [self.stopViewControllers addObject:test2];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    return 0;
}


@end
