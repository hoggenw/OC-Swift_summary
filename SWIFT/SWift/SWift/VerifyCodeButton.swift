//
//  VerifyCodeButton.swift
//  Swift
//
//  Created by 王留根 on 16/10/27.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import UIKit

class VerifyCodeButton: UIButton {
    
    var verifyCode : String?
    
    func showVerifyCode(code:String){
        self.verifyCode = code;
        self.setNeedsDisplay()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.verifyCode = " "
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //重绘
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let kLineWith = 1.0
        let kLineCount = 6
        self.backgroundColor = UIColor.init(colorLiteralRed: Float(arc4random()%255)/Float(255.0), green: Float(arc4random()%255)/Float(255.0), blue: Float(arc4random()%255)/Float(255.0), alpha: 1.0)
        var point : CGPoint?
        let text :String = String.init(format: "\(self.verifyCode)")

        let cSize: CGSize = "A".size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
        let width = rect.size.width/CGFloat(text.characters.count) - cSize.width
        let hight = rect.size.height - cSize.height
        
        //依次绘制每一个字符，可以设置显示每个字符的字体大小、颜色、样式等
        var pX : CGFloat?
        var pY : CGFloat?
        for index in 0..<text.characters.count {
            pX = CGFloat(arc4random()%UInt32(width)) + rect.size.width/CGFloat(text.characters.count)*CGFloat(index)
            pY = CGFloat(arc4random()%UInt32(hight))
            point = CGPoint(x: pX!, y: pY!)
            let c = text.index(text.startIndex, offsetBy: index)
            let textC :String = String.init(format: "%C", c as! CVarArg)
            let randomFont = UIFont.systemFont(ofSize:CGFloat(arc4random()%5+15))
            textC.draw(at: point!, withAttributes: [NSFontAttributeName:randomFont])

            
        }

        //调用drawRect：之前，系统会向栈中压入一个CGContextRef，调用UIGraphicsGetCurrentContext()会取栈顶的CGContextRef
        let context = UIGraphicsGetCurrentContext()
        context!.setLineWidth(CGFloat(kLineWith));
        
        for _ in 0..<kLineCount {
            let randomCorlor = UIColor.init(colorLiteralRed: Float(arc4random()%255)/Float(255.0), green: Float(arc4random()%255)/Float(255.0), blue: Float(arc4random()%255)/Float(255.0), alpha: 1.0)
            context?.setStrokeColor(randomCorlor.cgColor)
            //起点
            pX = CGFloat(arc4random()%UInt32(rect.size.width))
            pY = CGFloat(arc4random()%UInt32(rect.size.height))
            context?.move(to: CGPoint(x: pX!, y: pY!))
            //终点
            pX = CGFloat(arc4random()%UInt32(rect.size.width))
            pY = CGFloat(arc4random()%UInt32(rect.size.height))
            context?.addLine(to: CGPoint(x: pX!, y: pY!))
            context?.strokePath();
            
        }
        //MARK:获取本机ip
        func getIPAddress() ->String {
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
            
            
            
            print("ip ==== \(addresses)")
            return addresses
            
        }
        
        
        
        
        
    }
       
    

}
