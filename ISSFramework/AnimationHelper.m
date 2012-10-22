//
//  AnimationHelper.m
//  BIChartDemo
//
//  Created by Wei Mao on 8/27/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "AnimationHelper.h"
#import "PieChartCPView.h"

@interface AnimationHelper()
{
    NSTimer *timer;
}

@end

@implementation AnimationHelper
@synthesize dataIncreasedScale;
@synthesize dataIncreasedUpdateData;
@synthesize timeIntervalScale;
@synthesize timeIntervalUpdateData;
@synthesize timeForMoveFrame;
@synthesize dataStep;

-(id)init{
    if (self=[super init]) {
        self.dataIncreasedScale=1;
        self.dataIncreasedUpdateData=1;
        self.timeIntervalUpdateData=0.01;
        self.timeIntervalScale=0.01;
        self.timeForMoveFrame=0.4;
        self.dataStep=0.1;
    }
    return self;
}

-(void)commitAnimation:(AnimationType)type data:(NSDictionary *)data
{
    switch (type) {
        case AnimationUpdateData:
            self.dataIncreasedUpdateData=dataStep;
            timer = [NSTimer timerWithTimeInterval:self.timeIntervalUpdateData
                                            target:self
                                            selector:@selector(doAnimationUpdateData:)
                                            userInfo:data
                                            repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            break;
        case AnimationScale:
            self.dataIncreasedScale=1;
            timer = [NSTimer timerWithTimeInterval:self.timeIntervalScale
                                            target:self
                                            selector:@selector(doAnimationScale:)
                                            userInfo:data
                                            repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            break;
        case AnimationMoveFrame:
            [self doAnimationMoveFrame:data];
            break;
        default:
            break;
    }
    
}
-(void)stopAnimation
{
    if (timer) {
        [timer invalidate];
        timer = nil;
        self.dataIncreasedScale=1;
        self.dataIncreasedUpdateData=1;
    }
}


-(BOOL)isAnimation
{
    if (timer) {
        return [timer isValid];
    }
    
    return NO;
}

-(void)doAnimationUpdateData:(NSTimer *)theTimer{
    NSDictionary *data=theTimer.userInfo;
    if (data) {
        NSArray *plotArray=[data objectForKey:@"plotArray"];
        for (CPTPlot *plot in plotArray) {
            self.dataIncreasedUpdateData += self.dataStep;
            if (self.dataIncreasedUpdateData >= 1.0) {
                [timer invalidate];
                self.dataIncreasedUpdateData = 1.0;
            }
//            [CATransaction begin];
//            [CATransaction setAnimationDuration:0.5];
//
//            CABasicAnimation *arcAnimation = [CABasicAnimation animationWithKeyPath:@"SmoothAnimation"];
////            NSNumber *currentAngle = oldNumber;
//            
//            [arcAnimation setFromValue:@0];
//            [arcAnimation setToValue:@1];
////            [arcAnimation setDelegate:delegate];
//            [arcAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
//            [plot addAnimation:arcAnimation forKey:@"SmoothAnimation"];
//            [plot setValue:@1 forKey:@"SmoothAnimation"];
//            [CATransaction commit];
            
            [plot reloadData];
        }
    }
}

-(void)doAnimationScale:(NSTimer *)theTimer{
    NSDictionary *data=theTimer.userInfo;
    if (data) {
        CGPoint interactionPoint = [[data valueForKey:@"point"] CGPointValue];
        CPTGraphHostingView *hostView = [data valueForKey:@"hostView"];
        double scaleValue = [[data valueForKey:@"scaleValue"] doubleValue];
        
        double step=dataStep;
        double tempValue=1;
        // 放大
        if (scaleValue > 1.0f) {
            if (dataIncreasedScale > scaleValue) {
                tempValue = scaleValue/(dataIncreasedScale-step);
                [self stopAnimation];
            }else{
                tempValue=dataIncreasedScale/(dataIncreasedScale-step);
            }
            self.dataIncreasedScale += step;
        }
        // 缩小
        else {
            if (dataIncreasedScale < scaleValue) {
                tempValue = scaleValue/(dataIncreasedScale+step);
                [self stopAnimation];
            }else{
                tempValue=dataIncreasedScale/(dataIncreasedScale+step);
            }
            self.dataIncreasedScale -= step;
            
        }
        
        for ( CPTPlotSpace *space in hostView.hostedGraph.allPlotSpaces ) {
            if ( space.allowsUserInteraction ) {
                [space scaleBy:tempValue aboutPoint:interactionPoint];
            }
        }
    }
}

-(void)doAnimationMoveFrame:(NSDictionary *)data{
    if (data) {
        UIView *view     = [data valueForKey:@"view"];
        CGRect fromRect = [[data valueForKey:@"fromFrame"] CGRectValue];
        CGRect toRect   = [[data valueForKey:@"toFrame"] CGRectValue];
        void(^completion)(BOOL finished)  = [data valueForKey:@"Completion"];
        
        CGFloat tx = toRect.size.width/fromRect.size.width;
        CGFloat ty = toRect.size.height/fromRect.size.height;
        view.frame = toRect;
        CGAffineTransform newTransform = CGAffineTransformScale(view.transform, 1/tx, 1/ty);
        [view setTransform:newTransform];
        view.center = CGPointMake(CGRectGetMidX(fromRect), CGRectGetMidY(fromRect));
        view.alpha = 0.3;
        [UIView animateWithDuration:.1 animations:^{
            view.alpha = 1;
        }];
        
        [UIView animateWithDuration:self.timeForMoveFrame animations:^{
            CGAffineTransform newTransform = CGAffineTransformScale(view.transform, tx, ty);
            [view setTransform:newTransform];
            view.center = CGPointMake(CGRectGetMidX(toRect), CGRectGetMidY(toRect));
            if ([view isKindOfClass:[PieChartCPView class]]) {
                PieChartCPView *cview=(PieChartCPView *)view;
                CPTPieChart * plot=((CPTPieChart *)[cview.plotArray objectAtIndex:0]);
                plot.pieRadius=MIN(toRect.size.width,toRect.size.height)*0.4;
                plot.labelOffset = 0;
                [plot positionLabelAnnotation:cview.valueAnnotation forIndex:cview.selectIndex];
                plot.labelOffset = -plot.pieRadius*2/3;
                CGPoint displace = cview.valueAnnotation.displacement;
                displace = CGPointMake(displace.x, displace.y+cview.valueAnnotation.contentLayer.frame.size.height/2);
                cview.valueAnnotation.displacement = displace;
                CPTLayer *layer = cview.valueAnnotation.contentLayer;
                if (CGRectGetMaxY(layer.frame) > CGRectGetMaxY(toRect)) {
                    if ([layer isKindOfClass:[CPTValueTipRectLayer class]]) {
                        if ([plot isKindOfClass:[CPTPieChart class]]) {
                            cview.valueAnnotation.displacement = CGPointMake(cview.valueAnnotation.displacement.x,
                                                                            cview.valueAnnotation.displacement.y-layer.frame.size.height);
                        }
                        else {
                            cview.valueAnnotation.displacement = CGPointMake(0, -layer.frame.size.height/2);
                        }
                        [(CPTValueTipRectLayer*)layer setArrowDirection:UIArrowDirectionUp];
                    }
                }else{
                    [(CPTValueTipRectLayer*)layer setArrowDirection:UIArrowDirectionDown];
                }
            }
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];

    }
}


@end
