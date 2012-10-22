//
//  XYChartCPViewController.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/24/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "ChartCPBaseView.h"

@interface XYChartCPView : ChartCPBaseView<CPTPlotSpaceDelegate>

@property (assign, nonatomic) double xAxisMax; // max value
@property (assign, nonatomic) double xAxisMin; // min value
@property (assign, nonatomic) double yAxisMax; // max lalue
@property (assign, nonatomic) double yAxisMin; // min value
@property (assign, nonatomic) double xRangValue; 
@property (assign, nonatomic) double axisTitleFontSize; // title text font size
@property (assign, nonatomic) double xAxisTitleOffset; // title offset default 25.0
@property (assign, nonatomic) double yAxisTitleOffset; // title offset default 35.0
@property (assign, nonatomic) double axisLineWidth; // axis line width default 2.0
@property (assign, nonatomic) CPTColor *axisLineColor; // axis line color default black
@property (strong, nonatomic) NSString *xAxisTitle; // x axis title
@property (strong, nonatomic) NSString *yAxisTitle; // y axis title
@property (assign, nonatomic) double doubleClickScaleDefaultValue; // default 2.0

/**
 X轴显示标签
 @param policy x轴样式
 @param newAxisLabels 标签数据
 */
- (void)setAxis:(CPTAxisLabelingPolicy)policy axisLabels:(NSMutableSet*)newAxisLabels;

@end
