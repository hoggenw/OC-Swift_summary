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
