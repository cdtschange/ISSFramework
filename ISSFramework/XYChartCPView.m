//
//  XYChartCPViewController.m
//  BIChartDemo
//
//  Created by Wei Mao on 8/24/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "XYChartCPView.h"

@interface XYChartCPView (){
    double doubleXRangOffset; // x方向可视区域最大值与全局最大值差值
}

@end

@implementation XYChartCPView
@synthesize xAxisMax;
@synthesize xAxisMin;
@synthesize yAxisMax;
@synthesize yAxisMin;
@synthesize axisTitleFontSize;
@synthesize xAxisTitleOffset;
@synthesize yAxisTitleOffset;
@synthesize axisLineWidth;
@synthesize axisLineColor;
@synthesize xAxisTitle;
@synthesize yAxisTitle;
@synthesize doubleClickScaleDefaultValue;

-(id)init{
    if (self = [super init]) {
        // 默认属性值
        self.graphPaddingLeft=50;
        self.graphPaddingBottom=50;
        self.graphPaddingRight=20;
        self.graphPaddingTop=30;
        self.xAxisTitle=@"X Title";
        self.yAxisTitle=@"Y Title";
        self.axisTitleFontSize=12.0;
        self.xAxisTitleOffset=25.0;
        self.yAxisTitleOffset=35.0;
        self.axisLineWidth=2.0;
        self.axisLineColor=[[CPTColor blackColor] colorWithAlphaComponent:0.6];
        self.doubleClickScaleDefaultValue=2.0;
    }
    return  self;
}

-(void)dealloc{
    self.axisLineColor=nil;
    self.xAxisTitle=nil;
    self.yAxisTitle=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initHostView{
    [super initHostView];
    
    // 双击事件监控
    UITapGestureRecognizer *tapListener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapListener:)];
    tapListener.numberOfTapsRequired = 2;
    tapListener.numberOfTouchesRequired = 1;
    [self.hostView addGestureRecognizer:tapListener];
}

-(void)initGraph{
    [super initGraph];
    [self setPlotSpace];
}

-(void)setPlotSpace
{
    // 可视区域内X轴Y轴最大值设定
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    plotSpace.allowsUserInteraction=YES;
    plotSpace.delegate=self;
    plotSpace.xScaleType = CPTScaleTypeLinear;
    plotSpace.yScaleType = CPTScaleTypeLinear;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.xAxisMin) length:CPTDecimalFromFloat(self.xRangValue)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.yAxisMin) length:CPTDecimalFromFloat(self.yAxisMax)];
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.xAxisMin) length:CPTDecimalFromFloat(self.xAxisMax)];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.yAxisMin) length:CPTDecimalFromFloat(self.yAxisMax)];
    
    doubleXRangOffset = plotSpace.globalXRange.lengthDouble - plotSpace.xRange.lengthDouble;
}


-(void)initPlot{
    [super initPlot];
}

-(void)initAxes{
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor blackColor];
    
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = self.axisTitleFontSize;
    CPTMutableLineStyle *frameStyle = [CPTMutableLineStyle lineStyle];
	frameStyle.lineWidth = 1;
	frameStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.3];
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
	gridLineStyle.lineWidth = 1;
	gridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.3];
    gridLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:4.0f], nil];
    
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = self.axisLineWidth;
	axisLineStyle.lineColor = self.axisLineColor;
	// 2 - Get the graph's axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
	// 3 - Configure the x-axis
	axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
	axisSet.xAxis.title = self.xAxisTitle;
	axisSet.xAxis.titleTextStyle = axisTitleStyle;
	axisSet.xAxis.titleOffset = self.xAxisTitleOffset;
	axisSet.xAxis.axisLineStyle = axisLineStyle;
    
    axisSet.xAxis.minorTickLineStyle=nil;
    axisSet.xAxis.majorTickLineStyle=frameStyle;
    axisSet.xAxis.majorTickLength = 5;
    axisSet.xAxis.tickDirection = CPTSignNegative;
    axisSet.xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:self.xAxisMin];
	// 4 - Configure the y-axis
	axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
	axisSet.yAxis.title = self.yAxisTitle;
	axisSet.yAxis.titleTextStyle = axisTitleStyle;
	axisSet.yAxis.titleOffset = self.yAxisTitleOffset;
	axisSet.yAxis.axisLineStyle =axisLineStyle;
    axisSet.yAxis.minorTickLineStyle=nil;
    axisSet.yAxis.majorTickLineStyle=frameStyle;
    axisSet.yAxis.majorTickLength = 5;
    axisSet.yAxis.majorGridLineStyle = gridLineStyle;
    axisSet.yAxis.tickDirection = CPTSignNegative;
    axisSet.yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:self.yAxisMin];
}

- (void)setAxis:(CPTAxisLabelingPolicy)policy axisLabels:(NSMutableSet*)newAxisLabels
{
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
	axisSet.xAxis.labelingPolicy = policy;
	axisSet.xAxis.axisLabels = newAxisLabels;
}

-(void)setPlotSource:(NSMutableDictionary *)plotSource{
    [super setPlotSource:plotSource];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    [plotSpace scaleBy:plotSpace.xRange.lengthDouble/plotSpace.globalXRange.lengthDouble aboutPoint:CGPointMake(0, 0)];
}

#pragma mark - CPTPlotSpaceDelegate methods
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    [self dismissValueTipControl];
    
    
    NSLog(@"//%f",interactionScale );
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) space.graph.defaultPlotSpace;
    
//    if ((plotSpace.xRange.lengthDouble+doubleXRangOffset >= plotSpace.globalXRange.lengthDouble) && interactionScale < 1.0) {
//        return NO;
//    }
    if (plotSpace.xRange.lengthDouble*self.xAxisMax < ((CPTXYPlotSpace *)space).xRange.maxLimitDouble*interactionScale) {
        return NO;
    }
    if (plotSpace.yRange.lengthDouble*self.yAxisMax < ((CPTXYPlotSpace *)space).yRange.maxLimitDouble*interactionScale) {
        return NO;
    }
    
    return YES;
}

//点击空白处时提示消失
- (BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)point
{
    [self dismissValueTipControl];
    
    return YES;
}

#pragma mark - Tap Gesture Listener
- (void)doubleTapListener:(UITapGestureRecognizer*)sender
{
    if ([self.animationHelper isAnimation]) {
        return;
    }
    
    // 隐藏提示信息
    [self dismissValueTipControl];
    
    // 相对于柱状视图区域位置
    CGPoint interactionPoint = [sender locationInView:self.hostView];
	if (!self.hostView.collapsesLayers ) {
		interactionPoint = [self.hostView.layer convertPoint:interactionPoint toLayer:self.hostView.hostedGraph];
	}
	else {
		interactionPoint.y = self.hostView.frame.size.height - interactionPoint.y;
	}
    
    // 转换视图区域内点击点为坐标轴内点
	CGPoint pointInPlotArea = [self.hostView.hostedGraph convertPoint:interactionPoint
                                                              toLayer:self.hostView.hostedGraph.plotAreaFrame.plotArea];
    if (CGRectContainsPoint(self.hostView.hostedGraph.plotAreaFrame.plotArea.frame, pointInPlotArea)) {
        
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:2];
        [data setValue:[NSValue valueWithCGPoint:pointInPlotArea] forKey:@"point"];
        [data setValue:self.hostView forKey:@"hostView"];
        
        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
        if (plotSpace.xRange.lengthDouble+doubleXRangOffset < plotSpace.globalXRange.lengthDouble) {
            // 双击返回到初始状态
            [data setValue:[NSNumber numberWithDouble:(plotSpace.xRange.lengthDouble+doubleXRangOffset/doubleClickScaleDefaultValue)/plotSpace.globalXRange.lengthDouble]
                    forKey:@"scaleValue"];
        }
        else {
            // 双击放大
            [data setValue:[NSNumber numberWithDouble:doubleClickScaleDefaultValue] forKey:@"scaleValue"];
        }
        
        // 动画显示放大状态
        [self.animationHelper commitAnimation:AnimationScale data:data];
    }
}

@end
