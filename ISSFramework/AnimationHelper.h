//
//  AnimationHelper.h
//  BIChartDemo
//
//  Created by Wei Mao on 8/27/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    /**
     更新数据动画
     */
    AnimationUpdateData = 1,
    
    /**
     放大缩小动画
     */
    AnimationScale = 2,
    
    /**
     移动并且放大整个表图
     */
    AnimationMoveFrame = 3,
    
} AnimationType;

/**
 图表动画控制引擎
 */
@interface AnimationHelper : NSObject

@property(assign, nonatomic) double dataIncreasedUpdateData;  // 数据更新值
@property(assign, nonatomic) double dataIncreasedScale;       // 缩放更新值
@property (assign, nonatomic) double timeIntervalUpdateData;  // 数据更新刷新时间间隔
@property (assign, nonatomic) double timeIntervalScale;       // 图表内容区域缩放刷新时间间隔
@property (assign, nonatomic) double timeForMoveFrame;        // 图标区域缩放刷新时间间隔
@property (assign, nonatomic) double dataStep;                // 数据步长

/**
 动画是否正在运行
 */
-(BOOL)isAnimation;

/**
 开始执行动画
 @param type 动画类型
 @param data 动画参数
 @return void
 */
-(void)commitAnimation:(AnimationType)type data:(NSDictionary *)data;

/**
 停止动画
 */
-(void)stopAnimation;

@end
