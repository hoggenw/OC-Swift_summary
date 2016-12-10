//
//  Array+Extension.swift
//  SWift
//
//  Created by 王留根 on 16/12/9.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import Foundation


extension Array {
    
    func checkOutOfRange(_ index:Int) -> Element? {
        if index >= 0 && index < self.count {
            return self[index]
        }
        return nil
    }
    
    func JSONString() -> String {
        
        if JSONSerialization.isValidJSONObject(self) {
            do {
                let data = try JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                if let string = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch {
                
            }
        }
        return ""
    }
}

