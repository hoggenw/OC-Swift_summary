//
//  PSNavigationController.m
//  qianjituan2.0
//
//  Created by 小唐 on 7/27/16.
//  Copyright © 2016 ios-mac. All rights reserved.
//

#import "PSNavigationController.h"


@interface PSNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation PSNavigationController 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 当导航控制器管理的子控制器自定义了leftBarButtonItem，则子控制器左边缘右滑失效。解决方案一
    self.interactivePopGestureRecognizer.delegate = self;
    self.interactivePopGestureRecognizer.enabled  = YES;    // default is Yes
}

#pragma mark - delegate <UIGestureRecognizerDelegate>

// 左滑功能是否开启
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer{
    BOOL sholdBeginFlag = YES;
    
    //判断是否为rootViewController
    if (self.navigationController && self.navigationController.viewControllers.count == 1)
    {
        sholdBeginFlag =  NO;
    }
    // 根据当前控制器的类型决定是否开启
    else if (![self shouldRightSwipeWithChildViewController:self.childViewControllers.lastObject])
    {
        sholdBeginFlag =  NO;
    }
    return sholdBeginFlag;
}

- (BOOL)shouldRightSwipeWithChildViewController:(UIViewController *)childVC
{
    BOOL shouldFlag = YES;
    
    NSArray *notSwipeVCNames = @[@"PSResetPwdSuccessController", @"PSRegisterSuccessController", @"PSChangePhoneSuccessViewController", @"PSWebPayViewController", @"PSPayFailedViewController", @"PSPaySuccessViewController",@"PSAutographViewController"];
    for (NSString *vcName in notSwipeVCNames) {
        if ([childVC isKindOfClass:[NSClassFromString(vcName) class]]) {
            shouldFlag = NO;
            break;
        }
    }
    return shouldFlag;
}


@end
