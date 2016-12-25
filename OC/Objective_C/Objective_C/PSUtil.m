//
//  PSUtil.m
//  wlg
//
//  Created by wlg on 6/23/16.
//  Copyright © 2016 ios-mac. All rights reserved.
//

#import "PSUtil.h"
#import "PSShareShowView.h"

#import <ShareSDK/ShareSDK+Base.h>
//获取ip
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"



#define IPHONE6_SIZE CGSizeMake(375, 667)
@implementation PSUtil

// 带确定按钮的提示框
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    // show alertVC
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alertVC animated:YES completion:nil];
}


//  带确定按钮的提示框 可响应
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message clickAction:(void(^)())clickAction;
{
    // show alertVC
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (clickAction) {
            clickAction();
        }
    }]];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alertVC animated:YES completion:nil];
}


//  带左右按钮的提示框
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message leftTitle:(NSString *)leftTitle leftClickAction:(void(^)())leftClickAction rightTitle:(NSString *)rightTitle rightClickAction:(void(^)())rightClickAction
{
    // show alertVC
    UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:leftTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (leftClickAction) {
            leftClickAction();
        }
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:rightTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (rightClickAction) {
            rightClickAction();
        }
    }]];
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alertVC animated:YES completion:nil];
}


+ (void)getKeyboardToolbar:(UIToolbar **)kbToolbar doneBtn:(UIButton **)doneBtn;
{
    // toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    toolbar.tintColor = [UIColor blueColor];
    toolbar.backgroundColor = [UIColor lightGrayColor];
    
    // doneBtn
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [toolbar addSubview:button];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button setTitleColor:[[PSTheme sharedInstance] tintColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [button setContentEdgeInsets:UIEdgeInsetsMake(5, 10, 5, 10)];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(toolbar).offset(-10);
        make.centerY.equalTo(toolbar);
    }];
    
    *kbToolbar = toolbar;
    *doneBtn = button;
}

+ (void)showBankShare
{
    PSShareShowView *showView = [PSShareShowView showView];
    [[UIApplication sharedApplication].keyWindow addSubview:showView];
    [showView bankShare];
}

+ (void)showBankShareWithTitle:(NSString *)title text:(NSString *)text strUrl:(NSString *)strUrl
{
    UIImage *image = [UIImage imageNamed:@"Icon-Logo-Login"];
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:text
                                     images:@[image]
                                        url:[NSURL URLWithString:strUrl]
                                      title:title
                                       type:SSDKContentTypeAuto];
    
    [ShareSDK showShareActionSheet:nil
                             items:@[@(SSDKPlatformSubTypeQQFriend), @(SSDKPlatformSubTypeWechatSession)]
                       shareParams:shareParams
               onShareStateChanged:^(
                                     SSDKResponseState state,
                                     SSDKPlatformType platformType,
                                     NSDictionary *userData,
                                     SSDKContentEntity *contentEntity,
                                     NSError *error,
                                     BOOL end)
     {   
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 
             }
                 break;
             case SSDKResponseStateFail:
             {
                 UIAlertView* alert =
                 [[UIAlertView alloc]initWithTitle: [error description]
                                           message: nil
                                          delegate: nil
                                 cancelButtonTitle: @"关闭"
                                 otherButtonTitles: nil];
                 
                 [alert show];
                 
                 
             }
                 break;
             default:
                 break;
         }
     }];
    
}

//分享
+(void)showShareContextByText:(NSString *)text images:(NSArray<UIImage *>*)imageArray url:(NSURL *)urlString title:(NSString *)title type:(SSDKContentType) SSDKType {
    
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    
    [shareParams SSDKSetupShareParamsByText:text
                                     images:imageArray
                                        url:urlString
                                      title:title
                                       type:SSDKType];
    
    [ShareSDK showShareActionSheet:nil
                             items:nil
                       shareParams:shareParams
               onShareStateChanged:^(
                                     SSDKResponseState state,
                                     SSDKPlatformType platformType,
                                     NSDictionary *userData,
                                     SSDKContentEntity *contentEntity,
                                     NSError *error,
                                     BOOL end)
     {
         //微信朋友圈和微信收藏
         if (platformType == SSDKPlatformSubTypeWechatTimeline|| platformType == SSDKPlatformSubTypeWechatFav) {
             [shareParams SSDKSetupShareParamsByText:text
                                              images: imageArray
                                                 url: urlString
                                               title: title
                                                type: SSDKType];
         }
         
         if(platformType == SSDKPlatformTypeSinaWeibo){
             [shareParams SSDKSetupShareParamsByText: text
                                              images: imageArray
                                                 url: urlString
                                               title: title
                                                type: SSDKType];
         }
         
         switch (state)
         {
             case SSDKResponseStateSuccess:
             {
                 //                         UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"分享成功" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                 //                         [alert show];
                 
                 
             }
                 break;
             case SSDKResponseStateFail:
             {
                 UIAlertView* alert =
                 [[UIAlertView alloc]initWithTitle: [error description]
                                           message: nil
                                          delegate: nil
                                 cancelButtonTitle: @"关闭"
                                 otherButtonTitles: nil];
                 
                 [alert show];
                 
                 
             }
                 break;
             default:
                 break;
         }
     }];
    
    
}


+(CGFloat)returnProportion:(CGFloat) height{
    return MAIN_SCREEN_WIDTH/IPHONE6_SIZE.width * height;
}

//上传日志
+ (void)getLog:(NSMutableDictionary *)params {
    
    [NetWorkManager postWithMethod:PSMethod_UserCareInfoAddVisitLog params:params success:^(id  _Nullable responseObject) {
        NSLog(@"日志上传：成功");
        
    } failure:^(id  _Nullable responseObject) {
        NSLog(@"日志上传：失败：%@",responseObject);
    } error:^(NSError * _Nonnull error) {
        NSLog(@"日志上传：错误：%@",error);
    } showMsg:NO];
    
}



//iphone获取本机IP
+ (NSString *)getIPAddresses {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
// 通过UMeng集成的相关方法获取设备唯一编号

+ (NSString *)getUDID {
     Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
     NSString *deviceID = @"";
    if(cls && [cls respondsToSelector:deviceIDSelector]) {
      deviceID = [cls performSelector:deviceIDSelector];
    }
    if ([deviceID isKindOfClass:[NSString class]] && deviceID.length > 0) {
        return deviceID;
    }else {
        return @"";
    }
    
}
//获取系统版本号是否是9以上
+ (BOOL)getIOSVersion
{
    return ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9);
}

#pragma mark - https实验=======
+(void)connectJudge {
    if([[[UIDevice currentDevice] systemVersion] floatValue] < 9){
        NSURLRequest *failedRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://sslapi.qjt1000.com/rest"]];
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:failedRequest delegate:self];
        [urlConnection start];
    }
}

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
       // NSLog(@"self.failedRequest.URLt=%@",self.failedRequest.URL);
        //NSLog(@"trusting connection to host %@", challenge.protectionSpace.host);
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        
        
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response {
    [connection cancel];
    
}
@end
