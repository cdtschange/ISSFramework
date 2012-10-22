//
//  ZoomToolBar.m
//  IPChartDemo
//
//  Created by ISS on 11/09/12.
//  Copyright (c) 2012 __iSoftStone__. All rights reserved.
//
// CLASS INCLUDES
#import "ZoomToolBar.h"

// CONST DEIFNE
CGFloat const kDefaultValueScale = 2.0f;

@interface ZoomToolBar()
@end

@implementation ZoomToolBar
@synthesize scaleX, scaleY, touchPoint, hostView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 放大参数设置
        scaleX = kDefaultValueScale;
        scaleY = kDefaultValueScale;
        
        // 圆形
        self.layer.masksToBounds    = YES;
        self.layer.borderWidth      = 0;
        self.layer.backgroundColor  = [UIColor lightGrayColor].CGColor;
        self.layer.cornerRadius     = frame.size.width/2;
        
        // 放大镜
        UIImageView *circle = [[UIImageView alloc] initWithFrame:self.bounds];
        circle.image = [UIImage imageNamed:@"icon_zoom.png"];
        [self addSubview:circle];
    }
    return self;
}

- (void)setTouchPoint:(CGPoint)point
{
    touchPoint = point;
    self.center = touchPoint;
    [self setNeedsDisplay];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch    = [touches anyObject];
    CGPoint oldPoint  = [touch previousLocationInView:self];
    CGPoint newPoint  = [touch locationInView:self];
    
    // 重定位视图位置
    self.center       = CGPointMake(self.center.x+(newPoint.x-oldPoint.x), 
                                    self.center.y+(newPoint.y-oldPoint.y));
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context,1*(self.frame.size.width*0.5),1*(self.frame.size.height*0.5));
	CGContextScaleCTM(context, self.scaleX, self.scaleY);
	CGContextTranslateCTM(context,-1*(self.center.x),-1*(self.center.y));
	[self.hostView.layer renderInContext:context];
}

@end
