//
//  SendToxRequestUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/29.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "SendToxRequestUtil.h"
#import "OCTSubmanagerChats.h"
#import "SocketMessageUtil.h"
#import "OCTSubmanagerFiles.h"
#import "FileData.h"
#import "UserConfig.h"
#import "MyConfidant-Swift.h"
#import "NSDateFormatter+Category.h"
#import "ChatListDataUtil.h"

@implementation SendToxRequestUtil

/**
 发送文本消息

 @param message 发送文本
 @param manage toxmange
 */
+ (void) sendTextMessageWithText:(NSString *) message manager:(id<OCTManager>) manage
{
    if (AppD.currentRouterNumber < 0) {
        [AppD.window hideHud];
        [AppD.window showHint:@"Failed to send message"];
        return;
    }
    DDLogDebug(@"send text: %@",message);
    [manage.chats sendTextMessageWithfriendNumber:AppD.currentRouterNumber text:message messageType:OCTToxMessageTypeNormal successBlock:^(OCTToxMessageId megid) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

/**
 tox 发送文件

 @param filePath 文件本地file
 @param parames 上传文件所带的参数
 */
+ (void) sendFileWithFilePath:(NSString *) filePath parames:(NSDictionary *) parames
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppD.manager.files sendFileAtPath:filePath moveToUploads:NO parames:parames  toFriendId:AppD.currentRouterNumber failureBlock:^(NSError * _Nonnull error) {
            
            NSLog(@"文件发送失败 = %@",error.description);
            
           [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_FILE_SEND_FAIELD_NOTI object:@[@(1),parames[@"GId"],parames[@"FileId"]?:@""]];
        }];
    });
}

/**
 tox 重新发送文件
 
 @param filePath 文件本地file
 @param parames 上传文件所带的参数
 */
+ (void) deUploadFileWithFilePath:(NSString *) filePath parames:(NSDictionary *) parames fileData:(NSData *) fileData
{
    NSString *srcKey = parames[@"SrcKey"];
    NSInteger fileid = [parames[@"FileId"] integerValue];

    
     [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fileId"),bg_sqlValue(@(fileid)),bg_sqlKey(@"srcKey"),bg_sqlValue(srcKey)] complete:^(NSArray * _Nullable array) {
         if (array && array.count > 0) {
             FileData *fileModel = array[0];
             fileModel.status = 2;
             fileModel.didStart = 0;
             fileModel.filePath = filePath;
             NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
             fileModel.optionTime = [formatter stringFromDate:[NSDate date]];
             [fileModel bg_saveOrUpdate];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [AppD.manager.files sendFileAtPath:filePath moveToUploads:NO parames:parames  toFriendId:AppD.currentRouterNumber failureBlock:^(NSError * _Nonnull error) {
                     
                     NSLog(@"文件发送失败 = %@",error.description);
                     NSString *toid = parames[@"ToId"];
                     if ([toid isEmptyString]) { // 上传文件
                         
                         NSString *srcKey = parames[@"SrcKey"];
                         int fileType = [parames[@"FileType"] intValue];
                         NSString *fileName = parames[@"FileName"];
                         [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(1),fileName,@"",@(fileType),srcKey,@(fileid)]];
                     }
                     
                 }];
             });
         }
     }];

}

/**
 tox 上传文件
 
 @param filePath 文件本地file
 @param parames 上传文件所带的参数
 */
+ (void) uploadFileWithFilePath:(NSString *) filePath parames:(NSDictionary *) parames fileData:(NSData *) fileData
{

    
    NSString *srcKey = parames[@"SrcKey"];
    NSInteger fileid = [parames[@"FileId"] integerValue];
    int fileType = [parames[@"FileType"] intValue];
    NSString *fileName = parames[@"FileName"];
    
   
   /* [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(srcKey)] complete:^(NSArray * _Nullable array) {
        if (array && array.count > 0) {
            FileData *fileModel = array[0];
            fileModel.status = 2;
           // fileModel.didStart = 0;
            fileModel.filePath = filePath;
            NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
            fileModel.optionTime = [formatter stringFromDate:[NSDate date]];
            [fileModel bg_saveOrUpdateAsync:nil];
        } else {
            FileData *fileModel = [[FileData alloc] init];
            fileModel.bg_tableName = FILE_STATUS_TABNAME;
            fileModel.fileId = fileid;
            fileModel.fileSize = fileData.length;
            fileModel.fileData = fileData;
            fileModel.didStart = 0;
            fileModel.fileType = fileType;
            fileModel.filePath = filePath;
            NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
            fileModel.optionTime = [formatter stringFromDate:[NSDate date]];
            fileModel.progess = 0.0f;
            fileModel.fileName = [Base58Util Base58DecodeWithCodeName:fileName];
            fileModel.fileOptionType = 1;
            fileModel.status = 2;
            fileModel.userId = [UserConfig getShareObject].userId;
            fileModel.srcKey = srcKey;
            [fileModel bg_saveAsync:nil];
        }
    }];
    */
    
    FileData *fileModel = [[FileData alloc] init];
    fileModel.bg_tableName = FILE_STATUS_TABNAME;
    fileModel.fileId = fileid;
    fileModel.fileSize = fileData.length;
    fileModel.fileData = fileData;
    fileModel.didStart = 0;
    fileModel.fileType = fileType;
    fileModel.filePath = filePath;
    NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
    fileModel.optionTime = [formatter stringFromDate:[NSDate date]];
    fileModel.progess = 0.0f;
    fileModel.fileName = [Base58Util Base58DecodeWithCodeName:fileName];
    fileModel.fileOptionType = 1;
    fileModel.status = 2;
    fileModel.userId = [UserConfig getShareObject].userId;
    fileModel.srcKey = srcKey;
    [fileModel bg_save];
 
    [AppD.manager.files sendFileAtPath:filePath moveToUploads:NO parames:parames  toFriendId:AppD.currentRouterNumber failureBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"文件发送失败 = %@",error.description);
        NSString *toid = parames[@"ToId"];
        if ([toid isEmptyString]) { // 上传文件
            
            NSString *srcKey = parames[@"SrcKey"];
            int fileType = [parames[@"FileType"] intValue];
            NSString *fileName = parames[@"FileName"];
            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(1),fileName,@"",@(fileType),srcKey,@(fileid)]];
        }
        
    }];
}

+ (BOOL) check_can_be_canceled_uploadWithFileid:(NSString *) fileid
{
     BOOL result = NO;
    NSString *numberVaules = [[ChatListDataUtil getShareObject].fileNumberParames objectForKey:fileid];
    if (![[NSString getNotNullValue:numberVaules] isEmptyString]) {
        result = YES;
    }
    return result;
}

+ (BOOL) check_can_be_canceled_downWithMsgid:(NSString *) msgid
{
    BOOL result = NO;
    NSString *numberVaules = [[ChatListDataUtil getShareObject].fileNumberParames objectForKey:msgid];
    if (![[NSString getNotNullValue:numberVaules] isEmptyString]) {
        result = YES;
    }
    return result;
}

// 取消tox文件上传
+ (void) cancelToxFileUploadWithFileid:(NSString *) fileid
{
   NSString *numberVaules = [[ChatListDataUtil getShareObject].fileNumberParames objectForKey:fileid];
    if (![[NSString getNotNullValue:numberVaules] isEmptyString]) {
        int fileNumber = [numberVaules intValue];
        [AppD.manager.files cancelCurrentOperationWithFileNumber:fileNumber];
        [[ChatListDataUtil getShareObject].fileNumberParames removeObjectForKey:fileid];
    }
}
// 取消tox文件上传
+ (BOOL) cancelToxFileDownWithMsgid:(NSString *) msgid
{
    BOOL result = NO;
    NSString *numberVaules = [[ChatListDataUtil getShareObject].fileNumberParames objectForKey:msgid];
    if (![[NSString getNotNullValue:numberVaules] isEmptyString]) {
        int fileNumber = [numberVaules intValue];
        [AppD.manager.files cancelToxFileDownWithFileNumber:fileNumber];
        result = YES;
         [[ChatListDataUtil getShareObject].fileNumberParames removeObjectForKey:msgid];
    }
    return result;
}

@end
