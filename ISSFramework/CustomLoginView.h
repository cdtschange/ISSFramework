//
//  LoginView.h
//  CdtsFramework
//
//  Created by 山天 大畜 on 4/05/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//
#define LOGIN_DATA_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"iss_login_data.db"]
#define USER_NAME_KEY @"UserName"
#define USER_PWD_KEY @"UserPassword"
#define USER_REMEMBER_NAME_KEY @"RememberName"
#define USER_REMEMBER_PWD_KEY @"RememberPassword"
#define USER_AUTO_LOGIN_KEY @"IsAutoLogin"

#import <UIKit/UIKit.h>

#import "CustomCheckboxView.h"

@protocol CustomLoginViewDelegate <NSObject>

@required
-(void) loginView_login:(NSString *)name withPassword:(NSString *)password;
@optional
-(void) loginView_cancel;
-(void) loginView_forgetPwd:(NSString *)name;
-(void) loginView_changePwd:(NSString *)name;

@end

@class CustomCheckboxView;

@interface CustomLoginView : UIView<UITextFieldDelegate,CustomCheckboxViewDelegate>

@property(assign,nonatomic) id<CustomLoginViewDelegate> delegate;
//忘记密码按钮
@property(strong,nonatomic) UIButton *btnForgetPwd;
//修改密码按钮
@property(strong,nonatomic) UIButton *btnChangePwd;
//登录按钮
@property(strong,nonatomic) UIButton *btnLogin;
//取消按钮
@property(strong,nonatomic) UIButton *btnCancel;
//账号文本框
@property(strong,nonatomic) UITextField *txfName;
//密码文本框
@property(strong,nonatomic) UITextField *txfPassword;
//单选框记住账号
@property(strong,nonatomic) CustomCheckboxView *cbRememberName;
//单选框记住密码
@property(strong,nonatomic) CustomCheckboxView *cbRememberPwd;
//单选框自动登录
@property(strong,nonatomic) CustomCheckboxView *cbAutoLogin;
//switch记住账号
@property(strong,nonatomic) UISwitch *stRememberName;
//switch记住密码
@property(strong,nonatomic) UISwitch *stRememberPwd;
//switch自动登录
@property(strong,nonatomic) UISwitch *stAutoLogin;
//设置是否记住账号
- (void) setIsRememberName:(BOOL)remember;
//获取是否记住账号
- (BOOL) getIsRememberName;
//设置是否记住密码
- (void) setIsRememberPwd:(BOOL)remember;
//获取是否记住密码
- (BOOL) getIsRememberPwd;
//设置是否自动登录
- (void) setIsAutoLogin:(BOOL)remember;
//获取是否自动登录
- (BOOL) getIsAutoLogin;
//设置账号名称
- (void) setName:(NSString *)name;
//获取账号名称
- (NSString *) getName;
//设置密码
- (void) setPassword:(NSString *)pwd;
//获取密码
- (NSString *) getPassword;
//填充表单数据
- (void) fillDataInViews;

@end
