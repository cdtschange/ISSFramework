//
//  UIViewController+MJPopupViewController.h
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 martinjuhasz.de. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DummyClass_UIViewController_MJPopupViewController {} 
@end 

typedef enum {
    MJPopupViewAnimationSlideBottomTop = 1,
    MJPopupViewAnimationSlideRightLeft,
    MJPopupViewAnimationSlideBottomBottom,
    MJPopupViewAnimationFade
} MJPopupViewAnimation;

//动画形式弹出新层，背景遮罩
@interface UIViewController (MJPopupViewController)

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(MJPopupViewAnimation)animationType;
- (void)dismissPopupViewControllerWithanimationType:(MJPopupViewAnimation)animationType;

@end