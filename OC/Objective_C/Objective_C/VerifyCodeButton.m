//
//  VerifyCodeButton.m
//
//
//  Created by 王留根 on 6/22/16.
//  Copyright © 2016 ios-mac. All rights reserved.
//

#import "VerifyCodeButton.h"

@interface VerifyCodeButton ()

/** 验证码字符串 */
@property (copy, nonatomic) NSString *verifyCode;

@end


@implementation VerifyCodeButton

#pragma mark - public function

// 显示指定的验证码
- (void)showVerifyCode:(nonnull NSString *)verifyCode
{
    NSLog(@"showVerifyCode");
    self.verifyCode = verifyCode;
    [self setNeedsDisplay];
}


#pragma mark - override function

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.verifyCode = @"验证码";
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"drawRect");
    
    [super drawRect:rect];
    
    UIColor *bgRandomColor = [UIColor colorWithRed:arc4random() % 256 / 256.0 green:arc4random() % 256 / 256.0 blue:arc4random() % 256 / 256.0 alpha:1.0];
    const NSInteger kLineCount = 6;
    //const NSInteger kCharCount = 6;
    const CGFloat kLineWidth = 1.0;
    
    //设置随机背景颜色
    self.backgroundColor = bgRandomColor;
    
    //根据要显示的验证码字符串，根据长度，计算每个字符串显示的位置
    NSString *text  =  [NSString stringWithFormat:@"%@", self.verifyCode];
    
    CGSize cSize  =  [@"A" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    
    int width  =  rect.size.width/text.length - cSize.width;
    int height  =  rect.size.height - cSize.height;
    
    CGPoint point;
    
    //依次绘制每一个字符,可以设置显示的每个字符的字体大小、颜色、样式等
    float pX,pY;
    for ( int i  =  0; i<text.length; i++)
    {
        pX  =  arc4random() % width + rect.size.width/text.length * i;
        pY  =  arc4random() % height;
        point  =  CGPointMake(pX, pY);
        
        unichar c  =  [text characterAtIndex:i];
        NSString *textC  =  [NSString stringWithFormat:@"%C", c];
        
        UIFont *randomFont = [UIFont systemFontOfSize:arc4random() % 5 + 15];
        [textC drawAtPoint:point withAttributes:@{NSFontAttributeName : randomFont}];
    }
    
    //调用drawRect：之前，系统会向栈中压入一个CGContextRef，调用UIGraphicsGetCurrentContext()会取栈顶的CGContextRef
    CGContextRef context  =  UIGraphicsGetCurrentContext();
    //设置线条宽度
    CGContextSetLineWidth(context, kLineWidth);
    
    //绘制干扰线
    for (int i  =  0; i < kLineCount; i++)
    {
        UIColor *randomColor = [UIColor colorWithRed:arc4random() % 256 / 256.0 green:arc4random() % 256 / 256.0 blue:arc4random() % 256 / 256.0 alpha:1.0];
        CGContextSetStrokeColorWithColor(context, randomColor.CGColor);//设置线条填充色
        
        //设置线的起点
        pX  =  arc4random() % (int)rect.size.width;
        pY  =  arc4random() % (int)rect.size.height;
        CGContextMoveToPoint(context, pX, pY);
        //设置线终点
        pX  =  arc4random() % (int)rect.size.width;
        pY  =  arc4random() % (int)rect.size.height;
        CGContextAddLineToPoint(context, pX, pY);
        //画线
        CGContextStrokePath(context);
    }
}



@end
