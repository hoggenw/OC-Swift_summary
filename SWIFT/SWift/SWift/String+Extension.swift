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

    subscript (r: Range<Int>) -> String {
        get {
            return substring(with: r)
        }
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    var md5:String {
        let str = cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
    
    public func sizeRect(size:CGSize,font:UIFont) -> CGSize {
        let str = self as NSString
        let size = str.boundingRect(with: size,options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin),attributes: [NSFontAttributeName:font], context: nil).size
        return size
    }
    
    
    func size(_ maxSize: CGSize, _ font: UIFont, _ lineMargin: CGFloat) -> CGSize {
        
        let options: NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineMargin // 行间距
        
        var attributes = [String : Any]()
        attributes[NSFontAttributeName] = font
        attributes[NSParagraphStyleAttributeName] = paragraphStyle
        
        let str = self as NSString
        let textBounds = str.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        
        return textBounds.size
    }
    
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    func totalPriceJudge() ->String {
        var str = String(format: "%.2f", self.toFloatValue()!)
        
        if str.hasSuffix("00") {
            
            str = str.substring(to: str.characters.count - 3)
        }else if str.hasSuffix("0"){
            str = str.substring(to: str.characters.count - 1)
        }
        return str
        
    }
    //MARK:字符串替代
    func replaceString()->String {
        let range : NSRange = (self as NSString).range(of: ".")
        
        var firstString  = range.location != NSNotFound ? (self as NSString).components(separatedBy: ".").first :self
        
        if firstString?.characters.count == 11 {
            let nsrange = NSRange.init(location: 3, length: 4)
            return (self as NSString).replacingCharacters(in: nsrange, with: "****") as String
            
        }else if (firstString?.characters.count)! >= 5 && (firstString?.characters.count)! != 11 {
            let nsrange = NSRange.init(location: 1, length: 2)
            return (self as NSString).replacingCharacters(in: nsrange, with: "**") as String
        }else if (firstString?.characters.count)! >= 3 && (firstString?.characters.count)! < 5 {
            let nsrange = NSRange.init(location: 1, length: 1)
            return (self as NSString).replacingCharacters(in: nsrange, with: "*") as String
        }else if (firstString?.characters.count)! >= 1 && (firstString?.characters.count)! < 3 {
            let nsrange = NSRange.init(location: 0, length: 1)
            return (self as NSString).replacingCharacters(in: nsrange, with: "*") as String
        }
        
        return self
        
    }
    //utf8编码
    func utf8encodedString() ->String {
         return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
    
    func navigationBarNeedChanged() {
        UIView.animate(withDuration: 0.2, animations:{ [weak self]() in
            UIApplication.shared.statusBarStyle = .lightContent
            self?.topImageView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
            self?.topImageView.image =  UIImage(named:"ss")
            
            self?.messageButton.setImage( UIImage(named: (PSCommonUtils.ifMeiQiaNewMessage() ? "icon_message_b" :"01-alert")), for: .normal)
            
            self?.searchButton.setImage( UIImage(named:"01-seach"), for: .normal)
            self?.titleLog.image = UIImage(named:"01-logo")
            self?.cityButton.setImage(UIImage(named: "01-pulldown"), for: .normal)
            self?.cityButton.setTitleColor(UIColor.blue, for: .normal)
            
            
        })
        
        
        
    }
    
}

























