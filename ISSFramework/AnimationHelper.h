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

@interface AnimationHelper : NSObject

@property(assign, nonatomic) double dataIncreasedUpdateData;
@property(assign, nonatomic) double dataIncreasedScale;
@property (assign, nonatomic) double timeIntervalUpdateData;
@property (assign, nonatomic) double timeIntervalScale;
@property (assign, nonatomic) double timeForMoveFrame;
@property (assign, nonatomic) double dataStep;


-(void)commitAnimation:(AnimationType)type data:(NSDictionary *)data;
-(void)stopAnimation;

-(BOOL)isAnimation;

@end
