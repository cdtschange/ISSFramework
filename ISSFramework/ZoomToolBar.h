//
//  ZoomToolBar.h
//  IPChartDemo
//
//  Created by ISS on 11/09/12.
//  Copyright (c) 2012 __iSoftStone__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomToolBar : UIView

@property (assign, nonatomic) CGFloat scaleX;
@property (assign, nonatomic) CGFloat scaleY;
@property (assign, nonatomic) CGPoint touchPoint;
@property (assign, nonatomic) UIView *hostView;

@end
