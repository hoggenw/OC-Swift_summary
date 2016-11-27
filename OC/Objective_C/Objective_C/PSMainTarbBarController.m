//
//  PSMainTarbBarController.m
//  qianjituan2.0
//
//  Created by 小唐 on 7/4/16.
//  Copyright © 2016 ios-mac. All rights reserved.
//

#import "PSMainTarbBarController.h"
#import "PSLoginViewController.h"
#import "PSNavigationController.h"
#import <MeiQiaSDK/MeiQiaSDK.h>


@interface  PSMainTarbBarController () <UITabBarControllerDelegate>

/** 界面初始化 */
- (void)initialUserInterface;


/** 数据源初始化 */
- (void)initialDataSource;

/** 通知的统一处理 */
- (void)notificationProcess:(NSNotification *)notification;

@end

@implementation PSMainTarbBarController

#pragma mark - public function



#pragma mark - override function

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initialUserInterface];
    [self initialDataSource];
    [self judgeAppVersionUpdate];
    
    // 注册无效token通知的处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationProcess:) name:PSNotification_InvalidToken object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMQMessages:) name:MQ_RECEIVED_NEW_MESSAGES_NOTIFICATION object:nil];
    
}
- (void)didReceiveNewMQMessages:(NSNotification *)notification {
    //广播中的消息数组
    NSArray *messages = [notification.userInfo objectForKey:@"messages"];
    if (messages.count > 0) {
//        [PSHintView showMessageOnThisPage:@"客服有回复信息哦"];
        [[NSNotificationCenter defaultCenter] postNotificationName:PSNOTIFICATION_MESSAGE_SHOULDSHOW object:nil userInfo:@{PSNOTIFICATION_BOOL_FOR_MESSAGESHOW:@"YES"}] ;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PSNOTIFICATION_BOOL_FOR_MESSAGESHOW];
        
    }
    
}

- (void)dealloc
{
    // 通知移除
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    // 图片缓存清理
    
}

#pragma mark - extension function / private function


#pragma mark - extension UI布局

// 界面初始化
- (void)initialUserInterface
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // bar's title seleted color
    self.tabBar.tintColor = [[PSTheme sharedInstance] tintColor];
    // bar's background color(iOS7:tintColor -> barTintColor)
    //self.tabBar.barTintColor = [UIColor colorWithWhite:1 alpha:0.7];
    
    // 标签栏背景
    // 注：4，5，6，6+的适配问题
    //NSString *strImageName = nil;
    //self.tabBar.backgroundImage = [UIImage imageNamed:strImageName];
    
    // 代理
    self.delegate = self;
    
    // 添加子控制器
    NSArray *childVCNames  = @[@"HomepageViewController", @"ClassifyViewController", @"PSOrderProtoViewController", @"PSShoppingCartViewController", @"PersonalViewController"];
    NSArray *titles = @[@"首页", @"分类", @"闪电下单", @"购物车", @"我的"];
    NSArray *iconNames = @[@"1", @"2", @"3", @"4", @"5"];
    for (int i=0; i<childVCNames.count; i++)
    {
        UIViewController *childVC = [[NSClassFromString(childVCNames[i]) alloc] init];
        [self addChildVC:childVC title:titles[i] iconName:iconNames[i]];
    }

}

// 版本更新提示 判断
- (void)judgeAppVersionUpdate
{
    //    NSString *trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];1080261383
    NSString * strUrl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", AppID_PoGe];
    [[NetWorkManager shareManager] generalGetWithURL:strUrl param:nil returnBlock:^(NSDictionary *returnDict) {
        
       // NSLog(@"request app itunes info failure, responseObj : %@", returnDict);
        if (1 == [returnDict[@"resultCount"] integerValue])    // 获取成功
        {
            // 获取appstore 里的版本号
            NSDictionary * dicInfo = [returnDict[@"results"] firstObject];
            NSString * currentVersion = dicInfo[@"version"];
  
            currentVersion = [self dealVersionString:currentVersion];
            //NSLog(@"app.currentVersion=%@",currentVersion);
            NSString *trackViewUrl = [dicInfo objectForKey:@"trackViewUrl"];
            
            // 获取本地当前版本号
            NSDictionary * localInfo = [[NSBundle mainBundle] infoDictionary];
            
            NSString * localVersion  = [localInfo objectForKey:@"CFBundleShortVersionString"];
            
            localVersion = [self dealVersionString:localVersion];
            //NSLog(@"localVersion =%@",localVersion);
            // 这种方式要求填写一致  app上架申请里的版本必须和info配置里的版本一致
            // 判断版本号是否一致
            if (![currentVersion isEqualToString:localVersion]) // 不一致 提示有新版本更新
            {
                UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"更新" message:@"千机团版本有重要功能更新，是否前往更新？" preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:@"去更新" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackViewUrl]];
                }]];
                [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        }
        else    // 获取失败
        {
            NSLog(@"request app itunes info failure, responseObj : %@", returnDict);
        }
    }];
     
    
}

// 将传入的控制器包装成导航控制器作为子控制器
- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title iconName:(NSString *)iconName
{
    // 包装成导航控制器
    UINavigationController *nc = [[PSNavigationController alloc] initWithRootViewController:childVC];
    
    // 配置
    childVC.navigationItem.title = title;
    
    //UIImage * icon = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar-icon-%ld", [iconName integerValue]+5]];
    UIImage * icon = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar-icon-%@", @([iconName integerValue]+5)]];
    UIImage * selectedIcon = [UIImage imageNamed:[NSString stringWithFormat:@"tabbar-icon-%ld", (long)[iconName integerValue]]];
    
    // 设置图片渲染模式，UIImageRenderingModeAlwaysOriginal：始终绘制图片原始状态，不使用TintColor
    icon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectedIcon = [selectedIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:icon selectedImage:selectedIcon];
    nc.tabBarItem = tabBarItem;
    
    // 添加
    [self addChildViewController:nc];
    
}


#pragma mark - extension lazy load / getter



#pragma mark - extension 数据处理

// 数据源初始化
- (void)initialDataSource
{
    // 版本判断  是否提示更新
    
    
}


#pragma mark - extension 事件响应




#pragma mark - extension 通知处理

// 通知的统一处理
- (void)notificationProcess:(NSNotification *)notifiacation
{
    // 无效token通知 - 直接跳转
    if ([notifiacation.name isEqualToString:PSNotification_InvalidToken])
    {
        // 重置token
        PSUserModel *user = [[AccountManager sharedInstance] fetch];
        user.accessToken = nil;
        [[AccountManager sharedInstance] update:user];
        
        // 跳转到登录界面
        PSLoginViewController *loginVC = [[PSLoginViewController alloc] init];
        [(UINavigationController *)self.selectedViewController pushViewController:loginVC animated:YES];
    }
    
//    // 无效token通知 - 先提示，再选择跳转
//    if ([notifiacation.name isEqualToString:PSNotification_InvalidToken])
//    {
//        // 创建提示框
//        // 1.创建
//        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"登录已过期" preferredStyle:UIAlertControllerStyleAlert];
//        // 重置token
//        PSUserModel *user = [[AccountManager sharedInstance] fetch];
//        user.accessToken = nil;
//        [[AccountManager sharedInstance] update:user];
//        // 2.添加操作
//        // 2.1重新登录
//        [alertVC addAction:[UIAlertAction actionWithTitle:@"去登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//
//            // 跳转到登录界面
//            PSLoginViewController *loginVC = [[PSLoginViewController alloc] init];
//            // 跳转方式1.
////            [UIApplication sharedApplication].keyWindow.rootViewControler = [[UINavigationController alloc] initWithRootViewController:loginVC];
//            
//            // 跳转方式2.
//            [(UINavigationController *)self.selectedViewController pushViewController:loginVC animated:YES];
//            
//            // 跳转方式3.
////            [self presentViewController:loginVC animated:YES completion:nil];
//           
//        }]];
//        
//        // 2.2 取消操作
//        [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//        
//        // 3.显示
//        [self presentViewController:alertVC animated:YES completion:nil];
//    }
}


#pragma mark - delegate function


#pragma mark - delegate <UITabBarControllerDelegate>


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    BOOL selectFlag = YES;  // 允许选中标记

    if (self.selectedIndex == 0) {
        [MobClick event:@"导航首页"];
    }else if(self.selectedIndex == 1){
        [MobClick event:@"导航分类"];
    }else if(self.selectedIndex == 2){
        [MobClick event:@"导航闪电下单"];
    }else if(self.selectedIndex == 3){
        [MobClick event:@"导航购物车"];
    }else if(self.selectedIndex == 4){
        [MobClick event:@"导航我的"];
    }
    
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        UIViewController * vc = [((UINavigationController *)viewController).viewControllers firstObject];
        if ([vc isKindOfClass:NSClassFromString(@"PSShoppingCartViewController")])   // 购物车
        {
            // 根据token 判断是否登陆
            NSString *token = [[AccountManager sharedInstance] fetchAccessToken];
            if (!token || [token isEmpty]) {
                selectFlag = NO;

                // 直接跳转到登录界面
                PSLoginViewController * loginVC = [[PSLoginViewController alloc] init];
                loginVC.hidesBottomBarWhenPushed = YES;
                loginVC.loginSuccess = ^(){
                    self.selectedIndex = 3; // 选中购物车
                };
                [(UINavigationController *)self.selectedViewController pushViewController:loginVC animated:YES];

                // 先提示，再跳转
//                NSString * alertMsg = @"未登录，请登录";
//                UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
//                [alertVC addAction:[UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                    PSLoginViewController * loginVC = [[PSLoginViewController alloc] init];
//                    loginVC.hidesBottomBarWhenPushed = YES;
//                    loginVC.loginSuccess = ^(){
//                        self.selectedIndex = 3; // 选中购物车
//                    };
//                    [(UINavigationController *)self.selectedViewController pushViewController:loginVC animated:YES];
//                }]];
//                [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//                [self.selectedViewController presentViewController:alertVC animated:YES completion:nil];
            }
            
        }
    }
    
    return selectFlag;
}

-(NSString *)dealVersionString:(NSString *)versionString {
    NSArray  *dealStringArray = [versionString componentsSeparatedByString:@"."];

    if (dealStringArray.count <=1 ) {
        return versionString;
    }
    NSMutableString *returnString  = [NSMutableString stringWithFormat:@"%@.%@",dealStringArray[0],dealStringArray[1]];
    
    return  returnString;
}



@end
