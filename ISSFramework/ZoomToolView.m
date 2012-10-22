//
//  ZoomToolView.m
//  IPChartDemo
//
//  Created by ISS on 11/09/12.
//  Copyright (c) 2012 __iSoftStone__. All rights reserved.
//
// CLASS INCLUDES
#import "ZoomToolView.h"

// CONST DEFINE
CGFloat const kDefaultBorderWidth = 2.0f;
CGFloat const kDefaultCornerRadius = 5.0f;

@interface ZoomToolView()
- (CGPoint)checkPointValid:(CGPoint)point;
- (void)relayoutTipView;
@end

@implementation ZoomToolView
@synthesize zoomBar, tipView, touchPoint, tipMaskMode;
@synthesize tipBorderColor, tipBorderWidth, tipCornerRadius;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 背景透明
        self.backgroundColor = [UIColor clearColor];
        tipBorderWidth = kDefaultBorderWidth;
        tipBorderColor = [UIColor blackColor];
        tipCornerRadius = kDefaultCornerRadius;
        
        // 创建放大镜
        zoomBar = [[ZoomToolBar alloc] initWithFrame:self.bounds];
        [self addSubview:zoomBar];
    }
    return self;
}

- (void)setTipView:(UIView *)tip
{
    if (tipView) {
        [tipView removeFromSuperview];
    }
    
    // 添加到视图中
    tipView = tip;
    [self relayoutTipView];
    [self addSubview:tipView];
    
    // 始终保持放大镜在最前端
    [self bringSubviewToFront:zoomBar];
}

- (void)setTipBorderColor:(UIColor *)borderColor
{
    tipBorderColor = borderColor;
    [self relayoutTipView];
}

- (void)setTipBorderWidth:(CGFloat)borderWidth
{
    tipBorderWidth = borderWidth;
    [self relayoutTipView];
}

- (void)setTipCornerRadius:(CGFloat)cornerRadius
{
    tipCornerRadius = cornerRadius;
    [self relayoutTipView];
}

- (void)setTouchPoint:(CGPoint)point
{
    // 矫正 不能超过视图区域
    CGPoint pos = [self checkPointValid:point];
    if (CGPointEqualToPoint(touchPoint, pos)) {
        return;
    }
    touchPoint = pos;
    self.zoomBar.touchPoint = touchPoint;
    // TIP控件显示位置
    if (self.tipView) {
        CGRect viewFrame = self.zoomBar.frame;
        
        // 以父视图中点为界
        if (viewFrame.origin.x+viewFrame.size.width/2>CGRectGetMidX(self.superview.bounds)) {
            self.tipView.frame = CGRectMake(viewFrame.origin.x+viewFrame.size.width/2-self.tipView.frame.size.width,
                                            viewFrame.origin.y,
                                            self.tipView.frame.size.width,
                                            self.tipView.frame.size.height);
            tipMaskMode = UITipViewMaskRightMode;
        }
        else {
            self.tipView.frame = CGRectMake(viewFrame.origin.x+viewFrame.size.width/2,
                                            viewFrame.origin.y,
                                            self.tipView.frame.size.width,
                                            self.tipView.frame.size.height);
            tipMaskMode = UITipViewMaskLeftMode;
        }
    }
}

- (void)relayoutTipView
{
    if (self.tipView) {
        self.tipView.layer.cornerRadius = self.tipCornerRadius;
        self.tipView.layer.borderColor = self.tipBorderColor.CGColor;
        self.tipView.layer.borderWidth = self.tipBorderWidth;
    }
}

- (CGPoint)checkPointValid:(CGPoint)point
{
    CGRect containerFrame = self.superview.bounds;
    CGSize curSize = self.bounds.size;
    containerFrame = CGRectMake(containerFrame.origin.x+curSize.width/2.0, containerFrame.origin.y+curSize.height/2.0, containerFrame.size.width-curSize.width, containerFrame.size.height-curSize.height);
    if (CGRectContainsPoint(containerFrame, point)) {
        return point;
    }
    
    if (point.x > CGRectGetMaxX(containerFrame)) {
        point.x = CGRectGetMaxX(containerFrame);
    }
    if (point.x < CGRectGetMinX(containerFrame)) {
        point.x = CGRectGetMinX(containerFrame);
    }
    if (point.y > CGRectGetMaxY(containerFrame)) {
        point.y = CGRectGetMaxY(containerFrame);
    }
    if (point.y < CGRectGetMinY(containerFrame)) {
        point.y = CGRectGetMinY(containerFrame);
    }
    return point;
}

@end
