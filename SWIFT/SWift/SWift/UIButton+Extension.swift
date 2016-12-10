//
//  UIButton+Extension.swift
//  SWift
//
//  Created by 王留根 on 16/12/10.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import Foundation


public extension UIButton
{
    // MARK: - Initialization Function
    
    public convenience init(title: String?, titleColor: UIColor, font: UIFont) {
        self.init(type: .custom)
        self.setTitle(title, for: .normal)
        self.setTitle(title, for: .selected)
        self.setTitleColor(titleColor, for: .normal)
        self.setTitleColor(titleColor, for: .selected)
        self.titleLabel?.font = font
    }
}
