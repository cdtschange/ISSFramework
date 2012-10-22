//
//  XYChartCPViewController.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/24/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "ChartCPBaseView.h"

@interface XYChartCPView : ChartCPBaseView<CPTPlotSpaceDelegate>{
    
    BOOL isZoom;
}

@property (assign, nonatomic) double xAxisMax;
@property (assign, nonatomic) double xAxisMin;
@property (assign, nonatomic) double yAxisMax;
@property (assign, nonatomic) double yAxisMin;
@property (assign, nonatomic) double xRangValue;
@property (assign, nonatomic) double axisTitleFontSize;
@property (assign, nonatomic) double xAxisTitleOffset;
@property (assign, nonatomic) double yAxisTitleOffset;
@property (assign, nonatomic) double axisLineWidth;
@property (assign, nonatomic) CPTColor *axisLineColor;
@property (strong, nonatomic) NSString *xAxisTitle;
@property (strong, nonatomic) NSString *yAxisTitle;


@property (assign, nonatomic) double doubleClickScaleDefaultValue;

- (void)setAxis:(CPTAxisLabelingPolicy)policy axisLabels:(NSMutableSet*)newAxisLabels;


@end
