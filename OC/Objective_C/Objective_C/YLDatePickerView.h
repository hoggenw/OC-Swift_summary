//
//  YLDatePickerView.h
//  ftxmall3.0
//
//  Created by 王留根 on 2017/8/29.
//  Copyright © 2017年 FTXMALL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLDatePickerView : UIView

- (instancetype)initDatePackerWithResponse:(void(^)(NSString*))block;

- (void)show;

@end
