//
//  CheckboxView.h
//  CdtsFramework
//
//  Created by 山天 大畜 on 4/05/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomCheckboxViewDelegate <NSObject>

@optional
-(void) checkboxView_check:(id)sender checked:(BOOL)checked;

@end
//自定义单选框
@interface CustomCheckboxView : UIView

@property(assign,nonatomic) id<CustomCheckboxViewDelegate> delegate;


@property(nonatomic,assign) BOOL isChecked;

//设置选中/未选中单选框
- (void)check:(BOOL)checked;
//初始化单选框：位置大小、选中图像、未选中图像
- (id)initWithFrame:(CGRect)frame checkedImg:(NSString *)checkedImg uncheckedImg:(NSString *)uncheckedImg;

@end
