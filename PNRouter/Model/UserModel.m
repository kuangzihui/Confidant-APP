//
//  UserModel.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "UserModel.h"
#import "KeyCUtil.h"
#import "FriendModel.h"
#import "NSString+Base64.h"
#import "UserConfig.h"

@implementation UserModel

+ (void)createUserLocalWithName:(NSString *)name {
    NSString *modeJson = [KeyCUtil getKeyValueWithKey:USER_LOCAL];
    if (!modeJson || [modeJson isEmptyString]) {
        UserModel *userM = [[UserModel alloc] init];
        userM.username = name;
        userM.userId = @"";
        [KeyCUtil saveStringToKeyWithString:userM.mj_JSONString key:USER_LOCAL];
    }
}
+ (void)createUserLocalWithName:(NSString *)name userid:(NSString *) userid version:(NSInteger)version filePay:(NSString *)filePay userpass:(NSString *)pass userSn:(NSString *) userSn
{
    NSString *modeJson = [KeyCUtil getKeyValueWithKey:USER_LOCAL];
    if (!modeJson || [modeJson isEmptyString]) {
        UserModel *userM = [[UserModel alloc] init];
        if (name) {
            name = [name base64DecodedString];
        }
        userM.username = name;
        userM.pass = pass;
        userM.userId = userid;
        userM.dataFileVersion = version;
        userM.dataFilePay = filePay;
        userM.userSn = userSn;
        [KeyCUtil saveStringToKeyWithString:userM.mj_JSONString key:USER_LOCAL];
    } else {
         UserModel *userM = [UserModel getObjectWithKeyValues:[modeJson mj_keyValues]];
        if (name) {
            name = [name base64DecodedString];
        }
        userM.username = name;
        userM.pass = pass;
        userM.userId = userid;
        userM.dataFileVersion = version;
        userM.dataFilePay = filePay;
        userM.userSn = userSn;
        [KeyCUtil saveStringToKeyWithString:userM.mj_JSONString key:USER_LOCAL];
    }
}

+ (instancetype) getShareObject
{
    static UserModel *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}

+ (UserModel *)getUserModel {
    
    
    
    NSString *modeJson = [KeyCUtil getKeyValueWithKey:USER_LOCAL];
    UserModel *userM = nil;
    if (!modeJson || [modeJson isEmptyString]) {
        if ([UserConfig getShareObject].userId && ![[UserConfig getShareObject].userId isEmptyString]) {
            UserModel *model = [UserModel getShareObject];
            model.userId = [UserConfig getShareObject].userId;
            model.username = [UserConfig getShareObject].userName;
            model.pass = [UserConfig getShareObject].passWord;
            model.userSn = [UserConfig getShareObject].usersn;
            model.dataFilePay = [UserConfig getShareObject].dataFilePay;
            model.dataFileVersion = [UserConfig getShareObject].dataFileVersion;
            return model;
        } else {
            userM = [[UserModel alloc] init];
            userM.username = @"";
            userM.userId = @"";
        }
    } else {
        userM = [UserModel getObjectWithKeyValues:[modeJson mj_keyValues]];
    }
    return userM;
}
+ (void)updateUserLocalWithName:(NSString *) name {
    NSString *modeJson = [KeyCUtil getKeyValueWithKey:USER_LOCAL];
    UserModel *userM = [UserModel getObjectWithKeyValues:[modeJson mj_keyValues]];;
    userM.username = name;
    [KeyCUtil saveStringToKeyWithString:userM.mj_JSONString key:USER_LOCAL];
}
+ (void)updateUserLocalWithPass:(NSString *) pass {
    NSString *modeJson = [KeyCUtil getKeyValueWithKey:USER_LOCAL];
    UserModel *userM = [UserModel getObjectWithKeyValues:[modeJson mj_keyValues]];;
    userM.pass = pass;
    [KeyCUtil saveStringToKeyWithString:userM.mj_JSONString key:USER_LOCAL];
}

+ (void)updateUserLocalWithUserId:(NSString *)userId withUserName:(NSString *)userName userSn:(NSString *)userSn {
   NSString *modeJson = [KeyCUtil getKeyValueWithKey:USER_LOCAL];
    UserModel *userM = nil;
    if (!modeJson || [modeJson isEmptyString]) {
        userM = [[UserModel alloc] init];
        userM.userId = userId;
        if (userName) {
            userName = [userName base64DecodedString];
        }
        userM.username = userName?:@"";
        userM.userSn = userSn;
    } else {
        userM = [UserModel getObjectWithKeyValues:[modeJson mj_keyValues]];
        if (![userId isEqualToString:userM.userId]) {
            [FriendModel bg_drop:FRIEND_REQUEST_TABNAME];
        }
        userM.userId = userId;
        userM.userSn = userSn;
        if (userName) {
            userName = [userName base64DecodedString];
            userM.username = userName;
        }
    }
    [KeyCUtil saveStringToKeyWithString:userM.mj_JSONString key:USER_LOCAL];
}

- (void) saveUserModeToKeyChain
{
    [KeyCUtil saveStringToKeyWithString:self.mj_JSONString key:USER_LOCAL];
}

+ (void)isLogin {
    
}

@end