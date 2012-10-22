//
//  ScatterChartCPViewController.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "XYChartCPView.h"

typedef enum {
    ScatterChartNone,
    ScatterChartGradientFill,
    ScatterChartFullFill
} ScatterChartFillStyle;

@interface ScatterChartCPView : XYChartCPView<CPTScatterPlotDataSource, CPTScatterPlotDelegate>

@property(assign, nonatomic) ScatterChartFillStyle fillStyle; // 曲线图填充样式
@property(assign, nonatomic) double symbolSize; // 曲线图节点大小
@property(assign, nonatomic) CPTPlotSymbolType symbolType; // 曲线图节点样式

@end
