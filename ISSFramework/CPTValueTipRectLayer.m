//
//  CPTValueTipRectLayer.m
//  BIChartDemo
//
//  Created by Wei Mao on 8/28/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "CPTValueTipRectLayer.h"

#define kArrowWidth 2.0f
#define KRoundRectRadius 4.0f
#define kArrowRadius 4.0f

@interface CPTValueTipRectLayer (PrivateMethod)
-(void)drawBorder:(CGContextRef)context drawRect:(CGRect)rect;
-(void)drawArrow:(CGContextRef)context drawRect:(CGRect)rect;
@end

@implementation CPTValueTipRectLayer
@synthesize borderColor, borderWidth, arrowLength, drawerDelegate,arrowDirection;

- (id)initWithFrame:(CGRect)newFrame arrowLength:(CGFloat)len
{
    self = [super initWithFrame:CGRectMake(newFrame.origin.x,
                                           newFrame.origin.y-len,
                                           newFrame.size.width,
                                           newFrame.size.height+len)];
    if (self) {
        borderColor = [UIColor whiteColor];
        arrowLength = len;
        borderWidth = 2.0f;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        borderColor = [[aDecoder decodeObjectForKey:@"CPTValueTipRectLayer.borderColor"] copy];
        borderWidth = [aDecoder decodeFloatForKey:@"CPTValueTipRectLayer.borderWidth"];
        drawerDelegate = [aDecoder decodeObjectForKey:@"CPTValueTipRectLayer.drawerDelegate"];
        arrowLength = [aDecoder decodeFloatForKey:@"CPTValueTipRectLayer.arrowLength"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.borderColor forKey:@"CPTValueTipRectLayer.borderColor"];
    [aCoder encodeFloat:self.borderWidth forKey:@"CPTValueTipRectLayer.borderWidth"];
    [aCoder encodeFloat:self.arrowLength forKey:@"CPTValueTipRectLayer.arrowLength"];
    [aCoder encodeObject:self.drawerDelegate forKey:@"CPTValueTipRectLayer.drawerDelegate"];
}

- (void)setArrowLength:(CGFloat)arrowLen
{
    if (arrowLength == arrowLen) {
        return;
    }
    
    CGRect curFrame = self.frame;
    self.frame = CGRectMake(curFrame.origin.x,
                            curFrame.origin.y + (arrowLen - arrowLength),
                            curFrame.size.width,
                            curFrame.size.height + (arrowLen - arrowLength));
    arrowLength = arrowLen;
}

#pragma mark- private method

- (void)drawBorder:(CGContextRef)context drawRect:(CGRect)rect
{
    CGFloat offsetY = self.arrowDirection == UIArrowDirectionDown?0:self.arrowLength;
    CGContextSetFillColorWithColor(context, self.borderColor.CGColor);
    AddRoundedRectPath(context,
                       CGRectMake(0,
                                  offsetY,
                                  rect.size.width,
                                  rect.size.height-self.arrowLength),
                       KRoundRectRadius);
    CGContextFillPath(context);
    
    // 绘制内容区域
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:248/255.0 green:253/255.0 blue:227/255.0 alpha:1.0].CGColor);
//    CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
    AddRoundedRectPath(context,
                       CGRectMake(self.borderWidth,
                                  self.borderWidth+offsetY,
                                  rect.size.width-2*self.borderWidth,
                                  rect.size.height-2*self.borderWidth-self.arrowLength),
                       KRoundRectRadius);
    CGContextFillPath(context);
}


- (void)drawArrow:(CGContextRef)context drawRect:(CGRect)rect
{
    // 绘制线条
    CGPoint points[2];
    if (self.arrowDirection == UIArrowDirectionDown) {
        points[0] = CGPointMake(rect.size.width/2, rect.size.height - self.arrowLength);
        points[1] = CGPointMake(rect.size.width/2, rect.size.height);
    }
    else {
        points[0] = CGPointMake(rect.size.width/2, 0);
        points[1] = CGPointMake(rect.size.width/2, self.arrowLength);
    }
    
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetLineWidth(context, kArrowWidth);
    CGContextAddLines(context, points, 2);
    CGContextStrokePath(context);
    // 绘制圆点
    CGContextSetFillColorWithColor(context, self.borderColor.CGColor);
    if (self.arrowDirection == UIArrowDirectionDown) {
        CGContextAddArc(context, points[0].x,
                        points[1].y-kArrowRadius,
                        kArrowRadius, 0.0f, 2*M_PI, 1);
    }
    else {
        CGContextAddArc(context, points[0].x,
                        points[0].y+kArrowRadius,
                        kArrowRadius, 0.0f, 2*M_PI, 1);
    }
    CGContextFillPath(context);
}

#pragma mark- CPTLayer
- (void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.hidden ) {
		return;
	}
    
	[super renderAsVectorInContext:context];
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSetShouldAntialias(context, YES);
    
    
    // 绘制边框
    [self drawBorder:context drawRect:self.bounds];
    
    // 绘制内容区域
    if ([drawerDelegate respondsToSelector:@selector(drawContentRect:context:drawRect:)]) {
        [drawerDelegate drawContentRect:self
                                context:context
                               drawRect:CGRectMake(0,
                                                   self.arrowDirection==UIArrowDirectionDown?0:self.arrowLength,
                                                   self.bounds.size.width,
                                                   self.bounds.size.height - self.arrowLength)];
    }
    
    // 绘制箭头
    [self drawArrow:context drawRect:self.bounds];
	CGContextRestoreGState(context);
}

@end
