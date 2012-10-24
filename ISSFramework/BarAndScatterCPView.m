//
//  BarAndScatterCPView.m
//  BIChart
//
//  Created by 健 王 on 12-10-8.
//  Copyright (c) 2012年 Wei Mao. All rights reserved.
//

#import "BarAndScatterCPView.h"

@implementation BarAndScatterCPView
@synthesize barWidth,barInitX,colorfulBar;
@synthesize fillStyle,symbolSize,symbolType,scatterInitX;
-(id)init{
    if (self = [super init]) {
        
        self.graphTitle=@"Bar And Scatter Chart";
        self.barWidth=0.4;
        self.barInitX=0.8;
        
        self.fillStyle=ScatterChartNone;
        self.symbolSize=12;
        self.symbolType=CPTPlotSymbolTypeEllipse;
        self.scatterInitX = 0.0;
        
        selectPlotType = BARCHART;
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
    
    //    colorfulBar=YES;
    
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
    for (int i=0; i<self.plotSource.count; i++) 
    {
        NSString *key=[allKeys objectAtIndex:i];
        NSDictionary *item=[self.plotSource objectForKey:key];
        if([[item allKeys] containsObject:@"SType"] && [[item objectForKey:@"SType"] isEqualToNumber:[NSNumber numberWithInt:BARCHART]])
        {
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
            //barOffsetX+=barWidth;
            [self.plotArray addObject:plot];
        }
        if([[item allKeys] containsObject:@"SType"] && [[item objectForKey:@"SType"] isEqualToNumber:[NSNumber numberWithInt:SCATTERCHART]])
        {
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
            
            [self.hostView.hostedGraph addPlot:plot toPlotSpace:self.hostView.hostedGraph.defaultPlotSpace];
            [self.plotArray addObject:plot];
        }
    }
}

-(void)initAxes {
	[super initAxes];
}

-(NSInteger)getPlotType:(CPTPlot*)plot
{
    NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
    if([[item allKeys] containsObject:@"SType"] && [[item objectForKey:@"SType"] isEqualToNumber:[NSNumber numberWithInt:BARCHART]])
        return BARCHART;
    if([[item allKeys] containsObject:@"SType"] && [[item objectForKey:@"SType"] isEqualToNumber:[NSNumber numberWithInt:SCATTERCHART]])
        return SCATTERCHART;
    return -1;
}
-(CPTColor *)getPlotColor:(CPTScatterPlot *)plot index:(NSInteger)index{
    if([self getPlotType:plot] == SCATTERCHART)
        return plot.dataLineStyle.lineColor;
    else
        return [super getPlotColor:plot index:index];
    //return [self.defaultColorArray objectAtIndex:(index%virtualPlots)%self.defaultColorArray.count];
}
#pragma mark - Animation Delegate + Run Loop Timer

- (void)updateTimerFired:(NSTimer *)timer;
{
    
}
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
    NSInteger valueCount =  ((NSArray *)[item objectForKey:@"value"]).count;
    NSNumber *number=nil;
    NSNumber *oldNumber=nil;
    if([self getPlotType:plot] == SCATTERCHART)
    {
        switch (fieldEnum) {
            case CPTScatterPlotFieldX:
                if (index < valueCount) {
                    return [NSNumber numberWithDouble:index+scatterInitX];
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
    if([self getPlotType:plot] == BARCHART)
    {
        if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < ((NSArray *)[item objectForKey:@"value"]).count)) {
            NSNumber *number=[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
            NSNumber *oldNumber=oldItem?[((NSArray *)[oldItem objectForKey:@"value"]) objectAtIndex:index]:0;
            
            return [NSNumber numberWithDouble: oldNumber.doubleValue+(number.doubleValue-oldNumber.doubleValue)*self.animationHelper.dataIncreasedUpdateData];
        }
        return [NSDecimalNumber numberWithUnsignedInteger:index];
    }
    return [NSDecimalNumber zero];
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

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
	if (plot.isHidden == YES ||!self.getValueTipRectBlock ||!self.drawValueTipChartDelegate) {
		return;
	}
    
	NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
    NSNumber *price =[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
    
    self.selectPrice=price;
    self.selectPlot=plot;
    self.selectIndex=index;
    
    if (!self.tipShow) {
        return;
    }
    CGRect frame=self.getValueTipRectBlock(plot,index,price);
    CPTValueTipRectLayer *valueLayer = [[CPTValueTipRectLayer alloc] initWithFrame:frame arrowLength:self.tipArrowLength];
    valueLayer.borderColor = [UIColor colorWithCGColor:[self getPlotColor:plot index:index].cgColor];    
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
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)self.hostView.hostedGraph.defaultPlotSpace;
	CGFloat x = index + barInitX;
	NSNumber *anchorX = [NSNumber numberWithFloat:x];
	CGFloat y = [price floatValue];
    NSLog(@"%f",plotSpace.globalXRange.lengthDouble/plotSpace.xRange.lengthDouble);
	NSNumber *anchorY = [NSNumber numberWithFloat:y];
    NSLog(@"%f",y);
	// 8 - Add the annotation
    [self displayValueTipControl:plot subLayer:valueLayer anchorX:anchorX anchorY:anchorY];
    selectPlotType = BARCHART;
}
#pragma mark - CPTScatterPlotDelegate methods
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    
    //NSLog(@"\n\n %@ -- %s  \n\n",[self class],__FUNCTION__);
    
    
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
    CPTValueTipRectLayer *valueLayer = [[CPTValueTipRectLayer alloc] initWithFrame:frame
                                                                       arrowLength:self.tipArrowLength];
    valueLayer.borderColor = [UIColor colorWithCGColor:[self getPlotColor:[self.plotArray indexOfObject:plot]].cgColor];
    valueLayer.drawerDelegate = self;
    
    
    //NSLog(@"plot  = %p  ,  anchorX : %@    anchorY : %@ ",plot,x,y);
    [self displayValueTipControl:plot subLayer:valueLayer anchorX:x anchorY:y];
    selectPlotType = SCATTERCHART;
}

-(void)barDrawForBarPlot:(CPTBarPlot *)plot drawContext:(CGContextRef)context basePoint:(CGPoint)basePoint tipPoint:(CGPoint)tipPoint barWidthLength:(CGFloat)barWidthLength recordIndex:(NSUInteger)index
{
    if (!self.isFocusColorSupported || self.selectIndex != index || selectPlotType != BARCHART) {
        return;
    }
    
    CGRect barFrame = CGRectMake(basePoint.x - barWidthLength/2,
                                 tipPoint.y,
                                 barWidthLength,
                                 tipPoint.y - basePoint.y);
    
    NSLog(@"\n\n %@   --  %s   \n  self ==> %p\n  barFrame frame :%@\n  self.frame  ==> %@\n  basePoint : %@\n  tipPoint : %@\n\n",[self class],__FUNCTION__,self,  NSStringFromCGRect(barFrame),NSStringFromCGRect(self.frame) , NSStringFromCGPoint(basePoint),NSStringFromCGPoint(tipPoint));
    
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
    //    CGPoint lb = CGPointMake(lt.x, lt.y-delta); // 左下
    //    CGPoint rb = CGPointMake(rt.x, lb.y); // 右下
    
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
