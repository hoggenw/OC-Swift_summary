//
//  RegularExpressionsBySyc.h
//  正则
//
//  Created by 彦 on 17/3/26.
//  Copyright © 2017年 com.pbph. All rights reserved.
//

/**********     方法一览表    **********/
/*
 *  验证银行卡号是否正确
 *  车牌号验证
 *  检验邮箱地址是否正确
 *  手机号中间四位密文显示
 *  判断QQ号是否正确(5-11位)
 *  判断身份证号是否正确(如末位为字母请用“x”代替)
 *  判断全字母
 *  判断仅输入字母或数字
 *  判断密码是否同时包含大小写字母和数字(6-18位,可输入符号)
 *  替换字符串重复内容(可作为去重使用)
 *  判断字符串中是否为纯阿拉伯数字组成-字符传长度不限
 *  仅能输入中文
 *  判断字符串中是否包含汉字
 */



#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, FirstLetterType) {
    Zero_Allow = 0,
    Zero_NotAllow = 1
};
@interface RegularExpressionsBySyc : NSObject

/**
 判断银行卡号
 
 @param cardNo 传入值
 @return 返回值
 */
+(BOOL) checkBankCardNumber:(NSString*)cardNo;

/**
 车牌号验证
 
 @param carNo 传入值
 @return 返回值
 */
+ (BOOL)validateCarNo:(NSString *)carNo;


/**
 检验邮箱地址是否正确
 
 @param email 传入值
 @return 返回值
 */
+(BOOL)isRightEmail:(NSString *)email;


/**
 手机号中间四位密文显示
 
 @param phoneNumber 传入值
 @return 返回值
 */
+(NSString *)replaceThe4NumOfPhoneNumber:(NSString*)phoneNumber;

/**
 判断QQ号是否正确(5-11为位)
 
 @param qqNum 传入值
 @return 返回值
 */
+(BOOL)isCorrectAQQNumber:(NSString *)qqNum;

/**
 判断身份证号是否正确(如末位为字母请用“x”代替)

 @param idCardString 传入值
 @return 返回值
 */
+(BOOL)isIDCardNumComplyWithTheRules:(NSString *)idCardString;


/**
 判断全字母
 
 @param string 传入值
 @return 返回值
 */
+(BOOL)deptPassInputShouldAlpha:(NSString *)string;

/**
 判断仅输入字母或数字

 @param string 传入值
 @return 返回值
 */
+(BOOL) deptIdInputShouldAlphaNum:(NSString *)string;

/**
 判断密码是否同时包含大小写字母和数字(6-18位),可输入符号

 @param password 密码
 @return 校验结果
 */
+(BOOL)isPasswordContainsBigSmallNumber:(NSString *)password;


/**
 替换字符串重复内容(可作为去重使用)

 @param sourceString 数据源
 @param toString 目标数据
 @return 返回值
 */
+(NSString *)sourceString:(NSString *)sourceString toString:(NSString *)toString;

/**
 判断字符串中是否为纯阿拉伯数字组成-字符传长度不限

 @param string 传入值
 @param tpye 首字母是否允许为0
 @return 返回值
 */
+(BOOL)isOnlyArabicNumeralInTheString:(NSString *)string FirstLetterType:(FirstLetterType)tpye;



/**
 仅能输入中文

 @param string 传入值
 @return 返回值
 */
+(BOOL)deptNameInputShouldChinese:(NSString *)string;

/**
 判断字符串中是否包含汉字

 @param string 传入值
 @return 返回值
 */
+(BOOL)isChineseRangeOfString:(NSString *)string;

@end
