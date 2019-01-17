//
//  SendRequestUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/13.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "SendRequestUtil.h"
#import "SocketMessageUtil.h"
#import "RoutherConfig.h"
#import "UserModel.h"
#import "NSString+Base64.h"
#import "RSAModel.h"
#import "HeartBeatUtil.h"
#import "AFHTTPClientV2.h"
#import "UserConfig.h"

@implementation SendRequestUtil

#pragma mark - 用户找回
+ (void) sendUserFindWithToxid:(NSString *) toxid usesn:(NSString *) sn {
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":@"Recovery",@"RouteId":toxid?:@"",@"UserSn":sn?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark - 用户注册
+ (void) sendUserRegisterWithUserPass:(NSString *) pass username:(NSString *) userName code:(NSString *) code
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":@"Register",@"RouteId":[RoutherConfig getRoutherConfig].currentRouterToxid?:@"",@"UserSn":[RoutherConfig getRoutherConfig].currentRouterSn?:@"",@"IdentifyCode":code,@"LoginKey":pass,@"NickName":userName};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark - 用户登陆
+ (void) sendUserLoginWithPass:(NSString *) passWord userid:(NSString *) userid showHud:(BOOL) showHud {
    
    if (showHud) {
       [AppD.window showHudInView:AppD.window hint:@"Login..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    } 
    NSDictionary *params = @{@"Action":@"Login",@"RouteId":[RoutherConfig getRoutherConfig].currentRouterToxid?:@"",@"UserSn":[RoutherConfig getRoutherConfig].currentRouterSn?:@"",@"UserId":userid?:@"",@"LoginKey":passWord?:@"",@"DataFileVersion":[NSString stringWithFormat:@"%zd",[UserModel getUserModel].dataFileVersion]};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -派生类拉取用户
+ (void) sendPullUserList
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":@"PullUserList",@"UserType":@(0),@"UserNum":@(0),@"UserStartSN":@"0"};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -创建帐户
+ (void) createRouterUserWithRouterId:(NSString *) routerId mnemonic:(NSString *) mnemonic code:(NSString *) code
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
     UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"CreateNormalUser",@"RouterId":routerId,@"AdminUserId":userM.userId,@"Mnemonic":mnemonic,@"IdentifyCode":code};
    [SocketMessageUtil sendVersion2WithParams:params];
}
+ (void) sendAddFriendWithFriendId:(NSString *) friendId msg:(NSString *) msg
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"AddFriendReq",@"NickName":[userM.username base64EncodedString]?:@"",@"UserId":userM.userId?:@"",@"FriendId":friendId?:@"",@"UserKey":[RSAModel getCurrentRASModel].publicKey,@"Msg":msg?:@""};
    [SocketMessageUtil sendTextWithParams:params];
}
#pragma mark -tox pull文件
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toid filePath:(NSString *) filePath msgid:(NSString *) msgId

{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{};
    [SocketMessageUtil sendTextWithParams:params];
}
#pragma mark -发送已读
+ (void) sendRedMsgWithFriendId:(NSString *) friendId msgid:(NSString *) msgId
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"ReadMsg",@"UserId":userM.userId,@"FriendId":friendId,@"ReadMsgs":msgId};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark - 登陆退出
+ (void) sendLogOut
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"LogOut",@"UserId":userM.userId,@"RouterId":[RoutherConfig getRoutherConfig].currentRouterToxid?:@"",@"UserSn":[RoutherConfig getRoutherConfig].currentRouterSn?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -修改昵称
+ (void) sendUpdateWithNickName:(NSString *) nickName
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"UserInfoUpdate",@"UserId":userM.userId,@"NickName":[nickName base64EncodedString]};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -sendfile tox
+ (void) sendToxSendFileWithParames:(NSDictionary *) parames
{
    [SocketMessageUtil sendTextWithParams:parames];
}

#pragma mark tox_拉取文件
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toId fileName:(NSString *) fileName msgId:(NSString *) msgId fileOwer:(NSString *) fileOwer
{
    NSDictionary *params = @{@"Action":@"PullFile",@"FromId":fromId,@"ToId":toId,@"FileName":fileName,@"MsgId":msgId,@"FileOwner":fileOwer};
    [SocketMessageUtil sendTextWithParams:params];
}

#pragma mark -注册小米推送 邦定regid
+ (void) sendRegidReqeust
{
    if (AppD.regId && ![AppD.regId isEmptyString]) {
      //  NSDictionary *params = @{@"os":@"1",@"appversion":APP_Version,@"regid":AppD.regId,@"topicid":@"",@"routerid":[RoutherConfig getRoutherConfig].currentRouterToxid,@"userid":[UserModel getUserModel].userId?:@"",@"usersn":[UserModel getUserModel].userSn?:@""};
        
         NSDictionary *params = @{@"os":@"1",@"appversion":APP_Version,@"regid":AppD.regId,@"routerid":[RoutherConfig getRoutherConfig].currentRouterToxid,@"userid":[UserConfig getShareObject].userId?:@"",@"usersn":[UserConfig getShareObject].usersn?:@""};
        
        [AFHTTPClientV2 requestWithBaseURLStr:PUSH_DEBUG_URL params:params httpMethod:HttpMethodPost successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
            int retCode = [responseObject[@"Ret"] intValue];
            if (retCode == 0) {
                NSLog(@"注册推送成功!");
            } else {
                NSLog(@"注册推送失败!");
            }
        } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
            NSLog(@"注册推送失败!!!!!!!!");
        }];
    }
    
}
#pragma mark -添加好友备注
+ (void) sendAddFriendNickName:(NSString *) nickName friendId:(NSString *) friendId
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"ChangeRemarks",@"UserId":userM.userId,@"FriendId":friendId,@"Remarks":[nickName base64EncodedString]};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -查询好友关系状态
+ (void) sendQueryFriendWithFriendId:(NSString *) friendId
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"QueryFriend",@"UserId":userM.userId,@"FriendId":friendId};
    [SocketMessageUtil sendVersion2WithParams:params];
}
@end