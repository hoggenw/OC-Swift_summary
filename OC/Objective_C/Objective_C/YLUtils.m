//
//  YLUtils.m
//  Objective_C
//
//  Created by 王留根 on 16/11/3.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

#import "YLUtils.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation YLUtils


+ (NSString *)encryptDESForString:(NSString *)strOrigin key:(NSString *)key
{
    //    return nil;
    
    return [self encrypt:strOrigin encryptOrDecrypt:kCCEncrypt key:key];
    

    
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

/**
 *  将富文本转换成HTML
 *  added by dwk
 */
+ (NSString *)psk_converRichTextToHTML:(NSAttributedString *)attributedString {
    NSDictionary *exportParams = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSData *htmlData = [attributedString dataFromRange:NSMakeRange(0, attributedString.length) documentAttributes:exportParams error:nil];
    return [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
}

@end
