//
//  BarAndScatterCPView.h
//  BIChart
//
//  Created by 健 王 on 12-10-8.
//  Copyright (c) 2012年 Wei Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYChartCPView.h"
#import "ScatterChartCPView.h"

@interface BarAndScatterCPView : XYChartCPView<CPTBarPlotDataSource, CPTBarPlotDelegate,CPTScatterPlotDataSource, CPTScatterPlotDelegate>
{
    NSInteger selectPlotType;
    NSTimer *_animationTimer;
}

@property (assign, nonatomic) double barWidth;
@property (assign, nonatomic) double barInitX;
@property (assign, nonatomic) BOOL colorfulBar;

@property(assign, nonatomic) ScatterChartFillStyle fillStyle;
@property(assign, nonatomic) double symbolSize;
@property(assign, nonatomic) double scatterInitX;
@property(assign, nonatomic) CPTPlotSymbolType symbolType;

@end
