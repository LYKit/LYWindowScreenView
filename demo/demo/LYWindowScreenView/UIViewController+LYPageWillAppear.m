//
//  UIViewController+LYPageWillAppear.m
//  bangjob
//
//  Created by langezhao on 2019/12/23.
//  Copyright © 2019 com.58. All rights reserved.
//

#import "UIViewController+LYPageWillAppear.h"
#import "NSObject+LYSwizzle.h"


@implementation UIViewController (LYPageWillAppear)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL oldviewWillAppear = @selector(viewWillAppear:);
        SEL newviewWillAppear = @selector(p_viewWillAppear:);
        
        SEL oldviewDidAppear = @selector(viewDidAppear:);
        SEL newviewDidAppear = @selector(p_viewDidAppear:);
        
        SEL oldviewWillDisappear = @selector(viewWillDisappear:);
        SEL newviewWillDisappear = @selector(p_viewWillDisappear:);
        
        SEL oldviewDidDisappear = @selector(viewDidDisappear:);
        SEL newviewDidDisappear = @selector(p_viewDidDisappear:);
        
        SEL oldpresentDidDisappear = @selector(presentViewController:animated:completion:);
        SEL newpresentDidDisappear = @selector(p_presentViewController:animated:completion:);

        
        [self swizzleInstanceSelector:oldviewWillAppear withNewSelector:newviewWillAppear];
        [self swizzleInstanceSelector:oldviewDidAppear withNewSelector:newviewDidAppear];
        [self swizzleInstanceSelector:oldviewWillDisappear withNewSelector:newviewWillDisappear];
        [self swizzleInstanceSelector:oldviewDidDisappear withNewSelector:newviewDidDisappear];
        [self swizzleInstanceSelector:oldpresentDidDisappear withNewSelector:newpresentDidDisappear];

    });
}

//修复ios13下模态页面问题
- (void)p_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (@available(iOS 13.0, *)) {
        if (viewControllerToPresent.modalPresentationStyle != UIModalPresentationCustom) {
            viewControllerToPresent.modalPresentationStyle = UIModalPresentationFullScreen;
        }
    } else {
        // Fallback on earlier versions
    }
    [self p_presentViewController:viewControllerToPresent animated:flag completion:completion];
}


- (void)p_viewWillAppear:(BOOL)animated {
    [self p_viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:LYViewControllerViewWillAppearNotification object:@{LYViewControllerClassName:NSStringFromClass([self class]),LYViewControllerClassIdentifier:self}];
}

- (void)p_viewDidAppear:(BOOL)animated {
    [self p_viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:LYViewControllerViewDidAppearNotification object:@{LYViewControllerClassName:NSStringFromClass([self class]),LYViewControllerClassIdentifier:self}];
}

- (void)p_viewWillDisappear:(BOOL)animated {
    [self p_viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:LYViewControllerViewWillDisappearNotification object:@{LYViewControllerClassName:NSStringFromClass([self class]),LYViewControllerClassIdentifier:self}];
}

- (void)p_viewDidDisappear:(BOOL)animated {
    [self p_viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:LYViewControllerViewDidDisappearNotification object:@{LYViewControllerClassName:NSStringFromClass([self class]),LYViewControllerClassIdentifier:self}];
}

// 获取当前显示的Controller
+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController* viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [self findBestViewController:viewController];
}

+ (UIViewController*)findBestViewController:(UIViewController*)vc {
    if (vc.presentedViewController) {
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
        return [self findBestViewController:svc.viewControllers.lastObject];
        else
        return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
        return [self findBestViewController:svc.topViewController];
        else
        return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
        return [self findBestViewController:svc.selectedViewController];
        else
        return vc;
    } else {
        return vc;
    }
}


+ (BOOL)existViewController:(UIViewController *)identifier{
    if ([identifier isKindOfClass:[UIViewController class]]) {
        if (identifier.navigationController || identifier.presentingViewController) {
            return YES;
        }
    }
    return NO;
}

@end
