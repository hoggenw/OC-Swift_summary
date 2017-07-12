//
//  Data+Extension.swift
//  SWift
//
//  Created by 王留根 on 2017/7/12.
//  Copyright © 2017年 ios-mac. All rights reserved.
//

import Foundation

extension Data {
    func toDictionary() ->[String : AnyObject]?{
        
        do{
            
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            
            let dic: [String: AnyObject] = json as! [String : AnyObject]
            
            return dic
            
        }catch {
            
            print("失败")
            
            return nil;
            
        }
        
    }
    
}
