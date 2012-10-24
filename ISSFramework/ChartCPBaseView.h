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

//add by wj
enum SourceType
{
    BARCHART = 1000,
    SCATTERCHART,
    PIECHART
};

/**
 提示框大小
 */
typedef CGRect (^GetValueTipRectBlock)(CPTPlot*,NSInteger,NSNumber*);

// CLASS DECLARATION
@class ChartCPBaseView,ZoomToolView;

/**
 chart view delegate
 */
@protocol ChartCPBaseViewDelegate <NSObject>
@optional
// 单击图表
- (void)on_tap:(ChartCPBaseView *)view sender:(UITapGestureRecognizer*)sender;
// 图表详情展开后区域
- (CGRect)zoomChartRectInSuperView:(ChartCPBaseView*)view;
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index;
@end

/**
 zoom bar delegate
 */
@protocol ZoomTipDelegate <NSObject>
@required
// create zoom view
- (UIView *)createTipView:(ChartCPBaseView *)view;
// tip view frame in zoom view
- (CGRect)resetTipSize:(ChartCPBaseView *)view tipView:(UIView *)tipView;
// relayout zoom view 
- (void)relayoutTipView:(ChartCPBaseView *)view tipView:(UIView *)tipView mode:(UITipViewMaskMode)maskMode;
@end

/**
 value tip view
 */
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

@property (strong, nonatomic) CPTGraphHostingView *hostView;  // graph host view
@property (strong, nonatomic) CPTTheme *theme; // graph theme

@property (strong, nonatomic) NSString *graphTitle; // title
@property (strong, nonatomic) CPTTextStyle *graphTitleStyle; // title style

@property (strong, nonatomic) NSArray *defaultColorArray; // color array
@property (strong, nonatomic) NSMutableArray *plotArray; // plot array
@property (strong, nonatomic) NSMutableDictionary *plotSource; // new data source
@property (strong, nonatomic) NSMutableDictionary *oldPlotSource; // old data source

@property (nonatomic, strong) CPTPlotSpaceAnnotation *valueAnnotation; // tip annotation
@property (strong, nonatomic) AnimationHelper *animationHelper; // animation engine
@property (assign, nonatomic) GetValueTipRectBlock getValueTipRectBlock; 
@property (assign, nonatomic) id<DrawValueTipChartDelegate> drawValueTipChartDelegate;
@property (assign, nonatomic) id<ChartCPBaseViewDelegate> delegate;
@property (assign, nonatomic) id<ZoomTipDelegate> zoomDelegate;

@property (strong, nonatomic) CPTPlot *selectPlot; // focus plot
@property (assign, nonatomic) NSInteger selectIndex; // focus plot data index
@property (strong, nonatomic) NSNumber *selectPrice; // focus data value
@property (assign, nonatomic) BOOL tipShow; // default YES

@property (strong, nonatomic) UIColor *focusBorderColor; // the color when the view is tapped
@property (assign, nonatomic) BOOL isSelected; // the view seleted, default no
@property (assign, nonatomic) CGFloat borderWidth; // the view layer border width
@property (assign, nonatomic) double tipArrowLength; // value tip arrow length
@property (assign, nonatomic) double  selectDashPattern; 
@property (assign, nonatomic) double  selectDashLineWidth;

@property (strong, nonatomic) UIButton *btnInfo; // information touch button
@property (strong, nonatomic) UIButton *btnClose; // close touch button
@property (strong, nonatomic) UIView *groundView; 
@property (strong, nonatomic) ZoomToolView *scaleManager; // zoom manager 
@property (strong, nonatomic) UIView *parentView; 

@property (assign, nonatomic) BOOL isFocusColorSupported;
@property (strong, nonatomic) UIView *maskView; // mask view

/**
 图表初始化
 */
- (void)initChart;
- (void)initHostView;
- (void)initGraph;
- (void)initPlot;
- (void)initAxes;

/**
 设置图表数据源
 @param source 数据源 key:pie,bar,scatter  object:NSDictionary
 @param animation 是否动画显示
 @return void
 */
- (void)setNewPlotSource:(NSMutableDictionary *)source withAnimation:(BOOL)animation;

/**
 获取图表填充色
 @param index 图标索引
 @return CPTColor 
 */
- (CPTColor *)getPlotColor:(NSInteger)index;
- (CPTColor *)getPlotColor:(CPTPlot *)plot index:(NSInteger)index;

/**
 缩放图表区域
 @param frame 目标区域
 @animation 是否支持动画
 @completion 动画结束回调
 */
- (void)moveToFrame:(CGRect)frame animation:(BOOL)animation complete:(void (^)(BOOL finished))completion;

/**
 创建提示框 
 @param plot 目标图表
 */
- (void)createValueAnnotation:(CPTPlot*)plot;

/**
 显示提示框
 @param plot 目标图表
 @param layer 内容区域
 @param anchorX x轴位置
 @param anchorY y轴位置
 */
- (void)displayValueTipControl:(CPTPlot*)plot
                      subLayer:(CPTLayer*)layer
                       anchorX:(NSNumber*)anchorX
                       anchorY:(NSNumber*)anchorY;
- (void)displayValueTipControl:(CPTPlot *)plot
                      subLayer:(CPTLayer *)layer;

/**
 隐藏提示框
 */
-(void)dismissValueTipControl;

/**
 图标详情
 */
- (void)touchInfoButtonEvent:(id)sender;

@end
