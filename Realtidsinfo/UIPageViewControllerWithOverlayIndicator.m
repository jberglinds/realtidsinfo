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

@end
