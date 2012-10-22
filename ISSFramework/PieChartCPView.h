//
//  PieChartCPViewController.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "ChartCPBaseView.h"

@interface PieChartCPView : ChartCPBaseView<CPTPieChartDataSource,CPTPieChartDelegate>

@property (nonatomic, readonly, strong) CPTPieChart *pieChart;
@property (nonatomic, readonly, strong) CPTLegend *legend;
@property (nonatomic, readwrite, strong) NSArray *legendTextArray;

@end
