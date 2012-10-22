//
//  ZoomToolView.h
//  IPChartDemo
//
//  Created by ISS on 11/09/12.
//  Copyright (c) 2012 __iSoftStone__. All rights reserved.
//

// SYSTEM INCLUDES
#import <UIKit/UIKit.h>

#import "ZoomToolBar.h"

typedef enum{
    UITipViewMaskLeftMode,
    UITipViewMaskRightMode
} UITipViewMaskMode;

@interface ZoomToolView : UIView

@property (strong, nonatomic) ZoomToolBar *zoomBar;
@property (strong, nonatomic) UIView *tipView;
@property (assign, nonatomic) CGPoint touchPoint;
@property (readonly, nonatomic) UITipViewMaskMode tipMaskMode;

@property (strong, nonatomic) UIColor *tipBorderColor;
@property (assign, nonatomic) CGFloat tipBorderWidth;
@property (assign, nonatomic) CGFloat tipCornerRadius;
@end