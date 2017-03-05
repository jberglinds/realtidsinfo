//
//  UIPageViewControllerWithOverlayIndicator.m
//  Realtidsinfo
//
//  Created by Jonathan Berglind on 2017-03-05.
//  Copyright © 2017 Jonathan Berglind. All rights reserved.
//

#import "UIPageViewControllerWithOverlayIndicator.h"

@interface UIPageViewControllerWithOverlayIndicator ()

@end

@implementation UIPageViewControllerWithOverlayIndicator

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Puts the page indicator on top of the page views instead of below them.
- (void)viewDidLayoutSubviews {
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            subview.frame = self.view.bounds;
        } else if ([subview isKindOfClass:[UIPageControl class]]) {
            [self.view bringSubviewToFront:subview];
        }
    }
    [super viewDidLayoutSubviews];
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
