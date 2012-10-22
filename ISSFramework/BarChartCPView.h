//
//  BarChartCPViewController.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "XYChartCPView.h"
#import "CPTValueTipRectLayer.h"


@interface BarChartCPView : XYChartCPView<CPTBarPlotDataSource, CPTBarPlotDelegate>

@property (assign, nonatomic) double barWidth; // 柱状体宽度
@property (assign, nonatomic) double barInitX; // 柱状体间隔
@property (assign, nonatomic) BOOL colorfulBar; // 是否颜色填充

@end
