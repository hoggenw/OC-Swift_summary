//
//  CommonUtils.swift
//
//
//  Created by 王留根 on 16/10/31.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import UIKit
import Kingfisher


class PSCommonUtils: NSObject {
    
    
    //MARK:制作纯色图片
    class func imageWithColor(color: UIColor) -> UIImage{
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
    
    
    //MARK:图片缓存机制实现
    class func judgeCacheRefreshWith(urlString: String,imageView :UIImageView){
        //缓存路径
        let imageCache = ImageCache(name: "myImageSpace")
        
        imageView.image  = imageCache.retrieveImageInDiskCache(forKey: urlString)
        print("\(imageView.image)")
        //判断是否存在缓存
        if imageView.image == nil {
            KingfisherManager.shared.downloader.downloadImage(with: URL(string: urlString)!, options: nil, progressBlock: {(receivedSize, totalSize) in
                
                
            }, completionHandler: {(_ image: Image?, _ error: NSError?, _ url: URL?, _ originalData: Data?) in
                
                guard image != nil else {
                    print("获取图片失败")
                    return
                }
                //存入本地磁盘
                imageCache.store(image!, forKey: urlString)
                print("获取图片成功")
                //返回数据
                imageView.image = image!
                
            })
            
        }
        
        
    }
    
    //MARK:上传日志
    class func updateLog(ifBegin:Bool,timeInterVal: Int64?) {
        var params : [String :String] = [:]
        params["VisitIP"] = PSCommonUtils.getIPAddress()
        
        params["VisitStation"] = ifBegin ? " " : PSAccountManager.accountManager.fetchPSAreaModel().name
        //params ["Times"] = "0"
        params ["Source"] = "2"
        let userDef = UserDefaults.standard
        let cityName = (userDef.object(forKey: "locationCityName")) != nil ? userDef.object(forKey: "locationCityName") as! String : ""
        params ["Area"] = cityName.characters.count > 0 ? cityName : " "
        params ["Device"] = PSCommonUtils.getUUID()
        params ["Times"] = timeInterVal == nil ? "0" : String(format: "%ld", timeInterVal!)
        
        guard (PSAccountManager.accountManager.fetch()?.accessToken?.characters.count) != nil else {
            params["UserId"] = " "
            
            PSNetWorkManager.postWithMethod(method:"UserCareInfo.AddVisitLog" , params: params as [String : AnyObject], success:{(response) in
                print("日志上传 ：成功")
                
            },failure: {(response) in
                print("日志上传 ：失败\(response)")
                
            }, error: {(response) in
                print("日志上传 ：错误\(response)")
                
            }, showMsg: true)
            
            return
            
        }
        params["UserId"] = PSAccountManager.accountManager.fetch()?.accessToken
        
        PSNetWorkManager.postWithMethod(method:"UserCareInfo.AddVisitLog" , params: params as [String : AnyObject], success:{(response) in
            print("日志上传 ：成功")
            
        },failure: {(response) in
            print("日志上传 ：失败\(response)")
            
        }, error: {(response) in
            print("日志上传 ：错误\(response)")
            
        }, showMsg: true)
        
        
        
    }
    
    //MARK:获取本机ip
    class func getIPAddress() ->String {
        var addresses = "error"
        
        // Get list of all interfaces on the local machine:
        var ifaddr :  UnsafeMutablePointer<ifaddrs>? = nil
        var temp_addr :  UnsafeMutablePointer<ifaddrs>? = nil
        var success :Int = 0
        success = Int(getifaddrs(&ifaddr))
        if success == 0 {
            temp_addr = ifaddr
            while temp_addr != nil {
                if (Int32((temp_addr?.pointee.ifa_addr.pointee.sa_family)!) == AF_INET) {
                    
                    if (String(cString: (temp_addr?.pointee.ifa_name)!, encoding: .utf8) == "en0") {
                        
                        let fucn = ((temp_addr?.pointee.ifa_addr.pointee.sa_data)?.2)! < 0 ? -((temp_addr?.pointee.ifa_addr.pointee.sa_data)?.2)! : ((temp_addr?.pointee.ifa_addr.pointee.sa_data)?.2)
                        let fucn2 = ((temp_addr?.pointee.ifa_addr.pointee.sa_data)?.3)! < 0 ? -((temp_addr?.pointee.ifa_addr.pointee.sa_data)?.3)! : ((temp_addr?.pointee.ifa_addr.pointee.sa_data)?.3)
                        let foo : UInt8 = UInt8(Int8.max) - UInt8(fucn!) + UInt8(Int8.max) + 2
                        let foo1 : UInt8 = UInt8(Int8.max) - UInt8(fucn2!) + UInt8(Int8.max) + 2
                        let fucn3:UInt8  = UInt8(((temp_addr?.pointee.ifa_addr.pointee.sa_data)?.4)!)
                        let fucn4:UInt8  = UInt8(((temp_addr?.pointee.ifa_addr.pointee.sa_data)?.5)!)
                        let intString: String = "\(foo):\(foo1):\(fucn3):\(fucn4)"
                        print("intString=\(intString)")
                        
                        addresses = intString
                    }
                    
                }
                
                temp_addr = temp_addr?.pointee.ifa_next
            }
            
            
        }
        // print("ip ==== \(PSCommonUtils.getUUID())")
        
        return addresses
        
    }
    //MARK:获取UUID
    class func getUUID() -> String {
        
        let str = UIDevice.current.identifierForVendor?.uuidString
        return str!
    }
    
    //MARK:alamofire的HTTPS  自签名设置
    func alamofireManagerSet() {
        
        let manager = Alamofire.SessionManager.default
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    credential = manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace)
                    
                    if credential != nil {
                        disposition = .useCredential
                    }
                }
            }
            return (disposition, credential)
        }
        
    }
    
    //MARK:富文本装换
    class func  changeSellPriceToAttributedString(needString:String?,littleFont:UIFont,bigFont:UIFont,color:UIColor) -> NSMutableAttributedString {
        guard needString != nil else {
            return NSMutableAttributedString()
        }
        let attributeString:NSMutableAttributedString = NSMutableAttributedString(string: String(format: "%@", needString!))
        
        
        let rangeBack : NSRange = (attributeString.string as NSString).range(of: needString!)
        attributeString.setAttributes([NSForegroundColorAttributeName:color, NSFontAttributeName:bigFont], range: rangeBack)
        
        let range : NSRange = (attributeString.string as NSString).range(of: "¥")
        attributeString.setAttributes([NSForegroundColorAttributeName:color, NSFontAttributeName:littleFont], range: range)
        
        return attributeString
        
        
        
    }
    func *******weakself在block里面的写法******() {
        bannerScroller?.tapActionBlock = {[weak self](index) in
            if (self?.dataArray[0].count)! > 0 {
                let model = self?.dataArray[0][index]
                MobClick.event("Banner")
                
                if (model?.url?.characters.count)! > 0 {
                    let activeVc = PSActiveWebViewController()
                    activeVc.urlString = model?.url
                    activeVc.hidesBottomBarWhenPushed = true
                    _ = self?.navigationController?.pushViewController(activeVc, animated: false)
                    
                }else{
                    print("商品详情")
                }
            }
            
            
        }
    }
    
    
    
}


































