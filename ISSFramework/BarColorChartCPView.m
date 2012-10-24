//
//  BarColorChartCPView.m
//  BIChart
//
//  Created by 健 王 on 12-9-26.
//  Copyright (c) 2012年 Wei Mao. All rights reserved.
//

#import "BarColorChartCPView.h"

@implementation BarColorChartCPView
@synthesize barWidth,barInitX,colorfulBar;
-(id)init{
    if (self = [super init]) {
        
        self.graphTitle=@"Bar Chart";
        self.barWidth=0.4;
        self.barInitX=0.8;
        _selectCell = 0;
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
    if(self.xAxisMax >7)
        [self autoScale];
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
    //NSArray *allKeys=[self.plotSource allKeys];
    
    for (int i=self.plotSource.count-1; i>=0; i--) 
    //for (int i=0; i<self.plotSource.count; i++) 
    {
        NSString *key=[NSString stringWithFormat:@"%@%d",PLOTKEY,i];
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
//        barOffsetX += 0.2;
//        barOffsetX+=barWidth;
        [self.plotArray addObject:plot];
    }
}

-(void)initAxes {
	[super initAxes];
}
-(void)autoScale
{
    for ( CPTPlotSpace *space in self.hostView.hostedGraph.allPlotSpaces ) {
        if ( space.allowsUserInteraction ) {
            [space scaleBy:1.0 aboutPoint:CGPointMake(0, 0)];
        }
    }
}
-(NSInteger)getIndexFromPlot:(CPTPlot*)plot
{
    NSString * identifier = (NSString*)plot.identifier;
    if(identifier == nil)return 0;
    NSInteger result= 0;
    for(int i=0;i<INT32_MAX;i++)
    {
        if([identifier isEqualToString:[NSString stringWithFormat:@"%@%d",PLOTKEY,i]])
        {result = i;break;}
    }
    return result;
}
-(BOOL)isExistObj:(NSMutableArray*)obj I:(NSInteger)i J:(NSInteger)j
{
    BOOL result = NO;
    if(obj == nil)return NO;
    if(obj.count > i)
    {
        if([[obj objectAtIndex:i] count] > j)
            result = YES;
    }
    return result;
}
-(NSNumber*)getAllLastNum:(id)obj I:(NSInteger)i
{
    if(i == 0)
        return [NSNumber numberWithFloat:[(NSNumber*)[obj objectAtIndex:i] floatValue]];
    else 
    {
        float cur = [(NSNumber*)[obj objectAtIndex:i] floatValue];
        float last = [[self getAllLastNum:obj I:i-1] floatValue];
        return [NSNumber numberWithFloat:cur+last];
    }
    return nil;
}
-(void)setNewPlotSource:(NSMutableDictionary *)source withAnimation:(BOOL)animation
{
    if (source == nil) {
        return;
    }
    
    //第二种变换方式
    NSMutableDictionary *buildPlots = [[NSMutableDictionary alloc] init];
    for(int i=0;i<source.count;i++)
    {
        NSArray *allKeys=[source allKeys];
        NSMutableArray * values = [[source objectForKey:[allKeys objectAtIndex:i]] objectForKey:@"value"];
        int recordNum = values.count;
        int plotNum = [[values objectAtIndex:0] count];
        virtualPlots = plotNum;
        
        for (int j=plotNum-1; j>=0; j--) 
        {
            NSMutableDictionary * tmp = [[NSMutableDictionary alloc] init];
            NSMutableArray * value = [[NSMutableArray alloc] init];
            for(int k=0;k<recordNum;k++)
            {
                NSNumber * curNum = 0;
                if(![self isExistObj:values I:k J:j])
                    NSLog(@"%@--%s error",[self class],__FUNCTION__);
                else
                    curNum = (NSNumber*)[[values objectAtIndex:k] objectAtIndex:j];
                if(j>0)
                {
                    //NSNumber * lastNum = (NSNumber*)[[values objectAtIndex:k] objectAtIndex:j-1];
                    NSNumber * lastNum = [self getAllLastNum:[values objectAtIndex:k] I:j-1];
                    [value addObject:[NSNumber numberWithDouble:curNum.floatValue+lastNum.floatValue]];
                }
                else 
                    [value addObject:[NSNumber numberWithDouble:curNum.floatValue]]; 
            }
            //封装一维对象称为所需要的格式
            [tmp setValue:value forKey:@"value"];
            [buildPlots setValue:tmp forKey:[NSString stringWithFormat:@"%@%d",PLOTKEY,j]];
        }
    }
    
    [self.animationHelper stopAnimation];
    [self dismissValueTipControl];
    if (animation) {
        self.oldPlotSource = self.plotSource;
        self.plotSource = buildPlots;
        if (!self.plotArray) {
            [self initPlot];
        }
        NSDictionary *dict=[NSDictionary dictionaryWithObject:self.plotArray forKey:@"plotArray"];
        
        [self.animationHelper commitAnimation:AnimationUpdateData data:dict];
    }
    else {
        self.plotSource = source;
        
        for (CPTPlot *plot in self.plotArray) {
            [plot reloadData];
        }
    }
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
    //if(fieldEnum == CPTBarPlotFieldBarLocation)
    //    return [NSNumber numberWithInt:index/virtualPlots] ;
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
    NSInteger plotIndex = [self getIndexFromPlot:barPlot];
    CPTColor *color = (CPTColor *)[self.defaultColorArray objectAtIndex:plotIndex];
    //CPTColor *color = (CPTColor *)[self.defaultColorArray objectAtIndex:(index%virtualPlots)%self.defaultColorArray.count];
    const CGFloat *components = CGColorGetComponents(color.cgColor);
    CPTColor *gcolor = [CPTColor colorWithComponentRed:components[0]+(1-components[0])/2 green:components[1]+(1-components[1])/2 blue:components[2]+(1-components[2])/2 alpha:components[3]];
    CPTColor *gcolor2 = [CPTColor colorWithComponentRed:components[0]-(components[0])/3 green:components[1]-(components[1])/3 blue:components[2]-(components[2])/3 alpha:components[3]];
    
    CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:color endingColor:color];
	fillGradient = [fillGradient addColorStop:[gcolor colorWithAlphaComponent:1] atPosition:0.2];
    fillGradient = [fillGradient addColorStop:[gcolor2 colorWithAlphaComponent:1] atPosition:0.6];
	
    //return [CPTFill fillWithColor:[CPTColor blackColor]];
	return [CPTFill fillWithGradient:fillGradient];
}

-(CPTColor *)getPlotColor:(CPTBarPlot *)plot index:(NSInteger)index{
    if (!colorfulBar) {
        return [super getPlotColor:[self.plotArray indexOfObject:plot]];
    }
    NSInteger plotIndex = [self getIndexFromPlot:plot];
    return [self.defaultColorArray objectAtIndex:plotIndex];
    //return [self.defaultColorArray objectAtIndex:(index%virtualPlots)%self.defaultColorArray.count];
}



#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
	if (plot.isHidden == YES ||!self.getValueTipRectBlock ||!self.drawValueTipChartDelegate) {
		return;
	}
    
    NSNumber *lastPrice = [NSNumber numberWithFloat:0.0f];
    _selectCell= [self getIndexFromPlot:plot];
    if(_selectCell > 0)
    {
        NSDictionary *lastPlot=[self.plotSource objectForKey:[NSString stringWithFormat:@"%@%d",PLOTKEY,_selectCell-1]];
        lastPrice =[((NSArray *)[lastPlot objectForKey:@"value"]) objectAtIndex:index];

    }
	NSDictionary *item=[self.plotSource objectForKey:plot.identifier];
    NSNumber *price =[((NSArray *)[item objectForKey:@"value"]) objectAtIndex:index];
    
    self.selectPrice=[NSNumber numberWithFloat:price.floatValue - lastPrice.floatValue];
    self.selectPlot=plot;
    self.selectIndex=index;
    
    NSLog(@"self.selectIndex  %d",self.selectIndex);
    
    if (!self.tipShow) {
        return;
    }
    CGRect frame=self.getValueTipRectBlock(plot,index,price);
    CPTValueTipRectLayer *valueLayer = [[CPTValueTipRectLayer alloc] initWithFrame:frame arrowLength:self.tipArrowLength];
    valueLayer.borderColor = [UIColor colorWithCGColor:[self getPlotColor:plot index:index].cgColor];    
    valueLayer.drawerDelegate=self;
    
	// 7 - Get the anchor point for annotation
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)self.hostView.hostedGraph.defaultPlotSpace;
	CGFloat x = index + barInitX;
    NSLog(@"%f",x);
	NSNumber *anchorX = [NSNumber numberWithFloat:x];
	CGFloat y = [price floatValue];
    NSLog(@"%f",plotSpace.globalXRange.lengthDouble/plotSpace.xRange.lengthDouble);
	NSNumber *anchorY = [NSNumber numberWithFloat:y];
    NSLog(@"%f",y);
    
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
    
    NSLog(@"\n\n %@   --  %s   \n  self ==> %p\n  barFrame frame :%@\n  self.frame  ==> %@\n  basePoint : %@\n  tipPoint : %@\n  index ==>  %d\n",[self class],__FUNCTION__,self,  NSStringFromCGRect(barFrame),NSStringFromCGRect(self.frame) , NSStringFromCGPoint(basePoint),NSStringFromCGPoint(tipPoint),index);
    
    
    NSLog(@"self.selectIndex  %d",self.selectIndex);
    
    if([self getIndexFromPlot:plot] == _selectCell)
    {
        [self drawDashPatternLine:context drawArea:CGRectMake(barFrame.origin.x, barFrame.origin.y, barFrame.size.width, barFrame.size.height)];
    }
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
    
    
    NSLog(@"\n\n %@   --  %s   \n self ==> %p\n  drawArea frame :%@\n\n  ",[self class],__FUNCTION__,self, NSStringFromCGRect(rect));
    
    double delta=self.selectDashLineWidth;
    double length=rect.size.width+rect.size.height;
    CGPoint lt = CGPointMake(rect.origin.x-delta/2, rect.origin.y+delta/2); // 左上
    CGPoint rt = CGPointMake(lt.x+length+2*delta/2, lt.y); // 右上
    
    // 沿着上边从左到右移动，再从上到下
    CGFloat dx = 0;
    CGPoint linePoints[2];
    CGContextClipToRect(context, CGRectMake(rect.origin.x, rect.origin.y-rect.size.height, rect.size.width, rect.size.height));
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
