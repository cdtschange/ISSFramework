//
//  BarColorChartCPView.h
//  BIChart
//
//  Created by 健 王 on 12-9-26.
//  Copyright (c) 2012年 Wei Mao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYChartCPView.h"
#import "CPTValueTipRectLayer.h"
#define PLOTKEY @"plotKey_"
@interface BarColorChartCPView : XYChartCPView<CPTBarPlotDataSource, CPTBarPlotDelegate>
{
    double barWidth;
    double barInitX;
    BOOL colorfulBar;
    NSTimer *_animationTimer;
    NSInteger virtualPlots;
    NSInteger _selectCell;
}
@property (assign, nonatomic) double barWidth;
@property (assign, nonatomic) double barInitX;

@property (assign, nonatomic) BOOL colorfulBar;
@end
