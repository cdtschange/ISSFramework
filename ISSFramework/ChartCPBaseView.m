//
//  ChartQuartzBaseViewController.m
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "ChartCPBaseView.h"
#import "ZoomToolView.h"

@interface ChartCPBaseView ()
{
    UITapGestureRecognizer *tapGestureListener; // 单击事件
    CGRect originFrame; // 初始区域
}
@end

@implementation ChartCPBaseView
@synthesize graphPaddingTop;
@synthesize graphPaddingBottom;
@synthesize graphPaddingLeft;
@synthesize graphPaddingRight;
@synthesize hostView,theme;
@synthesize graphTitle;
@synthesize defaultColorArray;
@synthesize plotSource;
@synthesize plotArray;
@synthesize oldPlotSource;
@synthesize animationHelper,scaleManager;
@synthesize valueAnnotation,selectDashLineWidth,selectDashPattern;
@synthesize drawValueTipChartDelegate,delegate,zoomDelegate;
@synthesize getValueTipRectBlock;
@synthesize selectIndex,selectPlot,selectPrice,isFocusColorSupported,tipShow,maskView,parentView;
@synthesize btnInfo,btnClose,borderWidth,isSelected,focusBorderColor,groundView,tipArrowLength;

-(id)init{
    if (self = [super init]) {
        // 默认属性值
        defaultColorArray = [NSArray arrayWithObjects:[CPTColor colorWithComponentRed:77/255.0 green:94/255.0 blue:185/255.0 alpha:1],[CPTColor colorWithComponentRed:58/255.0 green:181/255.0 blue:0/255.0 alpha:1],[CPTColor colorWithComponentRed:220/255.0 green:0/255.0 blue:0/255.0 alpha:1],[CPTColor colorWithComponentRed:254/255.0 green:207/255.0 blue:0/255.0 alpha:1], nil ];
        animationHelper = [[AnimationHelper alloc] init];
        theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
        self.borderWidth=2;
        self.focusBorderColor=[UIColor blueColor];
        self.tipArrowLength=30;
        self.isFocusColorSupported=YES;
        self.selectDashLineWidth=9;
        self.selectDashPattern=23;
        self.selectIndex=-1;
        self.tipShow=YES;
        
        // 放大后背景遮罩
        maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.5;
        
        // information button
        btnInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
        btnInfo.hidden = YES;
        btnInfo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        CGRect frame=btnInfo.frame;
        frame.origin=CGPointMake(self.bounds.size.width-10-borderWidth-frame.size.width, borderWidth+10);
        btnInfo.frame=frame;
        [btnInfo addTarget:self action:@selector(touchInfoButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnInfo];
        
        groundView = [[UIView alloc] initWithFrame:CGRectZero];
        groundView.backgroundColor = [UIColor blackColor];
        groundView.layer.borderColor=[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
        groundView.layer.borderWidth=1;
        groundView.layer.cornerRadius=5;
        groundView.hidden=YES;
        groundView.frame=self.bounds;
        groundView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:groundView];
        
        // 放大后关闭按钮
        btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        btnClose.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"close.png"]];
        btnClose.frame=CGRectMake(10, 10, 22, 22);
        [btnClose addTarget:self action:@selector(touchCloseButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        btnClose.hidden=YES;
        [self addSubview:btnClose];
        
        // tap listener
        tapGestureListener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapListener:)];
        tapGestureListener.numberOfTapsRequired = 1;
        tapGestureListener.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGestureListener];
        
    }
    return self;
}

-(void)dealloc{
    self.hostView=nil;
    self.graphTitle=nil;
    self.defaultColorArray=nil;
    self.plotSource=nil;
    self.plotArray=nil;
    self.oldPlotSource=nil;
    self.valueAnnotation=nil;
    [animationHelper stopAnimation];
    self.animationHelper=nil;
    self.getValueTipRectBlock=nil;
    self.drawValueTipChartDelegate=nil;
    self.delegate=nil;
    self.selectPlot=nil;
    self.selectPrice=nil;
    self.theme=nil;
    self.btnInfo=nil;
    self.btnClose=nil;
    self.focusBorderColor=nil;
    tapGestureListener=nil;
    self.scaleManager=nil;
    self.zoomDelegate=nil;
    self.maskView=nil;
    self.parentView=nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)initChart{
    
}

-(void)initHostView {
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:CGRectMake(borderWidth,
                                                                                                  borderWidth,
                                                                                                  self.bounds.size.width-borderWidth*2,
                                                                                                  self.bounds.size.height-borderWidth*2)];
    
	self.hostView.allowPinchScaling = YES;
    self.hostView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.hostView.hostedGraph.fill=[CPTFill fillWithColor:[CPTColor clearColor]];
    //	self.layer.masksToBounds = YES;
	[self addSubview:self.hostView];
    
    // 长按事件
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEventListener:)];
    [self.hostView addGestureRecognizer:longPress];
}

- (void)initGraph{
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	graph.plotAreaFrame.masksToBorder = NO;
	self.hostView.hostedGraph = graph;
    graph.paddingBottom = graphPaddingBottom;
	graph.paddingLeft   = graphPaddingLeft;
	graph.paddingTop    = graphPaddingTop;
	graph.paddingRight  = graphPaddingRight;
    [graph applyTheme:theme];

	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	graph.title = self.graphTitle;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
    CPTMutableLineStyle *frameStyle = [CPTMutableLineStyle lineStyle];
	frameStyle.lineWidth = 1;
	frameStyle.lineColor = [CPTColor colorWithComponentRed:255 green:255 blue:255 alpha:0.3];
    graph.plotAreaFrame.borderLineStyle=frameStyle;
}

- (void)initPlot{
    NSArray *allKeys=[self.plotSource allKeys];
    if (!self.plotArray) {
        self.plotArray= [[NSMutableArray alloc] initWithCapacity:allKeys.count];
    }else{
        [self.plotArray removeAllObjects];
    }
}

-(void)initAxes{
    
}

-(CPTColor *)getPlotColor:(CPTPlot *)plot index:(NSInteger)index{
    return [self.defaultColorArray objectAtIndex:index%self.defaultColorArray.count];
}

-(CPTColor *)getPlotColor:(NSInteger)index{
    return [self.defaultColorArray objectAtIndex:index%self.defaultColorArray.count];
}

- (void)createValueAnnotation:(CPTPlot*)plot
{
    if (!self.valueAnnotation) {
        NSNumber *x = [NSNumber numberWithInt:0];
		NSNumber *y = [NSNumber numberWithInt:0];
		NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
		self.valueAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
    }
}

- (void)displayValueTipControl:(CPTPlot*)plot
                      subLayer:(CPTLayer*)layer
                       anchorX:(NSNumber*)anchorX
                       anchorY:(NSNumber*)anchorY;
{
	[self createValueAnnotation:plot];
    self.valueAnnotation.displacement = CGPointMake(0, layer.frame.size.height/2);
	self.valueAnnotation.anchorPlotPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
    [self displayValueTipControl:plot subLayer:layer];
	
}
- (void)displayValueTipControl:(CPTPlot *)plot
                      subLayer:(CPTLayer *)layer
{
    // refuse show tip
    if (!self.tipShow) {
        return;
    }
    
    // Add plot area
    self.valueAnnotation.contentLayer = layer;
    //    [plot.graph.plotAreaFrame.plotArea addAnnotation:self.valueAnnotation];
    [plot.graph addAnnotation:self.valueAnnotation];
    
    // Reset value Annotation frame
    CGFloat offsetY = CGRectGetMaxY(layer.frame) - CGRectGetMaxY(plot.graph.plotAreaFrame.plotArea.frame);
    if (offsetY > 0) {
        if ([layer isKindOfClass:[CPTValueTipRectLayer class]]) {
            if ([plot isKindOfClass:[CPTPieChart class]]) {
                self.valueAnnotation.displacement = CGPointMake(self.valueAnnotation.displacement.x,
                                                                self.valueAnnotation.displacement.y-layer.frame.size.height);
            }
            else {
                if (offsetY > layer.frame.size.height) {
                    self.valueAnnotation.displacement = CGPointMake(0,
                                                                    -offsetY+layer.frame.size.height/2);
                }
                else {
                    self.valueAnnotation.displacement = CGPointMake(0, -layer.frame.size.height/2);
                }
            }
            
            [(CPTValueTipRectLayer*)layer setArrowDirection:UIArrowDirectionUp];
        }
    }
    
    // Add the disappear animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.fromValue = [NSValue valueWithCGRect:CGRectZero];
    animation.toValue = [NSValue valueWithCGRect:self.valueAnnotation.contentLayer.bounds];
    animation.duration = 0.1f;
    animation.fillMode = kCAFillModeForwards;
    [self.valueAnnotation.contentLayer addAnimation:animation forKey:@"bounds"];
}


-(void)dismissValueTipControl
{
    if (self.hostView && self.valueAnnotation) {
        [self.hostView.hostedGraph removeAnnotation:self.valueAnnotation];
        self.valueAnnotation = nil;
    }
    self.selectIndex=-1;
}

-(void)setBorderWidth:(CGFloat)_borderWidth{
    borderWidth=_borderWidth;
    self.layer.borderWidth=borderWidth;
}

- (void)setIsSelected:(BOOL)selected
{
    isSelected = selected;
    if (isSelected) {
        self.layer.borderColor=focusBorderColor.CGColor;
        [self removeGestureRecognizer:tapGestureListener];
    }
    else {
        self.btnInfo.hidden=YES;
        self.layer.borderColor=[UIColor clearColor].CGColor;
        [self addGestureRecognizer:tapGestureListener];
    }    
}

- (void)moveToFrame:(CGRect)frame animation:(BOOL)animation complete:(void (^)(BOOL finished))completion
{
    if (animation) {
        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithCapacity:4];
        [data setValue:self forKey:@"view"];
        [data setValue:[NSValue valueWithCGRect:self.frame] forKey:@"fromFrame"];
        [data setValue:[NSValue valueWithCGRect:frame] forKey:@"toFrame"];
        [data setValue:completion forKey:@"Completion"];
        
        [self.animationHelper commitAnimation:AnimationMoveFrame data:data];
    }
    else {
        self.frame = frame;
    }
}

#pragma mark - Animation
-(void)setNewPlotSource:(NSMutableDictionary *)source withAnimation:(BOOL)animation{
    if (source == nil) {
        return;
    }
    [animationHelper stopAnimation];
    [self dismissValueTipControl];
    
    if (animation) {
        self.oldPlotSource = self.plotSource;
        self.plotSource = source;
        if (!self.plotArray) {
            [self initPlot];
        }
        NSDictionary *dict=[NSDictionary dictionaryWithObject:self.plotArray forKey:@"plotArray"];
        
        [animationHelper commitAnimation:AnimationUpdateData data:dict];
    }
    else {
        self.plotSource = source;
        
        for (CPTPlot *plot in self.plotArray) {
            [plot reloadData];
        }
    }
}

#pragma mark - Tap Gesture Listener
- (void)longPressEventListener:(UILongPressGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self.hostView];
    point.y -= 50;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            [self longPressEventBegan:sender point:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self longPressEventChanged:sender point:point];
            break;
        default:
            [self longPressEventEnd:sender point:point];
            break;
    }
}

- (void)longPressEventBegan:(UILongPressGestureRecognizer *)sender point:(CGPoint)pos
{
    if (!scaleManager) {
        scaleManager = [[ZoomToolView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        scaleManager.zoomBar.hostView = self.hostView;
        scaleManager.tipView = [zoomDelegate createTipView:self];
        [self addSubview:scaleManager];
    }
    
    // 焦点位置是否在图形上
    self.tipShow = NO;
    BOOL exist = [self simulatePointDownEvent:sender point:pos];
    self.tipShow = YES;
    
    scaleManager.hidden = NO;
    scaleManager.touchPoint = pos;
    [self updateZoomTipView:exist];
}

- (void)longPressEventChanged:(UILongPressGestureRecognizer *)sender point:(CGPoint)pos
{
    // 焦点位置是否在图形上
    self.tipShow = NO;
    BOOL exist = [self simulatePointDownEvent:sender point:pos];
    self.tipShow = YES;
    
    // 移动放大镜
    if (scaleManager) {
        scaleManager.touchPoint = pos;
        [self updateZoomTipView:exist];
    }
}

- (void)longPressEventEnd:(UILongPressGestureRecognizer *)sender point:(CGPoint)pos
{
    if (scaleManager) {
        // 放大镜显示，同时焦点处在图形上
        if (scaleManager.hidden == NO) {
            if (scaleManager.tipView && scaleManager.tipView.hidden == NO) {
                [self simulatePointDownEvent:sender point:pos];
            }
        }
        scaleManager.hidden = YES;
    }
}

- (void)updateZoomTipView:(BOOL)active
{
    if (scaleManager && scaleManager.tipView) {
        UIColor *focusColor = [UIColor colorWithCGColor:[self getPlotColor:self.selectIndex].cgColor];
        const CGFloat* colors = CGColorGetComponents(focusColor.CGColor);
        scaleManager.tipBorderColor = [UIColor colorWithRed:colors[0]*0.75 green:colors[1]*0.75 blue:colors[2]*0.75 alpha:1.0];
        scaleManager.tipView.backgroundColor = [UIColor colorWithRed:248/255.0 green:253/255.0 blue:227/255.0 alpha:1.0];
        scaleManager.tipView.bounds = [zoomDelegate resetTipSize:self tipView: scaleManager.tipView];
        if (active) {
            [zoomDelegate relayoutTipView:self tipView:scaleManager.tipView mode:scaleManager.tipMaskMode];
        }
        scaleManager.tipView.hidden = !active;
    }
}

- (BOOL)simulatePointDownEvent:(UILongPressGestureRecognizer*)sender point:(CGPoint)pos
{
    // 转转成图标坐标位置
    CGPoint interactionPoint = pos;
    if (self.hostView.collapsesLayers) {
        interactionPoint.y = self.hostView.frame.size.height - interactionPoint.y;
    }
    else{
        interactionPoint = [self.hostView.layer convertPoint:interactionPoint
                                                     toLayer:self.hostView.hostedGraph];
    }
    
    // 模拟点击事件，确定焦点是否在图形上
    for (CPTPlot *plot in self.plotArray) {
        if ([plot pointingDeviceDownEvent:nil atPoint:interactionPoint]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)tapListener:(UITapGestureRecognizer*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(on_tap:sender:)]) {
        [self.delegate on_tap:self sender:sender];
    }
    if (self.btnInfo.hidden) {
        self.btnInfo.hidden = NO;
        [self bringSubviewToFront:self.btnInfo];
        
        self.isSelected = YES;
    }
}

- (void)touchInfoButtonEvent:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(zoomChartRectInSuperView:)]) {
        [self.parentView addSubview:maskView];
        [self.parentView bringSubviewToFront:self];
        
        originFrame=self.frame;
        UIViewController *controller=(UIViewController *)self.delegate;
        [controller.view bringSubviewToFront:self];
        CGRect newFrame = [self.delegate zoomChartRectInSuperView:self];
        self.btnInfo.hidden = YES;
        self.layer.borderColor=[UIColor clearColor].CGColor;
        [self moveToFrame:newFrame animation:YES complete:^(BOOL finished) {
            
            CGRect frame=groundView.frame;
            CGRect oldFrame=frame;
            oldFrame.size=newFrame.size;
            groundView.frame=oldFrame;
            groundView.center = CGPointMake(CGRectGetMidX(oldFrame), CGRectGetMidY(oldFrame));
            groundView.hidden=NO;
            [UIView animateWithDuration:0.2f animations:^{
                groundView.frame = frame;
                groundView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
            } completion:^(BOOL finished) {
                btnClose.hidden=NO;
                [self bringSubviewToFront:btnClose]; 
            }];
        }];
    }
}

- (void)touchCloseButtonEvent:(id)sender
{
    [maskView removeFromSuperview];
    btnClose.hidden=YES;
    CGRect frame=groundView.frame;
    CGRect newFrame=self.frame;
    newFrame.origin=frame.origin;
    [UIView animateWithDuration:0.2f animations:^{
        groundView.frame = newFrame;
        groundView.center = CGPointMake(CGRectGetMidX(newFrame), CGRectGetMidY(newFrame));
    } completion:^(BOOL finished) {
        groundView.hidden=YES;
        groundView.frame = frame;
        groundView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        [self moveToFrame:originFrame animation:YES complete:^(BOOL finished) {
            self.btnInfo.hidden=NO;
            self.layer.borderColor=focusBorderColor.CGColor;
        }];
    }];
}


@end