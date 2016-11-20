//
//  Dictionary+Extension.swift
//  千机团Swift
//
//  Created by 王留根 on 16/11/8.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func changedToString()-> String {
        var needString:String? = ""
        var count : Int = 0
        for (key,name) in self {
            count = count+1
            if count == self.keys.count {
               needString = needString?.appending("\(key) : \(name) }")
            }else if count == 1{
               needString = needString?.appending("{ \(key) : \(name) ,")
            }else{
               needString = needString?.appending(" \(key) : \(name) ,")
            }
            
        }
        
        return needString!
    }
    
}
