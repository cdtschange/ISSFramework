//
//  ZoomToolBar.h
//  IPChartDemo
//
//  Created by ISS on 11/09/12.
//  Copyright (c) 2012 __iSoftStone__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomToolBar : UIView

@property (assign, nonatomic) CGFloat scaleX; // 放大镜X轴放大倍数
@property (assign, nonatomic) CGFloat scaleY; // 放大镜Y轴放大倍数
@property (assign, nonatomic) CGPoint touchPoint; // 放大中心点
@property (assign, nonatomic) UIView *hostView; // 放大视图

@end
