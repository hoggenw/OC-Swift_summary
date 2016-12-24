//
//  NSString+Extension.m
//  qianjituan2.0
//
//  Created by wlg on 5/27/16.
//  Copyright © 2016 ios-mac. All rights reserved.
//

#import "NSString+Extension.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+Base64.h"

@implementation NSString (Extension)

/**
 *  字符串 size计算
 *
 *  @param font    字体
 *  @param maxSize 最大尺寸
 *  @param lineMargin 行间距
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize lineMargin:(CGFloat)lineMargin
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineMargin;    // 行间距
    
    NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    CGRect textBounds = [self boundingRectWithSize:maxSize options:options attributes:attributes context:nil];
    
    return textBounds.size;
}


/**
 *  是否为空 的判断
 */
- (BOOL)isEmpty
{
    BOOL emptyFlag = NO;
    if (!self) {
        emptyFlag = YES;
    }
    else if ([self isEqual:[NSNull null]]) {
        emptyFlag = YES;
    }
    else if (0 == self.length) {
        emptyFlag = YES;
    }
    
    return emptyFlag;
}



/**
 *  是否符合某种正字表达式
 */
- (BOOL)isMatchRegex:(NSString *)regex
{
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    return isMatch;
}

/**
 *  电话号码判断
 */
- (BOOL)isPhoneNumber
{
    NSString * regex = @"^1\\d{10}$";
    return [self isMatchRegex:regex];
}

/**
 *  身份证号判断
 */
- (BOOL)isIdentityForChina
{
    NSString *regex = @"^(\\d{15}$|^\\d{18}$|^\\d{17}(\\d|X|x))$";
    return [self isMatchRegex:regex];
}


// md5加密
- (NSString *)md5String
{
    // md5 加密
    const char * str = self.UTF8String;
    int length = (int)strlen(str);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, length, bytes);
    
    NSMutableString *md5String = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [md5String appendFormat:@"%02X", bytes[i]];
    }
    
    return [md5String lowercaseString];
}
+ (NSString *)md5ForString:(NSString *)string
{
    return [string md5String];
}



+ (NSString *)encryptDESForString:(NSString *)strOrigin key:(NSString *)key
{
//    return nil;
    
    return [self encrypt:strOrigin encryptOrDecrypt:kCCEncrypt key:key];
    
//    NSString *ciphertext = nil;
//    NSData *textData = [strOrigin dataUsingEncoding:NSUTF8StringEncoding];
//    NSUInteger dataLength = [textData length];
//    unsigned char buffer[1024];
//    //const Byte iv[] = {1,2,3,4,5,6,7,8};
//    char iv[8] = {(char)0xef, (char)0x34, (char)0x56, (char)0x78, (char)0x90, (char)0xab, (char)0xcd, (char)0xef};
//    memset(buffer, 0, sizeof(char));
//    size_t numBytesEncrypted = 0;
//    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
//                                          kCCOptionPKCS7Padding,
//                                          [key UTF8String], kCCKeySizeDES,
//                                          iv,
//                                          [textData bytes], dataLength,
//                                          buffer, 1024,
//                                          &numBytesEncrypted);
//    if (cryptStatus == kCCSuccess) {
//        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
//        ciphertext = [GTMBase64 encodeBase64Data:data];
//    }
//    return ciphertext;

    
//    NSString *ciphertext = nil;
//    const char *textBytes = [strOrigin UTF8String];
//    NSUInteger dataLength = [strOrigin length];
//    unsigned char buffer[1024];
//    memset(buffer, 0, sizeof(char));
//    //Byte iv[] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};
//    char iv[8] = {(char)0xef, (char)0x34, (char)0x56, (char)0x78, (char)0x90, (char)0xab, (char)0xcd, (char)0xef};
//    size_t numBytesEncrypted = 0;
//    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
//                                          kCCAlgorithmDES,
//                                          kCCOptionPKCS7Padding,
//                                          [key UTF8String],
//                                          kCCKeySizeDES,
//                                          iv,
//                                          textBytes,
//                                          dataLength,
//                                          buffer,
//                                          1024,
//                                          &numBytesEncrypted);
//    if(cryptStatus == kCCSuccess)
//    {
//        NSData *data = [GTMBase64 encodeBytes: buffer length: (NSUInteger)numBytesEncrypted];
////        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
//        ciphertext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    }
//    return ciphertext;
    
    
}

+ (NSString *)decryptDESWithString:(NSString*)strDES key:(NSString*)key
{
//    return nil;
    
    return [self encrypt:strDES encryptOrDecrypt:kCCDecrypt key:key];

}

+ (NSString *)encrypt:(NSString *)sText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOperation == kCCDecrypt)
    {
        NSData *decryptData = [GTMBase64 decodeData:[sText dataUsingEncoding:NSUTF8StringEncoding]];
        plainTextBufferSize = [decryptData length];
        vplainText = [decryptData bytes];
    }
    else
    {
        NSData* encryptData = [sText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [encryptData length];
        vplainText = (const void *)[encryptData bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
//    NSString *initVec = @"init Kurodo";
//    const void *vinitVec = (const void *) [initVec UTF8String];
    char iv[8] = {(char)0xef, (char)0x34, (char)0x56, (char)0x78, (char)0x90, (char)0xab, (char)0xcd, (char)0xef};
    const void *vkey = (const void *) [key UTF8String];
    
    ccStatus = CCCrypt(encryptOperation,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeDES,
//                       vinitVec,
                       iv,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSString *result = nil;
    
    if (encryptOperation == kCCDecrypt)
    {
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding];
    }
    else
    {
        NSData *data = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [GTMBase64 stringByEncodingData:data];
    }
    
    return result;
}

@end
