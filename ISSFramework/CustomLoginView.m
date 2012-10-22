//
//  LoginView.m
//  CdtsFramework
//
//  Created by 山天 大畜 on 4/05/12.
//  Copyright (c) 2012 iSoftStone. All rights reserved.
//

#import "CustomLoginView.h"

@interface CustomLoginView()
{


}

@end

@implementation CustomLoginView

@synthesize delegate;
@synthesize btnForgetPwd;
@synthesize btnChangePwd;
@synthesize btnLogin;
@synthesize btnCancel;
@synthesize txfName;
@synthesize txfPassword;
@synthesize cbRememberName;
@synthesize cbRememberPwd;
@synthesize cbAutoLogin;
@synthesize stRememberName;
@synthesize stRememberPwd;
@synthesize stAutoLogin;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(NSString *)getName{
    if (txfName) {
        return [txfName.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}
-(void)setName:(NSString *)name{
    if (txfName) {
        txfName.text=name;
    }
}
-(NSString *)getPassword{
    if (txfPassword) {
        return txfPassword.text;
    }
    return nil;
}
-(void)setPassword:(NSString *)pwd{
    if (txfPassword) {
        txfPassword.text=pwd;
    }
}

-(BOOL)getIsRememberName{
    if (cbRememberName) {
        return cbRememberName.isChecked;
    }
    if (stRememberName) {
        return stRememberName.on;
    }
    return NO;
}
-(void)setIsRememberName:(BOOL)remember{
    if (cbRememberName) {
        [cbRememberName check:remember];
    }
    if (stRememberName) {
        return [stRememberName setOn:remember];
    }
}
-(BOOL)getIsRememberPwd{
    if (cbRememberPwd) {
        return cbRememberPwd.isChecked;
    }
    if (stRememberPwd) {
        return stRememberPwd.on;
    }
    return NO;
}
-(void)setIsRememberPwd:(BOOL)remember{
    if (cbRememberPwd) {
        [cbRememberPwd check:remember];
    }
    if (stRememberPwd) {
        [stRememberPwd setOn:remember];
    }
}
-(BOOL)getIsAutoLogin{
    if (cbAutoLogin) {
        return cbAutoLogin.isChecked;
    }
    if (stAutoLogin) {
        return stAutoLogin.on;
    }
    return NO;
}
-(void)setIsAutoLogin:(BOOL)remember{
    if (cbAutoLogin) {
        [cbAutoLogin check:remember];
    }
    if (stAutoLogin) {
        [stAutoLogin setOn:remember];
    }
}

-(void)setTxfName:(UITextField *)_txfName{
    txfName=_txfName;
    txfName.delegate = self;
    [txfName setReturnKeyType:UIReturnKeyNext];
    [txfName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [txfName setEnablesReturnKeyAutomatically:YES];
    [txfName setKeyboardType:UIKeyboardTypeDefault];
    txfName.tag=1;
}
-(void)setTxfPassword:(UITextField *)_txfPassword{
    txfPassword=_txfPassword;
    txfPassword.delegate = self;
    [txfPassword setEnablesReturnKeyAutomatically:YES];
    [txfPassword setReturnKeyType:UIReturnKeyDone];
    [txfPassword setSecureTextEntry:YES];
    txfPassword.tag=2;
}
-(void)setBtnLogin:(UIButton *)_btnLogin{
    btnLogin=_btnLogin;
    [btnLogin addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
}
-(void)setBtnCancel:(UIButton *)_btnCancel{
    btnCancel=_btnCancel;
    if (delegate&&[delegate respondsToSelector:@selector(loginView_cancel)]) {
        [btnCancel addTarget:delegate action:@selector(loginView_cancel) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)setBtnForgetPwd:(UIButton *)_btnForgetPwd{
    btnForgetPwd=_btnForgetPwd;
    if (delegate&&[delegate respondsToSelector:@selector(loginView_forgetPwd:)]) {
        [btnForgetPwd addTarget:delegate action:@selector(loginView_forgetPwd:) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)setBtnChangePwd:(UIButton *)_btnChangePwd{
    btnChangePwd=_btnChangePwd;
    if (delegate&&[delegate respondsToSelector:@selector(loginView_changePwd:)]) {
        [btnChangePwd addTarget:delegate action:@selector(loginView_changePwd:) forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)setStRememberName:(UISwitch *)_stRememberName{
    stRememberName=_stRememberName;
    [stRememberName addTarget:self action:@selector(switch_check:) forControlEvents:UIControlEventValueChanged];
    stRememberName.tag=1;
}
-(void)setCbRememberName:(CustomCheckboxView *)_cbRememberName{
    cbRememberName=_cbRememberName;
    cbRememberName.delegate=self;
    cbRememberName.tag=1;
}
-(void)setStRememberPwd:(UISwitch *)_stRememberPwd{
    stRememberPwd=_stRememberPwd;
    [stRememberPwd addTarget:self action:@selector(switch_check:) forControlEvents:UIControlEventValueChanged];
    stRememberPwd.tag=2;
}
-(void)setCbRememberPwd:(CustomCheckboxView *)_cbRememberPwd{
    cbRememberPwd=_cbRememberPwd;
    cbRememberPwd.delegate=self;
    cbRememberPwd.tag=2;
}
-(void)setStAutoLogin:(UISwitch *)_stAutoLogin{
    stAutoLogin=_stAutoLogin;
    [stAutoLogin addTarget:self action:@selector(switch_check:) forControlEvents:UIControlEventValueChanged];
    stAutoLogin.tag=3;
}
-(void)setCbAutoLogin:(CustomCheckboxView *)_cbAutoLogin{
    cbAutoLogin=_cbAutoLogin;
    cbAutoLogin.delegate=self;
    cbAutoLogin.tag=3;
}

-(void)fillDataInViews{
    NSDictionary *m_userData = [self getLoginDataFromSandbox];
    if (m_userData && [m_userData count]!= 0) {
        NSString * userName = [m_userData objectForKey:USER_NAME_KEY];
        if (txfName) {
            [txfName setText:userName];
        }
        NSString * userPassword = [m_userData objectForKey:USER_PWD_KEY];
        if (txfPassword) {
            [txfPassword setText:userPassword];
        }
        NSString * selectedRememberName = [m_userData objectForKey:USER_REMEMBER_NAME_KEY];
        if (cbRememberName) {
            if ([selectedRememberName isEqualToString:@"YES"]) {
                [cbRememberName check:YES];
            }else{
                [cbRememberName check:NO];
            }
        }
        if (stRememberName) {
            if ([selectedRememberName isEqualToString:@"YES"]) {
                [stRememberName setOn:YES];
            }else{
                [stRememberName setOn:NO];
            }
        }
        NSString * selectedRememberPwd = [m_userData objectForKey:USER_REMEMBER_PWD_KEY];
        if (cbRememberPwd) {
            if ([selectedRememberPwd isEqualToString:@"YES"]) {
                [cbRememberPwd check:YES];
            }else{
                [cbRememberPwd check:NO];
            }
        }
        if (stRememberPwd) {
            if ([selectedRememberPwd isEqualToString:@"YES"]) {
                [stRememberPwd setOn:YES];
            }else{
                [stRememberPwd setOn:NO];
            }
        }
        NSString * selectedIsAutoLogin = [m_userData objectForKey:USER_AUTO_LOGIN_KEY];
        if (cbAutoLogin) {
            if ([selectedIsAutoLogin isEqualToString:@"YES"]) {
                [cbAutoLogin check:YES];
            }else{
                [cbAutoLogin check:NO];
            }
        }
        if (stAutoLogin) {
            if ([selectedIsAutoLogin isEqualToString:@"YES"]) {
                [stAutoLogin setOn:YES];
            }else{
                [stAutoLogin setOn:NO];
            }
        }
    }
}

-(void)login{
    if (txfName) {
        [txfName resignFirstResponder];
    }
    if (txfPassword) {
        [txfPassword resignFirstResponder];
    }
    [self saveLoginData];
    [delegate loginView_login:[self getName] withPassword:[self getPassword]];
}

- (NSDictionary *)getLoginDataFromSandbox
{
    NSLog(@"%@",LOGIN_DATA_PATH);
	if (![[NSFileManager defaultManager] fileExistsAtPath:LOGIN_DATA_PATH]) {
		NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
		[data setObject:@"" forKey:USER_NAME_KEY];
        [data setObject:@"" forKey:USER_PWD_KEY];
        [data setObject:@"" forKey:USER_REMEMBER_NAME_KEY];
		[data setObject:@"" forKey:USER_REMEMBER_PWD_KEY];
        [data setObject:@"" forKey:USER_AUTO_LOGIN_KEY];
		[data writeToFile:LOGIN_DATA_PATH atomically:YES];
		return nil;
	}else {
		NSDictionary * data = [NSDictionary dictionaryWithContentsOfFile:LOGIN_DATA_PATH];
		return data;
	}
}

- (void)saveLoginData
{
	NSMutableDictionary * data = [[NSMutableDictionary alloc] init];
	NSString * status = nil;
	if ([self getIsRememberName]) {
		status = @"YES";
		[data setObject:status forKey:USER_REMEMBER_NAME_KEY];
		[data setObject:[self getName] forKey:USER_NAME_KEY];
	}else {
		status = @"NO";
		[data setObject:status forKey:USER_REMEMBER_NAME_KEY];
		[data setObject:@"" forKey:USER_NAME_KEY];
	}
    if ([self getIsRememberPwd]) {
		status = @"YES";
		[data setObject:status forKey:USER_REMEMBER_PWD_KEY];
		[data setObject:[self getPassword] forKey:USER_PWD_KEY];
	}else {
		status = @"NO";
		[data setObject:status forKey:USER_REMEMBER_PWD_KEY];
		[data setObject:@"" forKey:USER_PWD_KEY];
	}
    if ([self getIsAutoLogin]) {
		status = @"YES";
		[data setObject:status forKey:USER_AUTO_LOGIN_KEY];
	}else {
		status = @"NO";
		[data setObject:status forKey:USER_AUTO_LOGIN_KEY];
	}
	NSLog(@"data:%@",data);
	[data writeToFile:LOGIN_DATA_PATH atomically:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(textField.tag == 1) {
		[txfPassword becomeFirstResponder];
	}
	if (textField.tag == 2) {
		[txfPassword resignFirstResponder];
		[self login];
	}	
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{  
	if (range.location >= 20)
	{
		return NO; 
	}
	return YES;       
}

-(void)checkboxView_check:(id)sender checked:(BOOL)checked{
    CustomCheckboxView *cv=(CustomCheckboxView *)sender;
    switch (cv.tag) {
        case 1:
            if (!checked) {
                if (cbRememberPwd) {
                    [cbRememberPwd check:checked];
                }
                if (cbAutoLogin) {
                    [cbAutoLogin check:checked];
                }
            }
            break;
        case 2:
            if (checked) {
                if (cbRememberName) {
                    [cbRememberName check:checked];
                }
            }else {
                if (cbAutoLogin) {
                    [cbAutoLogin check:checked];
                }
            }
            break;
        case 3:
            if (checked) {
                if (cbRememberName) {
                    [cbRememberName check:checked];
                }
                if (cbRememberPwd) {
                    [cbRememberPwd check:checked];
                }
            }
            break;
        default:
            break;
    }
}
-(void)switch_check:(id)sender{
    UISwitch *st=(UISwitch *)sender;
    switch (st.tag) {
        case 1:
            if (!st.on) {
                if (stRememberPwd) {
                    [stRememberPwd setOn:st.on animated:YES];
                }
                if (stAutoLogin) {
                    [stAutoLogin setOn:st.on animated:YES];
                }
            }
            break;
        case 2:
            if (st.on) {
                if (stRememberName) {
                    [stRememberName setOn:st.on animated:YES];
                }
            }else {
                if (stAutoLogin) {
                    [stAutoLogin setOn:st.on animated:YES];
                }
            }
            break;
        case 3:
            if (st.on) {
                if (stRememberName) {
                    [stRememberName setOn:st.on animated:YES];
                }
                if (stRememberPwd) {
                    [stRememberPwd setOn:st.on animated:YES];
                }
            }
            break;
        default:
            break;
    }
}


-(void)dealloc{
    self.txfName=nil;
    self.txfPassword=nil;
    self.btnLogin=nil;
    self.btnCancel=nil;
    self.cbRememberName=nil;
    self.cbRememberPwd=nil;
    self.cbAutoLogin=nil;
    self.btnChangePwd=nil;
    self.btnForgetPwd=nil;
    self.delegate=nil;
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
