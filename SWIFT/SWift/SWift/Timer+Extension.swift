//
//  Timer+Extension.swift
//  Swift
//
//  Created by 王留根 on 16/10/30.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import UIKit

extension Timer {
    
    func pauseTimer() {
        if self.isValid {
            self.fireDate = Date.distantFuture
        }
    }
    
    func resumeTimer() {
        if self.isValid {
            self.fireDate = Date()
        }
    }
    
    func resumeTimerAfterInterval(_ interval: TimeInterval ) {
        if self.isValid {
            self.fireDate = Date(timeIntervalSinceNow: interval)
        }
    }
    
}
