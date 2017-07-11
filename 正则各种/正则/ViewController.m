//
//  ViewController.m
//  正则
//
//  Created by 菲 on 17/3/26.
//  Copyright © 2017年 com.pbph. All rights reserved.
//

#import "ViewController.h"
#import "RegularExpressionsBySyc.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //替换字符串内容
    [self replaceStringWithString];
    //判断是否为纯阿拉伯数字
    [self isOnlyArabicNumeralInTheString];
    //判断字符串中是否包含汉字
    [self isChineseRangeOfString];
    //判断是否为纯汉字
    [self deptNameInputShouldChinese];
    //判断全字母
    [self deptPassInputShouldAlpha];
    //判断仅输入字母或数字
    [self deptIdInputShouldAlphaNum];
    //判断身份证号码是否合规
    [self isIDCardNumComplyWithTheRules];
    //判断密码是否同时包含大小写字母和数字
    [self isPasswordContainsBigSmallNumber];
    //判断QQ号是否正确
    [self isCorrectAQQNumber];
    //手机号中间四位密文显示
    [self replaceThe4NumOfPhoneNumber];
    //检验邮箱是否正确
    [self isRightEmail];
    //车牌号验证
    [self validateCarNo];
    //验证银行卡号是否正确
    [self checkBankCardNumber];
}


#pragma mark - RegularExpressionsBySyc
//验证银行卡号是否正确
-(void)checkBankCardNumber{
    if ([RegularExpressionsBySyc checkBankCardNumber:@"请输入卡号"]) {
        NSLog(@"银行卡号正确");
    }else{
        NSLog(@"银行卡号不正确");
    }
}


//车牌号验证
-(void)validateCarNo{
    if ([RegularExpressionsBySyc validateCarNo:@"请输入车牌号码(格式：黑F10823)"]) {
        NSLog(@"车牌号正确");
    }else{
        NSLog(@"车牌号不正确");
    }
}


//检验邮箱是否正确
-(void)isRightEmail{
    if ([RegularExpressionsBySyc isRightEmail:@"请输入邮箱地址"]) {
        NSLog(@"邮箱正确");
    }else{
        NSLog(@"邮箱不正确");
    }
}

//手机号中间四位密文显示
-(void)replaceThe4NumOfPhoneNumber{
    NSLog(@"手机号中间四位密文显示=%@",[RegularExpressionsBySyc replaceThe4NumOfPhoneNumber:@"请输入手机号码"]);
}


//判断QQ号是否正确
-(void)isCorrectAQQNumber{
    if ([RegularExpressionsBySyc isCorrectAQQNumber:@"请输入QQ号"]) {
        NSLog(@"QQ号正确");
    }else{
        NSLog(@"QQ号不正确");
    }
}

//判断密码是否同时包含大小写字母和数字(6-18位,可输入符号)
-(void)isPasswordContainsBigSmallNumber{
    if ([RegularExpressionsBySyc isPasswordContainsBigSmallNumber:@"1234Aelf.**."]) {
        NSLog(@"包含大小写字母和数字");
    }else{
        NSLog(@"不包含大小写字母和数字");
    }
}


//判断身份证号码是否合规
-(void)isIDCardNumComplyWithTheRules{
    /**
     *  用途：判断身份证号码是否合规
     *  参数：末尾如是字母以“x”代替
     */
    if ([RegularExpressionsBySyc isIDCardNumComplyWithTheRules:@"请输入身份证号"]) {
        NSLog(@"身份证号码合规");
    }else{
        NSLog(@"身份证号码不合规");
    }
}


//替换字符串内容(可作为去重使用)
-(void)replaceStringWithString{
    //替换字符串重复内容
    NSLog(@"替换字符串重复内容(去重)=%@",[RegularExpressionsBySyc sourceString:@"abcccddddefffff" toString:@"$1"]);
}

//判断全字母
-(void)deptPassInputShouldAlpha{
    if ([RegularExpressionsBySyc deptPassInputShouldAlpha:@"s1s"]) {
        NSLog(@"全字母");
    }else{
        NSLog(@"非全字母");
    }
}

//判断仅输入字母或数字
-(void)deptIdInputShouldAlphaNum{
    if ([RegularExpressionsBySyc deptIdInputShouldAlphaNum:@"131..."]) {
        NSLog(@"字母或数字");
    }else{
        NSLog(@"非字母或数字");
    }
}

//判断是否为纯阿拉伯数字
-(void)isOnlyArabicNumeralInTheString{
    /**
     *  判断是否为纯阿拉伯数字
     *  允许“0开头”=“Zero_Allow”
     *  不允许“0开头”=“Zero_NotAllow”
     */
    if ([RegularExpressionsBySyc isOnlyArabicNumeralInTheString:@"123456a" FirstLetterType:Zero_Allow]) {
        NSLog(@"纯阿拉伯数字");
    }else{
        NSLog(@"非纯阿拉伯数字");
    }
}

//判断字符串中是否包含汉字
-(void)isChineseRangeOfString{
    /**
     *  用途：
     */
    if ([RegularExpressionsBySyc isChineseRangeOfString:@"hhhsesh哈哈ss"]) {
        NSLog(@"包含汉字");
    }else{
        NSLog(@"不包含汉字");
    }
}
//判断是否为纯汉字
-(void)deptNameInputShouldChinese{
    /**
     *  用途：判断是否为纯汉字
     */
    if ([RegularExpressionsBySyc deptNameInputShouldChinese:@"哈哈s哈哈"]) {
        NSLog(@"纯汉字");
    }else{
        NSLog(@"非纯汉字");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
