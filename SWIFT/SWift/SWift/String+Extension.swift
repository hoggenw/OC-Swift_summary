//
//  String+Extension.swift
//  Swift
//
//  Created by 王留根 on 16/10/11.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import Foundation


extension String {
    
    
    func md5String() -> String {
        // md5 加密
        let cStr = self.cString(using: String.Encoding.utf8);
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(cStr!, CC_LONG(lengthOfBytes(using: String.Encoding.utf8)), buffer)
        let md5String = NSMutableString()
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            md5String.appendFormat("%02x", buffer[index])
        }
        free(buffer)
        return String(format: md5String as String)


    }

    //DES加密
    func encryptDESForString(key : String) ->String{
       return self.encrypt( encryptOrDecrypt:CCOperation(kCCEncrypt), key: key)
        
    }
    
    func encrypt( encryptOrDecrypt:CCOperation, key : String) ->String {
        //要销毁
        var vplainText :UnsafeMutablePointer<UInt8>?
        var plainTextBufferSize:size_t?
        if encryptOrDecrypt == CCOperation(kCCDecrypt) {
            let decryptData:Data = GTMBase64.decode(self.data(using: .utf8))
            plainTextBufferSize = decryptData.count
            vplainText = UnsafeMutablePointer<UInt8>.allocate(capacity: decryptData.count)
            decryptData.copyBytes(to: vplainText!, count:plainTextBufferSize! )
        }else {
            let decryptData:Data = self.data(using: .utf8)!
            plainTextBufferSize = decryptData.count
             vplainText = UnsafeMutablePointer<UInt8>.allocate(capacity: decryptData.count)
            decryptData.copyBytes(to: vplainText!, count:plainTextBufferSize! )
        }
        var ccStatus : CCCryptorStatus?
        let bufferSize: size_t = (plainTextBufferSize! + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1)
        //要销毁
        let bufferPtr = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize * (MemoryLayout<CChar>.size ))
        var movedBytes: size_t = 0;
        memset(bufferPtr, 0x0, bufferSize)
        let iv:[Int] = [Int(0xef), Int(0x34), Int(0x56), Int(0x78), Int(0x90), Int(0xab), Int(0xcd), Int(0xef)]
        var keyString : ContiguousArray = key.utf8CString
        
        ccStatus = CCCrypt(encryptOrDecrypt, CCAlgorithm(kCCAlgorithmDES), CCOptions(kCCOptionPKCS7Padding), &keyString, keyString.count, iv, vplainText, plainTextBufferSize!, bufferPtr, bufferSize, &movedBytes)
        
        var result:String?
        
        if encryptOrDecrypt == CCOperation(kCCDecrypt) {
            
            result = String.init(data: Data.init(bytes: bufferPtr, count: movedBytes), encoding: .utf8)
            
        }else{
            let data = Data.init(bytes: bufferPtr, count: movedBytes)
            result = GTMBase64.string(byEncoding: data)
        }
        print("\(ccStatus)")
        vplainText = nil
        bufferPtr.deallocate(capacity: bufferSize * (MemoryLayout<CChar>.size ))
        
        return result!
        
    }
    
    func isPhoneNumber()  -> Bool{
        let regex = "^1\\d{10}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        let  ifTrue:Bool = pred.evaluate(with: self)
        return ifTrue
        
        
    }

    
}

























