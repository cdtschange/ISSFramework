//
//  CheckboxView.m
//  CdtsFramework
//
//  Created by 山天 大畜 on 4/05/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "CustomCheckboxView.h"

@interface CustomCheckboxView()
{
    UIButton * isSelectedBtn;
    UIImage * m_unSelectedImg;
    UIImage * m_selectedImg;
}

@end

@implementation CustomCheckboxView

@synthesize isChecked;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame checkedImg:(NSString *)checkedImg uncheckedImg:(NSString *)uncheckedImg {
    
    self = [super initWithFrame:frame];
    if (self) {
		NSString * selImgPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:checkedImg];
		NSString * unselImgPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:uncheckedImg];
		
		m_unSelectedImg = [[UIImage alloc] initWithContentsOfFile:unselImgPath];
		m_selectedImg = [[UIImage alloc] initWithContentsOfFile:selImgPath];
		
		isSelectedBtn = [[UIButton alloc] initWithFrame:self.bounds];
		[isSelectedBtn setBackgroundImage:m_unSelectedImg forState:UIControlStateNormal];
		[isSelectedBtn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:isSelectedBtn];
		self.isChecked = NO;
		
    }
    return self;
}

- (void)btnPressed:(UIButton *)btn
{
	if (!btn.selected) {
		[btn setBackgroundImage:m_selectedImg forState:UIControlStateNormal];
		btn.selected = YES;
	}else {
		[btn setBackgroundImage:m_unSelectedImg forState:UIControlStateNormal];
		btn.selected = NO;
	}
	self.isChecked  = btn.selected;
    
    if (delegate&&[delegate respondsToSelector:@selector(checkboxView_check:checked:)]) {
        [delegate checkboxView_check:self checked:self.isChecked];
    }
}

- (void)check:(BOOL)checked
{
	self.isChecked = checked;
	isSelectedBtn.selected = checked;
	if (self.isChecked) {
		[isSelectedBtn setBackgroundImage:m_selectedImg forState:UIControlStateNormal];
	}else {
		[isSelectedBtn setBackgroundImage:m_unSelectedImg forState:UIControlStateNormal];
	}
    if (delegate&&[delegate respondsToSelector:@selector(checkboxView_check:checked:)]) {
        [delegate checkboxView_check:self checked:self.isChecked];
    }
}


- (void)dealloc {
	isSelectedBtn=nil;
    m_selectedImg=nil;
    m_unSelectedImg=nil;
    delegate=nil;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
