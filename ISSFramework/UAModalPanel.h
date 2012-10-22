//
//  UAModalDisplayPanelView.h
//  UAModalPanel
//
//  Created by Matt Coneybeare on 1/8/12.
//  Copyright (c) 2012 Urban Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UARoundedRectView.h"

#define IMG_UIMODALPANNEL_CLOSEBUTTON @"close.png"

// Logging Helpers
//动画从点击的位置弹出新层，带关闭按钮，背景遮罩
@class UAModalPanel;

@protocol UAModalPanelDelegate
@optional
- (void)willShowModalPanel:(UAModalPanel *)modalPanel;
- (void)didShowModalPanel:(UAModalPanel *)modalPanel;
- (BOOL)shouldCloseModalPanel:(UAModalPanel *)modalPanel;
- (void)willCloseModalPanel:(UAModalPanel *)modalPanel;
- (void)didCloseModalPanel:(UAModalPanel *)modalPanel;
@end

typedef void (^UAModalDisplayPanelEvent)(UAModalPanel* panel);
typedef void (^UAModalDisplayPanelAnimationComplete)(BOOL finished);

@interface UAModalPanel : UIView {	
	NSObject<UAModalPanelDelegate>	*delegate;
	
	UIView		*contentContainer;
	UIView		*roundedRect;
	UIButton	*closeButton;
	UIView		*contentView;
	
	CGPoint		startEndPoint;
	
    NSInteger   closeBtnPosition;
	CGFloat		outerHMargin;
	CGFloat		outerVMargin;
	CGFloat		innerHMargin;
	CGFloat		innerVMargin;
	UIColor		*borderColor;
	CGFloat		borderWidth;
	CGFloat		cornerRadius;
	UIColor		*contentColor;
	BOOL		shouldBounce;
	
}

@property (nonatomic, assign) NSObject<UAModalPanelDelegate>	*delegate;


@property (nonatomic, retain) UIView		*contentContainer;
@property (nonatomic, retain) UIView		*roundedRect;
@property (nonatomic, retain) UIButton		*closeButton;
@property (nonatomic, retain) UIView		*contentView;

@property (nonatomic, assign) NSInteger		closeBtnPosition;
// Margin between edge of container frame and panel. Default = 20.0
@property (nonatomic, assign) CGFloat		outerHMargin;
@property (nonatomic, assign) CGFloat		outerVMargin;
// Margin between edge of panel and the content area. Default = 20.0
@property (nonatomic, assign) CGFloat		innerHMargin;
@property (nonatomic, assign) CGFloat       innerVMargin;
// Border color of the panel. Default = [UIColor whiteColor]
@property (nonatomic, retain) UIColor		*borderColor;
// Border width of the panel. Default = 1.5f
@property (nonatomic, assign) CGFloat		borderWidth;
// Corner radius of the panel. Default = 4.0f
@property (nonatomic, assign) CGFloat		cornerRadius;
// Color of the panel itself. Default = [UIColor colorWithWhite:0.0 alpha:0.8]
@property (nonatomic, retain) UIColor		*contentColor;
// Shows the bounce animation. Default = YES
@property (nonatomic, assign) BOOL			shouldBounce;

@property (readwrite, copy)	UAModalDisplayPanelEvent onClosePressed;

- (void)show;
- (void)showFromPoint:(CGPoint)point;
- (void)hide;
- (void)hideWithOnComplete:(UAModalDisplayPanelAnimationComplete)onComplete;

- (CGRect)roundedRectFrame;
- (CGRect)closeButtonFrame;
- (CGRect)contentViewFrame;

@end
