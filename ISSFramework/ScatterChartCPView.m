//
//  ScatterChartCPViewController.m
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "ScatterChartCPView.h"

@interface ScatterChartCPView ()

@end

@implementation ScatterChartCPView
@synthesize fillStyle,symbolSize,symbolType;

-(id)init{
    if (self = [super init]) {
        self.graphTitle=@"Scatter Chart";
        self.fillStyle=ScatterChartNone;
        self.symbolSize=12;
        self.symbolType=CPTPlotSymbolTypeEllipse;
    }
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)initChart{
    [self initHostView];
    [self initGraph];
    [self initPlots];
    [self initAxes];
}

-(void)initGraph{
    [super initGraph];
}

-(void)initPlots {
    [super initPlot];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.hostView.hostedGraph.defaultPlotSpace;
    NSArray *allKeys=[self.plotSource allKeys];
    
    for (int i=0; i<allKeys.count; i++) {
        NSString *key=[allKeys objectAtIndex:i];
        NSDictionary *item=[self.plotSource objectForKey:key];
        CPTColor *color=[self.defaultColorArray objectAtIndex:i%self.defaultColorArray.count];
        if ([[item allKeys] containsObject:@"color"]) {
            color=[item objectForKey:@"color"];
        }
        CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
        plot.identifier=key;
        plot.dataSource = self;
		plot.delegate = self;
        CPTMutableLineStyle *lineStyle = [plot.dataLineStyle mutableCopy];
        lineStyle.lineWidth = 2.5;
        lineStyle.lineColor = color;
        plot.dataLineStyle = lineStyle;
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = color;
        CPTPlotSymbol *symbol = [[CPTPlotSymbol alloc] init];
        symbol.symbolType = symbolType;
        symbol.fill = [CPTFill fillWithColor:color];
        symbol.lineStyle = symbolLineStyle;
        symbol.size = CGSizeMake(symbolSize, symbolSize);
        plot.plotSymbol = symbol;
        CPTGradient *areaGradient;
        CPTFill *areaGradientFill;
        switch (self.fillStyle) {
            case ScatterChartNone:
                plot.areaFill=nil;
                break;
            case ScatterChartGradientFill:
                areaGradient = [ CPTGradient gradientWithBeginningColor :color endingColor :[CPTColor clearColor]];
                // 渐变角度： -90 度（顺时针旋转）
                areaGradient.angle = -90.0f ;
                areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
                plot.areaFill = areaGradientFill;
                plot.areaBaseValue = CPTDecimalFromString ( @"0.0" );
                plot.interpolation = CPTScatterPlotInterpolationLinear;
                break;
            case ScatterChartFullFill:
                areaGradient = [ CPTGradient gradientWithBeginningColor :color endingColor :color];
                // 渐变角度： -90 度（顺时针旋转）
                areaGradient.angle = -90.0f ;
                areaGradientFill = [ CPTFill fillWithGradient :areaGradient];
                plot.areaFill = areaGradientFill;
                plot. areaBaseValue = CPTDecimalFromString ( @"0.0" );
                plot.interpolation = CPTScatterPlotInterpolationLinear;
                break;
            default:
                break;
        }
        
        [self.hostView.hostedGraph addPlot:plot toPlotSpace:plotSpace];
        [self.plotArray addObject:plot];
    }
}

-(void)initAxes {
	[super initAxes];
}

-(CPTColor *)getPlotColor:(CPTBarPlot *)plot index:(NSInteger)index{
    return [super getPlotColor:[self.plotArray indexOfObject:plot]];
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
	return ((NSArray *)[item objectForKey:@"value"]).count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
    NSDictionary *oldItem=self.oldPlotSource?[self.oldPlotSource objectForKey:plot.identifier]:nil;
    NSInteger valueCount =  ((NSArray *)[item objectForKey:@"value"]).count;
    NSNumber *number=nil;
    NSNumber *oldNumber=nil;
	switch (fieldEnum) {
		case CPTScatterPlotFieldX:
			if (index < valueCount) {
				return [NSNumber numberWithUnsignedInteger:index];
			}
			break;
			
		case CPTScatterPlotFieldY:
            number=[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
            oldNumber=oldItem?[((NSArray *)[oldItem objectForKey:@"value"]) objectAtIndex:index]:0;
            return [NSNumber numberWithDouble: oldNumber.doubleValue+(number.doubleValue-oldNumber.doubleValue)*self.animationHelper.dataIncreasedUpdateData];
			break;
	}
	return [NSDecimalNumber zero];
}

#pragma mark - CPTScatterPlotDelegate methods
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    if (plot.isHidden == YES ||!self.getValueTipRectBlock ||!self.drawValueTipChartDelegate) {
        return;
    }
    
	// Determine point of symbol in plot coordinates
	NSNumber *x			 = [self numberForPlot:plot
                                   field:CPTScatterPlotFieldX
                             recordIndex:index];
	NSNumber *y			 = [self numberForPlot:plot
                                   field:CPTScatterPlotFieldY
                             recordIndex:index];
    NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
    NSNumber *price =[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
    
	self.selectPrice=price;
    self.selectPlot=plot;
    self.selectIndex=index;
    
    if (!self.tipShow) {
        return;
    }
    CGRect frame=self.getValueTipRectBlock(plot,index,price);
    UIColor *focusColor = [UIColor colorWithCGColor:[self getPlotColor:index].cgColor];
    const CGFloat* colors = CGColorGetComponents(focusColor.CGColor);
    CPTValueTipRectLayer *valueLayer = [[CPTValueTipRectLayer alloc] initWithFrame:frame arrowLength:self.tipArrowLength];
    valueLayer.borderColor = [UIColor colorWithRed:colors[0]*0.75 green:colors[1]*0.75 blue:colors[2]*0.75 alpha:1.0];
    valueLayer.drawerDelegate = self;

    [self displayValueTipControl:plot subLayer:valueLayer anchorX:x anchorY:y];
}

#pragma mark- ValueTipRectLayerDelegate
- (void)drawContentRect:(CPTValueTipRectLayer *)layer context:(CGContextRef)context drawRect:(CGRect)rect
{
    if (self.drawValueTipChartDelegate && [self.drawValueTipChartDelegate respondsToSelector:@selector(drawValueTipRect:layer:context:drawRect:plot:index:price:)]) {
        [self.drawValueTipChartDelegate drawValueTipRect:self layer:layer context:context drawRect:rect plot:self.selectPlot index:self.selectIndex price:self.selectPrice];
    }
}


@end
