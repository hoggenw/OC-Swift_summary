//
//  PSVerifyCodeButton.h
//  qianjituan2.0
//
//  Created by 小唐 on 6/22/16.
//  Copyright © 2016 ios-mac. All rights reserved.
//
//  验证码按钮

#import <UIKit/UIKit.h>

@interface VerifyCodeButton : UIButton

/** 显示指定的验证码 */
- (void)showVerifyCode:(nonnull NSString *)verifyCode;

@end
