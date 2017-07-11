//
//  RegularExpressionsBySyc.m
//  正则
//
//  Created by 彦 on 17/3/26.
//  Copyright © 2017年 com.pbph. All rights reserved.
//

#import "RegularExpressionsBySyc.h"

@implementation RegularExpressionsBySyc

#pragma mark - 银行卡号验证
+(BOOL) checkBankCardNumber:(NSString*)cardNo{
    int oddsum = 0;     //奇数求和
    int evensum = 0;    //偶数求和
    int allsum = 0;
    int cardNoLength = (int)[cardNo length];
    int lastNum = [[cardNo substringFromIndex:cardNoLength-1] intValue];
    cardNo = [cardNo substringToIndex:cardNoLength - 1];
    for (int i = cardNoLength -1 ; i>=1;i--) {
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i-1, 1)];
        int tmpVal = [tmpString intValue];
        if (cardNoLength % 2 ==1 ) {
            if((i % 2) == 0){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }else{
            if((i % 2) == 1){
                tmpVal *= 2;
                if(tmpVal>=10)
                    tmpVal -= 9;
                evensum += tmpVal;
            }else{
                oddsum += tmpVal;
            }
        }
    }
    allsum = oddsum + evensum;
    allsum += lastNum;
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}

#pragma mark - 车牌号验证
+ (BOOL) validateCarNo:(NSString *)carNo{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:carNo];
}

#pragma mark - 检验邮箱是否正确
+(BOOL)isRightEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


#pragma mark - 判断是否为正确的QQ号
+(BOOL)isCorrectAQQNumber:(NSString *)qqNum{
    NSString *pattern = @"\\d{5,11}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:qqNum];
    return isMatch;
}

#pragma mark - 手机号中间四位密文显示
+(NSString *)replaceThe4NumOfPhoneNumber:(NSString*)phoneNumber{
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:@"(\\d{3})\\d{4}(\\d{4})"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];
    NSString *resultStr = phoneNumber;
    resultStr = [regExp stringByReplacingMatchesInString:phoneNumber
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, phoneNumber.length)
                                            withTemplate:@"$1****$2"];
    return resultStr;
}

#pragma mark - 判断身份证号是否符合规则
+(BOOL)isIDCardNumComplyWithTheRules:(NSString *)idCardString{
    NSString *pattern = @"(^[0-9]{15}$)|([0-9]{17}([0-9]|x)$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:idCardString];
    return isMatch;
}


#pragma mark - 判断密码是否同时包含大小写字母和数字,可输入符号
+(BOOL)isPasswordContainsBigSmallNumber:(NSString *)password{
    NSString * regex = @"^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{6,18}$";
    NSPredicate * onlyArabicNumeral = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [onlyArabicNumeral evaluateWithObject:password];
    return isMatch;
}

#pragma mark - 替换字符串内容
+(NSString *)sourceString:(NSString *)sourceString toString:(NSString *)toString{
    NSRegularExpression *regExp = [[NSRegularExpression alloc] initWithPattern:@"(.)\\1+"
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:nil];
    NSString *resultStr = sourceString;
    resultStr = [regExp stringByReplacingMatchesInString:sourceString
                                                 options:NSMatchingReportProgress
                                                   range:NSMakeRange(0, sourceString.length)
                                            withTemplate:toString];
    return resultStr;
}

#pragma mark - 判断字符串中是否为纯阿拉伯数字组成-字符传长度不限
+(BOOL)isOnlyArabicNumeralInTheString:(NSString *)string FirstLetterType:(FirstLetterType)tpye{
    switch (tpye) {
        //允许首位为0
        case 0:{
            NSString * regex_0 = @"\\d{1,}";
            NSPredicate * onlyArabicNumeral = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex_0];
            BOOL isMatch = [onlyArabicNumeral evaluateWithObject:string];
            return isMatch;
        }break;
        //不允许首位为0
        case 1:{
            NSString * regex_1 =@"[1-9]\\d{0,}";
            NSPredicate * onlyArabicNumeral = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex_1];
            BOOL isMatch = [onlyArabicNumeral evaluateWithObject:string];
            return isMatch;
        }break;
            
        default:
            break;
    }
}


#pragma mark 仅能输入中文
+(BOOL)deptNameInputShouldChinese:(NSString *)string{
    NSString *regex = @"[\u4e00-\u9fa5]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}


#pragma mark - 判断字符串中是否包含汉字
+(BOOL)isChineseRangeOfString:(NSString *)string{
    NSRange range = [string rangeOfString:@"[\u4e00-\u9fa5]+" options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        //输出包含的汉字是什么
//        NSLog(@"%@", [string substringWithRange:range]);
        return YES;
    }
    return NO;
}

#pragma mark - 判断全字母
+(BOOL)deptPassInputShouldAlpha:(NSString *)string{
    NSString *regex =@"[a-zA-Z]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
    
}

#pragma mark - 判断仅输入字母或数字
+(BOOL) deptIdInputShouldAlphaNum:(NSString *)string{
    NSString *regex =@"[a-zA-Z0-9]+";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}


@end
