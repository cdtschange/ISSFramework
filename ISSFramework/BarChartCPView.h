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

@property (assign, nonatomic) double barWidth;
@property (assign, nonatomic) double barInitX;

@property (assign, nonatomic) BOOL colorfulBar;


-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index;


@end
