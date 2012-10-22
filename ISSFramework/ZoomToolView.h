//
//  ZoomToolView.h
//  IPChartDemo
//
//  Created by ISS on 11/09/12.
//  Copyright (c) 2012 __iSoftStone__. All rights reserved.
//

// SYSTEM INCLUDES
#import <UIKit/UIKit.h>

#import "ZoomToolBar.h"

typedef enum{
    UITipViewMaskLeftMode,
    UITipViewMaskRightMode
} UITipViewMaskMode;

@interface ZoomToolView : UIView

@property (strong, nonatomic) ZoomToolBar *zoomBar; // 放大镜
@property (strong, nonatomic) UIView *tipView; // 指示信息框
@property (assign, nonatomic) CGPoint touchPoint; // 放大中心点
@property (readonly, nonatomic) UITipViewMaskMode tipMaskMode; // 提示信息所处位置

@property (strong, nonatomic) UIColor *tipBorderColor; // 提示信息框边框颜色
@property (assign, nonatomic) CGFloat tipBorderWidth; // 提示信息框边框宽度
@property (assign, nonatomic) CGFloat tipCornerRadius; // 提示信息框边框曲率
@end