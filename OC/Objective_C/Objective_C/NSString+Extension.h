//
//  NSString+Extension.h
//  qianjituan2.0
//
//  Created by wlg on 5/27/16.
//  Copyright © 2016 ios-mac. All rights reserved.
//
//  NSString扩展

#import <Foundation/Foundation.h>

@interface NSString (Extension)


/**
 *  字符串 size计算
 *
 *  @param font    字体
 *  @param maxSize 最大尺寸
 *  @param lineMargin 行间距
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize lineMargin:(CGFloat)lineMargin;



/**
 *  是否为空 的判断
 */
- (BOOL)isEmpty;





//TODO 可以考拉将正则部分单独再提取个NSString+Match/Regex的分类
#pragma mark - 正则表达式部分  


/** 
 *  是否符合某种正字表达式 
 */
- (BOOL)isMatchRegex:(NSString *)regex;

/**
 *  电话号码判断
 */
- (BOOL)isPhoneNumber;

/**
 *  身份证号判断
 */
- (BOOL)isIdentityForChina;




#pragma mark - 加密部分

/** md5 */
- (NSString *)md5String;
+ (NSString *)md5ForString:(NSString *)string;


/** DES加解密 */
+ (NSString *)encryptDESForString:(NSString *)strOrigin key:(NSString *)key;
+ (NSString *)decryptDESWithString:(NSString*)strDES key:(NSString*)key;













@end
