//
//  UIApplication+CurrentViewController.m
//  WealthOnline
//
//  Created by Rainy on 2018/1/16.
//  Copyright © 2018年 WealthOnline_iOS_team. All rights reserved.
//

#import "UIApplication+CurrentViewController.h"

@implementation UIApplication (CurrentViewController)

- (UIViewController *)getCurrentViewController {
    __block UIWindow *normalWindow = [self.delegate window];
    if (normalWindow.windowLevel != UIWindowLevelNormal) {
        [self.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.windowLevel == UIWindowLevelNormal) {
                normalWindow = obj;
                *stop        = YES;
            }
        }];
    }
    
    return [self nextTopForViewController:normalWindow.rootViewController];
}

- (UIViewController *)nextTopForViewController:(UIViewController *)inViewController {
    while (inViewController.presentedViewController) {
        inViewController = inViewController.presentedViewController;
    }
    
    if ([inViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedVC = [self nextTopForViewController:((UITabBarController *)inViewController).selectedViewController];
        return selectedVC;
    } else if ([inViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *selectedVC = [self nextTopForViewController:((UINavigationController *)inViewController).visibleViewController];
        return selectedVC;
    } else {
        return inViewController;
    }
}

@end
