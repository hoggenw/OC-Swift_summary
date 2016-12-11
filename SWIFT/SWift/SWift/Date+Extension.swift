//
//  Date+Extension.swift
//  SWift
//
//  Created by 王留根 on 16/12/11.
//  Copyright © 2016年 ios-mac. All rights reserved.
//

import Foundation


public extension Date
{
    // 格式化输出时间  使用UTC时区表示时间  如：yyyy-MM-dd HH:mm:ss
    public func string(with format: String, in timeZone: TimeZone? = TimeZone.current) -> String {
        
        let dateFormatter = DateFormatter()
        // 设置 格式化样式
        dateFormatter.dateFormat = format
        // 设置时区
        dateFormatter.timeZone = timeZone
        
        let strDate = dateFormatter.string(from: self)
        return strDate
        
        
        
        
        //        TimeZone.init(secondsFromGMT: 0)
        //        TimeZone.init(identifier: "en_US")
        //        TimeZone.init(abbreviation: "")
        
        //        // 设置 格式化样式
        //        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        //        [dateformatter setDateFormat:format];
        //
        //        //    NSTimeZone *timezone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        //        NSTimeZone *timezone = [NSTimeZone systemTimeZone];
        //        [dateformatter setTimeZone:timezone];
        //
        //        // 设置 时区
        //        //    [dateformatter setLocale:[NSLocale currentLocale]];
        //        //    [dateformatter setLocale:[NSLocale currentLocale]];
        //        //    [dateformatter setTimeZone:[NSTimeZone systemTimeZone]];
        //        //    [dateformatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        //        
        //        NSString *strFormResult = [dateformatter stringFromDate:self];
        //        return strFormResult;
    }
}
