//
//  PSUtil.h
//  
//
//  Created by wlg on 6/23/16.
//  Copyright © 2016 ios-mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>

@interface PSUtil : NSObject<NSURLConnectionDelegate>

/**
 *  带确定按钮的提示框
 *  显示在keywindow的根控上
 */
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;


/**
 *  带确定按钮的提示框 可响应
 */
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message clickAction:(void(^)())clickAction;


/**
 *  带左右按钮的提示框
 *
 *  @param title            提示标题
 *  @param message          提示信息
 *  @param leftTitle        左侧按钮标题
 *  @param leftClickAction  左侧按钮点击响应
 *  @param rightTitle       右侧按钮标题
 *  @param rightClickAction 右侧按钮点击响应
 */
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message leftTitle:(NSString *)leftTitle leftClickAction:(void(^)())leftClickAction rightTitle:(NSString *)rightTitle rightClickAction:(void(^)())rightClickAction;



/**
 *  用于给键盘的inputAccessaryView设置toolBar，并添加完成按钮
 *
 *  @param kbToolbar 用于键盘的inputAccessaryView
 *  @param doneBtn   完成按钮，其响应需自己完成
 */
+ (void)getKeyboardToolbar:(UIToolbar **)kbToolbar doneBtn:(UIButton **)doneBtn;


//日志收集

+ (void)getLog:(NSMutableDictionary *)params;



//获取Ip地址
+ (NSDictionary *)getIPAddresses;


// 通过UMeng集成的相关方法获取设备唯一编号

+ (NSString *)getUDID;








/**
 *  分享需要传入参数
 *
 *  @param text       分享显示的内容
 *  @param imageArray 图片
 *  @param urlString  分享的链接
 *  @param title      分享的title
 *  @param SSDKType   分享模式（一般选择自动 0）
 */

+(void)showShareContextByText:(NSString *)text images:(NSArray<UIImage *>*)imageArray url:(NSURL *)urlString title:(NSString *)title type:(SSDKContentType) SSDKType;

/**
 *  自定义UI方式实现分享
 */
+ (void)showBankShare;
/**
 *  使用系统自带的方式实现分享
 */
+ (void)showBankShareWithTitle:(NSString *)title text:(NSString *)text strUrl:(NSString *)strUrl;



/**
 *  按照6的=尺寸返回高度
 *
 *  @param height 传入高度
 *
 *  @return 现在屏幕需要高度
 */
+(CGFloat)returnProportion:(CGFloat) height;


//获取系统版本号
+ (BOOL)getIOSVersion;

//HTTPS信任
+(void)connectJudge;


@end
