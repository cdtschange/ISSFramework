//
//  ChartQuartzBaseViewController.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/23/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationHelper.h"
#import "CPTValueTipRectLayer.h"
#import "ZoomToolView.h"

typedef CGRect (^GetValueTipRectBlock)(CPTPlot*,NSInteger,NSNumber*);

@class ChartCPBaseView,ZoomToolView;

@protocol ChartCPBaseViewDelegate <NSObject>

@optional
- (void)on_tap:(ChartCPBaseView *)view sender:(UITapGestureRecognizer*)sender;
- (CGRect)zoomChartRectInSuperView:(ChartCPBaseView*)view;
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index;
@end

@protocol ZoomTipDelegate <NSObject>
@required
- (UIView *)createTipView:(ChartCPBaseView *)view;
- (CGRect)resetTipSize:(ChartCPBaseView *)view tipView:(UIView *)tipView;
- (void)relayoutTipView:(ChartCPBaseView *)view tipView:(UIView *)tipView mode:(UITipViewMaskMode)maskMode;
@end

@protocol DrawValueTipChartDelegate <NSObject>

@optional
// 绘制内容区域
- (void)drawValueTipRect:(ChartCPBaseView *)view layer:(CPTValueTipRectLayer*)layer context:(CGContextRef)context drawRect:(CGRect)rect plot:(CPTPlot *)plot index:(NSInteger)index price:(NSNumber *)price;
@end

@interface ChartCPBaseView: UIView<ValueTipRectLayerDelegate>

@property (assign, nonatomic) double graphPaddingTop;
@property (assign, nonatomic) double graphPaddingBottom;
@property (assign, nonatomic) double graphPaddingLeft;
@property (assign, nonatomic) double graphPaddingRight;

@property (strong, nonatomic) CPTGraphHostingView *hostView;
@property (strong, nonatomic) CPTTheme *theme;

@property (strong, nonatomic) NSString *graphTitle;

@property (strong, nonatomic) NSArray *defaultColorArray;
@property (strong, nonatomic) NSMutableArray *plotArray;
@property (strong, nonatomic) NSMutableDictionary *plotSource;
@property (strong, nonatomic) NSMutableDictionary *oldPlotSource;

@property (nonatomic, strong) CPTPlotSpaceAnnotation *valueAnnotation;
@property (strong, nonatomic) AnimationHelper *animationHelper;
@property (assign, nonatomic) GetValueTipRectBlock getValueTipRectBlock;
@property (assign, nonatomic) id<DrawValueTipChartDelegate> drawValueTipChartDelegate;
@property (assign, nonatomic) id<ChartCPBaseViewDelegate> delegate;
@property (assign, nonatomic) id<ZoomTipDelegate> zoomDelegate;

@property (strong, nonatomic) CPTPlot *selectPlot;
@property (assign, nonatomic) NSInteger selectIndex;
@property (strong, nonatomic) NSNumber *selectPrice;
@property (assign, nonatomic) BOOL tipShow;

@property (strong, nonatomic) UIColor *focusBorderColor;
@property (assign, nonatomic) BOOL isSelected;
@property (assign, nonatomic) CGFloat borderWidth;
@property (assign, nonatomic) double tipArrowLength;
@property (assign, nonatomic) double  selectDashPattern;
@property (assign, nonatomic) double  selectDashLineWidth;

@property (strong, nonatomic) UIButton *btnInfo;
@property (strong, nonatomic) UIButton *btnClose;
@property (strong, nonatomic) UIView *groundView;
@property (strong, nonatomic) ZoomToolView *scaleManager;
@property (strong, nonatomic) UIView *parentView;

@property (assign, nonatomic) BOOL isFocusColorSupported;
@property (strong, nonatomic)UIView *maskView;


- (void)initChart;
- (void)initHostView;
- (void)initGraph;
- (void)initPlot;
- (void)initAxes;

- (void)setNewPlotSource:(NSMutableDictionary *)source withAnimation:(BOOL)animation;

- (CPTColor *)getPlotColor:(NSInteger)index;
- (CPTColor *)getPlotColor:(CPTPlot *)plot index:(NSInteger)index;
- (void)moveToFrame:(CGRect)frame animation:(BOOL)animation complete:(void (^)(BOOL finished))completion;
- (void)createValueAnnotation:(CPTPlot*)plot;
- (void)displayValueTipControl:(CPTPlot*)plot
                      subLayer:(CPTLayer*)layer
                       anchorX:(NSNumber*)anchorX
                       anchorY:(NSNumber*)anchorY;
- (void)displayValueTipControl:(CPTPlot *)plot
                      subLayer:(CPTLayer *)layer;
-(void)dismissValueTipControl;

- (void)touchInfoButtonEvent:(id)sender;

@end
