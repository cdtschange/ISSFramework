//
//  BarChartCPViewController.m
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "BarChartCPView.h"
#import "CPTValueTipRectLayer.h"

@interface BarChartCPView ()
{
    NSTimer *_animationTimer;
}

@end

@implementation BarChartCPView

@synthesize barWidth,barInitX,colorfulBar;

-(id)init{
    if (self = [super init]) {
        
        self.graphTitle=@"Bar Chart";
        self.barWidth=0.4;
        self.barInitX=0.8;
    }
    return self;
}

-(void)dealloc{
    
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
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
	barLineStyle.lineColor = [CPTColor clearColor];
	barLineStyle.lineWidth = 0.5;
    
    CGFloat barOffsetX = barInitX;
    NSArray *allKeys=[self.plotSource allKeys];
    
    for (int i=0; i<self.plotSource.count; i++) {
        NSString *key=[allKeys objectAtIndex:i];
        NSDictionary *item=[self.plotSource objectForKey:key];
        CPTColor *color=[self.defaultColorArray objectAtIndex:i%self.defaultColorArray.count];
        if ([[item allKeys] containsObject:@"color"]) {
            color=[item objectForKey:@"color"];
        }
        BOOL horizontal=NO;
        if ([[item allKeys] containsObject:@"horizontal"]) {
            horizontal=[[item objectForKey:@"horizontal"] boolValue];
        }
        if ([[item allKeys] containsObject:@"barWidth"]) {
            barWidth=[[item objectForKey:@"barWidth"] doubleValue];
        }
        CPTBarPlot *plot=[CPTBarPlot tubularBarPlotWithColor:color horizontalBars:horizontal];
         
        plot.identifier=key;
        plot.dataSource = self;
		plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(barWidth);
        plot.barOffset = CPTDecimalFromDouble(barOffsetX);
		plot.lineStyle = barLineStyle;
		[self.hostView.hostedGraph addPlot:plot toPlotSpace:self.hostView.hostedGraph.defaultPlotSpace];
        barOffsetX+=barWidth;
        [self.plotArray addObject:plot];
    }
}

-(void)initAxes {
	[super initAxes];
}

#pragma mark - Animation Delegate + Run Loop Timer

static CGPathRef CGPathCreateArc(CGPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center.x, center.y);
    
    CGPathAddArc(path, NULL, center.x, center.y, radius, startAngle, endAngle, 0);
    CGPathCloseSubpath(path);
    
    return path;
}


- (void)animationDidStart:(CAAnimation *)anim
{
    if (_animationTimer == nil) {
        static float timeInterval = 1.0/60.0;
        _animationTimer= [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];
    }
    
//    [_animations addObject:anim];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)animationCompleted
{
//    [_animations removeObject:anim];
    
//    if ([_animations count] == 0) {
        [_animationTimer invalidate];
        _animationTimer = nil;
//    }
}


#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
	return ((NSArray *)[item objectForKey:@"value"]).count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
    NSDictionary *oldItem=self.oldPlotSource?[self.oldPlotSource objectForKey:plot.identifier]:nil;
    
    if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < ((NSArray *)[item objectForKey:@"value"]).count)) {
        NSNumber *number=[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
        NSNumber *oldNumber=oldItem?[((NSArray *)[oldItem objectForKey:@"value"]) objectAtIndex:index]:0;
                
        return [NSNumber numberWithDouble: oldNumber.doubleValue+(number.doubleValue-oldNumber.doubleValue)*self.animationHelper.dataIncreasedUpdateData];
   }
    return [NSDecimalNumber numberWithUnsignedInteger:index];
}

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index{
    if (!colorfulBar) {
        return nil;
    }
    CPTColor *color = (CPTColor *)[self.defaultColorArray objectAtIndex:index%self.defaultColorArray.count];
    const CGFloat *components = CGColorGetComponents(color.cgColor);
    CPTColor *gcolor = [CPTColor colorWithComponentRed:components[0]+(1-components[0])/2 green:components[1]+(1-components[1])/2 blue:components[2]+(1-components[2])/2 alpha:components[3]];
    CPTColor *gcolor2 = [CPTColor colorWithComponentRed:components[0]-(components[0])/3 green:components[1]-(components[1])/3 blue:components[2]-(components[2])/3 alpha:components[3]];

    CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:color endingColor:color];
    
	fillGradient = [fillGradient addColorStop:[gcolor colorWithAlphaComponent:1] atPosition:0.2];
    fillGradient = [fillGradient addColorStop:[gcolor2 colorWithAlphaComponent:1] atPosition:0.6];
	
    
	return [CPTFill fillWithGradient:fillGradient];
}

-(CPTColor *)getPlotColor:(CPTBarPlot *)plot index:(NSInteger)index{
    if (!colorfulBar) {
        return [super getPlotColor:[self.plotArray indexOfObject:plot]];
    }
    return [self.defaultColorArray objectAtIndex:index%self.defaultColorArray.count];
}

-(CPTColor *)getPlotColor:(NSInteger)index{
    if (!colorfulBar) {
        return [super getPlotColor:0];
    }
    return [super getPlotColor:index];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
	if (plot.isHidden == YES ||!self.getValueTipRectBlock ||!self.drawValueTipChartDelegate) {
		return;
	}

    // 3 - select index and value
	NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
    NSNumber *price =[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
    
    self.selectPrice=price;
    self.selectPlot=plot;
    self.selectIndex=index;
    
    // 4 - not need show
    if (!self.tipShow) {
        return;
    }
    
    // 5 - create content layer
    CGRect frame=self.getValueTipRectBlock(plot,index,price);
    UIColor *focusColor = [UIColor colorWithCGColor:[self getPlotColor:index].cgColor];
    const CGFloat* colors = CGColorGetComponents(focusColor.CGColor);
    CPTValueTipRectLayer *valueLayer = [[CPTValueTipRectLayer alloc] initWithFrame:frame arrowLength:self.tipArrowLength];
    valueLayer.borderColor = [UIColor colorWithRed:colors[0]*0.75 green:colors[1]*0.75 blue:colors[2]*0.75 alpha:1.0];
    valueLayer.drawerDelegate=self;
    
	// 6 - Get plot index based on identifier
	NSInteger plotIndex = 0;
    for (int i=0; i<self.plotArray.count; i++) {
        if (plot == [self.plotArray objectAtIndex:i]) {
            plotIndex = i;
            break;
        }
    }
    
	// 7 - Get the anchor point for annotation
	CGFloat x = index + barInitX + (plotIndex * barWidth);
	NSNumber *anchorX = [NSNumber numberWithFloat:x];
	CGFloat y = [price floatValue];
	NSNumber *anchorY = [NSNumber numberWithFloat:y];
    
    // 8 - Add the annotation
    [self displayValueTipControl:plot subLayer:valueLayer anchorX:anchorX anchorY:anchorY];
}

-(void)barDrawForBarPlot:(CPTBarPlot *)plot drawContext:(CGContextRef)context basePoint:(CGPoint)basePoint tipPoint:(CGPoint)tipPoint barWidthLength:(CGFloat)barWidthLength recordIndex:(NSUInteger)index
{
    if (!self.isFocusColorSupported || self.selectIndex != index) {
        return;
    }
    
    CGRect barFrame = CGRectMake(basePoint.x - barWidthLength/2,
                                 tipPoint.y,
                                 barWidthLength,
                                 tipPoint.y - basePoint.y);
    
    [self drawDashPatternLine:context drawArea:barFrame];
}

#pragma mark- ValueTipRectLayerDelegate
- (void)drawContentRect:(CPTValueTipRectLayer *)layer context:(CGContextRef)context drawRect:(CGRect)rect
{
    if (self.drawValueTipChartDelegate && [self.drawValueTipChartDelegate respondsToSelector:@selector(drawValueTipRect:layer:context:drawRect:plot:index:price:)]) {
        [self.drawValueTipChartDelegate drawValueTipRect:self layer:layer context:context drawRect:rect plot:self.selectPlot index:self.selectIndex price:self.selectPrice];
    }
}

#pragma mark- private method
- (void)drawDashPatternLine:(CGContextRef)context drawArea:(CGRect)rect
{
    CGRect clipRect = CGRectMake(rect.origin.x,
                                 rect.origin.y-rect.size.height,
                                 rect.size.width,
                                 rect.size.height);
    CGContextSaveGState(context);
    CGContextAddRect(context, clipRect);
    CGContextRestoreGState(context);
    CGContextClip(context);
    
    double delta=self.selectDashLineWidth;
    double length=rect.size.height+rect.size.width;
    CGPoint lt = CGPointMake(rect.origin.x-delta/2, rect.origin.y+delta/2); // 左上
    CGPoint rt = CGPointMake(lt.x+length+2*delta/2, lt.y); // 右上

    // 沿着上边从左到右移动，再从上到下
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
}

@end
