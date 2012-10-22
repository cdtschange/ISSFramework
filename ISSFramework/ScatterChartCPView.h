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

@property(assign, nonatomic) ScatterChartFillStyle fillStyle;
@property(assign, nonatomic) double symbolSize;
@property(assign, nonatomic) CPTPlotSymbolType symbolType;

@end
