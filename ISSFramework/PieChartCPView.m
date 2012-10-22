//
//  PieChartCPViewController.m
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "PieChartCPView.h"

@interface CPTPieChartEx : CPTPieChart
@property (assign, nonatomic)  PieChartCPView *parentView;
@end

@implementation CPTPieChartEx
@synthesize parentView;

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    BOOL result = [super pointingDeviceDownEvent:event atPoint:interactionPoint];
    if (result) {
    }
    else {
        if (!parentView.tipShow) {
            return result;
        }
        
        [parentView dismissValueTipControl];
    }
    return result;
}
@end


@interface PieChartCPView ()
@end

@implementation PieChartCPView
@synthesize pieChart, legend, legendTextArray;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initHostView{
    [super initHostView];
}

- (void)initChart{
    [self initHostView];
    [self initGraph];
    [self initPlot];
    [self initAxes];
}

-(void)initGraph{
    [super initGraph];
    self.hostView.hostedGraph.axisSet = nil;
    self.hostView.hostedGraph.plotAreaFrame.borderLineStyle=nil;
}

-(void)initPlot {
    [super initPlot];
	CPTGraph *graph = self.hostView.hostedGraph;
    
	// 2 - Create chart
    pieChart = [[CPTPieChartEx alloc] init];
    ((CPTPieChartEx*)pieChart).parentView = self;
    pieChart.dataSource = self;
	pieChart.delegate = self;
	pieChart.pieRadius = MIN(self.hostView.bounds.size.width,self.hostView.bounds.size.height)*0.4;
	pieChart.identifier = graph.title;
	pieChart.startAngle = M_PI_4;
	pieChart.labelOffset = -pieChart.pieRadius*2/3;
	pieChart.sliceDirection = CPTPieDirectionClockwise;
    pieChart.centerAnchor = CGPointMake(0.1, 0.5);
    
    // 3 - Create gradient
	CPTGradient *overlayGradient = [[CPTGradient alloc] init];
	overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor whiteColor] colorWithAlphaComponent:0.0] atPosition:0.9];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor whiteColor] colorWithAlphaComponent:0.2] atPosition:1.0];
	pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    
	// 4 - Add chart to graph
	[graph addPlot:pieChart];
    [self.plotArray addObject:pieChart];
}

#pragma mark - setter
- (void)setLegendTextArray:(NSArray *)_legendTextArray
{
    legendTextArray = _legendTextArray;
    if (legendTextArray && !legend) {
        CPTGraph *graph = self.hostView.hostedGraph;
        
        // Add legend
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineColor = [CPTColor clearColor];
        CGFloat boundsPadding = self.bounds.size.width / 2.0f;
        legend                  = [CPTLegend legendWithGraph:graph];
        legend.numberOfColumns  = 1;
        legend.fill			    = [CPTFill fillWithColor:[CPTColor clearColor]];
        legend.borderLineStyle  = lineStyle;
        graph.legend             = legend;
        graph.legendAnchor		 = CPTRectAnchorTopRight;
        graph.legendDisplacement = CGPointMake(-boundsPadding - 10.0, 0);
    }
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return ((NSArray *)[[self.plotSource objectForKey:@"pie"] objectForKey:@"value"]).count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if (CPTPieChartFieldSliceWidth == fieldEnum) {
        NSDictionary *item=[self.plotSource objectForKey:@"pie" ];
        NSDictionary *oldItem=[self.oldPlotSource objectForKey:@"pie" ];
        NSNumber *number=[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
        NSNumber *oldNumber = oldItem?[((NSArray *)[oldItem objectForKey:@"value"]) objectAtIndex:index]:0;
        NSNumber *result=[NSNumber numberWithDouble: oldNumber.doubleValue+(number.doubleValue-oldNumber.doubleValue)*self.animationHelper.dataIncreasedUpdateData];
        return result;
	}
	return [NSDecimalNumber zero];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataLabelForPlot:recordIndex:)]) {
        return [self.delegate dataLabelForPlot:plot recordIndex:index];
    }
	// 1 - Define label text style
	return nil;
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    if (legendTextArray) {
        return [legendTextArray objectAtIndex:index];
    }
	return @"N/A";
}


#pragma mark - CPTPieChartDelegate methods
-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index{
    return [CPTFill fillWithColor:[self getPlotColor:index]];
}

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    if (plot.isHidden == YES ||!self.getValueTipRectBlock ||!self.drawValueTipChartDelegate) {
		return;
	}
    // Now add the annotation to the plot area
    NSDictionary *item=[self.plotSource objectForKey:@"pie" ];
    NSNumber *price=[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
    
    self.selectPrice = price;
    self.selectIndex = index;
    self.selectPlot = plot;
    
    if (!self.tipShow) {
        return;
    }
    
    // create content layer
    CGRect frame = self.getValueTipRectBlock(plot,index,price);
    UIColor *focusColor = [UIColor colorWithCGColor:[self getPlotColor:index].cgColor];
    const CGFloat* colors = CGColorGetComponents(focusColor.CGColor);
    CPTValueTipRectLayer *valueLayer = [[CPTValueTipRectLayer alloc] initWithFrame:frame arrowLength:self.tipArrowLength];
    valueLayer.borderColor = [UIColor colorWithRed:colors[0]*0.75 green:colors[1]*0.75 blue:colors[2]*0.75 alpha:1.0];
    valueLayer.drawerDelegate=self;
    
    // create value annotation
    [self createValueAnnotation:plot];
    
    // caculate anchor point and displaccement
    plot.labelOffset     = 0;
    self.valueAnnotation.contentLayer=valueLayer;
    [plot positionLabelAnnotation:self.valueAnnotation forIndex:index];
    plot.labelOffset     = -plot.pieRadius*2/3;
    
    // reset displacement
    CGPoint displace = self.valueAnnotation.displacement;
    displace = CGPointMake(displace.x, displace.y+valueLayer.frame.size.height/2);
    self.valueAnnotation.displacement = displace;
    
    // animation layer
    [self displayValueTipControl:plot subLayer:valueLayer];
}

-(void)pieDrawForPiePlot:(CPTPieChart *)plot
             drawContext:(CGContextRef)context
                drawRect:(CGRect)rect
               slicePath:(CGMutablePathRef)path
             recordIndex:(NSUInteger)index
{
    if (!self.isFocusColorSupported || self.selectIndex != index) {
        return;
    }
    
    // save context
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);

    double delta=self.selectDashLineWidth;
    double length=rect.size.height+rect.size.width;
    CGPoint lt = CGPointMake(rect.origin.x-delta, rect.origin.y+delta); // 左上
    CGPoint rt = CGPointMake(lt.x+length+2*delta, lt.y); // 右上
    CGFloat dx = 0;
    CGPoint linePoints[2];

    while (dx<=rt.x) {
        dx += self.selectDashPattern;
        linePoints[1] = CGPointMake(lt.x+dx, lt.y);
        linePoints[0] = CGPointMake(lt.x, lt.y-dx);
        
        // 绘制斜线
        CGContextSetStrokeColorWithColor(context,
                                         [[CPTColor blackColor] colorWithAlphaComponent:0.3f].cgColor);
        CGContextSetLineWidth(context, self.selectDashLineWidth);
        CGContextAddLines(context, linePoints, 2);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
}

-(CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    if (self.selectIndex == index) {
        return 10.0f;
    }
    return 0;
}

#pragma mark- ValueTipRectLayerDelegate
- (void)drawContentRect:(CPTValueTipRectLayer *)layer context:(CGContextRef)context drawRect:(CGRect)rect
{
    if (self.drawValueTipChartDelegate && [self.drawValueTipChartDelegate respondsToSelector:@selector(drawValueTipRect:layer:context:drawRect:plot:index:price:)]) {
        [self.drawValueTipChartDelegate drawValueTipRect:self layer:layer context:context drawRect:rect plot:self.selectPlot index:self.selectIndex price:self.selectPrice];
    }
}

@end
