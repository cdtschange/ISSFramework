//
//  CPTValueTipRectLayer.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/28/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "CPTLayer.h"

@protocol ValueTipRectLayerDelegate;

typedef enum{
    UIArrowDirectionDown = 0,
    UIArrowDirectionUp = 1,
} UIArrowDirection;

@interface CPTValueTipRectLayer : CPTBorderedLayer

@property (retain, nonatomic) UIColor *borderColor; // 边框颜色
@property (assign, nonatomic) CGFloat borderWidth; // 边框宽度
@property (assign, nonatomic) CGFloat arrowLength; // 箭头长度
@property (assign, nonatomic) id<ValueTipRectLayerDelegate> drawerDelegate;
@property (assign, nonatomic) UIArrowDirection arrowDirection; // 箭头指示方向

/**
 提示信息初始化
 @param newFrame 提示框区域
 @param len 箭头长度
 */
- (id)initWithFrame:(CGRect)newFrame arrowLength:(CGFloat)len;

@end

@protocol ValueTipRectLayerDelegate <NSObject>
@optional
// 绘制内容区域
- (void)drawContentRect:(CPTValueTipRectLayer*)layer context:(CGContextRef)context drawRect:(CGRect)rect;
@end