//
//  PieChartCPViewController.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "ChartCPBaseView.h"

@interface PieChartCPView : ChartCPBaseView<CPTPieChartDataSource,CPTPieChartDelegate>

@property (nonatomic, readonly, strong) CPTPieChart *pieChart; // 饼图
@property (nonatomic, readonly, strong) CPTLegend *legend; // 图例
@property (nonatomic, readwrite, strong) NSArray *legendTextArray; // 饼图文字

@end
