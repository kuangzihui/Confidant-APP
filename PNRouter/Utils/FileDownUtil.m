//
//  FileDownUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FileDownUtil.h"
#import "FileListModel.h"
#import "PNRouter-Swift.h"
#import "OperationRecordModel.h"
#import "SystemUtil.h"
#import "RequestService.h"
#import "NSDate+Category.h"
#import "UserConfig.h"
#import "FileData.h"

@implementation FileDownUtil
+ (instancetype) getShareObject
{
    static FileDownUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}

- (void) downFileWithFileModel:(FileListModel *) fileModel  progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure
{
    NSString *filePath = fileModel.FileName;
    NSString *fileNameBase58 = fileModel.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileName];
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(NSArray * _Nullable array) {
        if (array && array.count > 0) {
            FileData *fileData = array[0];
            fileData.status = 2;
            [fileData bg_saveOrUpdateAsync:nil];
        } else {
            FileData *fileData = [[FileData alloc] init];
            fileModel.bg_tableName = FILE_STATUS_TABNAME;
            NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
            NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
            fileData.fileId = [mill intValue];
            fileData.fileSize = [fileModel.FileSize intValue];
            fileData.fileType = [fileModel.FileType intValue];
            fileData.progess = 0.0f;
            fileData.fileName = fileName;
            fileData.filePath = filePath;
            fileData.fileOptionType = 2;
            fileData.status = 2;
            fileData.userId = [UserConfig getShareObject].userId;
            fileData.srcKey = fileModel.UserKey;
            [fileModel bg_saveAsync:nil];
        }
    }];
    
    [RequestService downFileWithBaseURLStr:filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(progress);
            
            [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(NSArray * _Nullable array) {
                if (array && array.count > 0) {
                    FileData *fileData = array[0];
                    fileData.progess = progress;
                    [fileData bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Progess_Noti object:fileData];
                }
            }];
            
        });
    } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 保存下载完成记录
            [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(NSArray * _Nullable array) {
                if (array && array.count > 0) {
                    FileData *fileData = array[0];
                    fileData.status = 1;
                    fileData.progess = 1.0f;
                    [fileData bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileData];
                }
            }];
            // 下载成功-保存操作记录
            NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
            NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
            NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileModel.FileName.lastPathComponent];
            [OperationRecordModel saveOrUpdateWithFileType:fileModel.FileType operationType:@(1) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:fileModel.FileName?:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
        });
        
    } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"download error********* %@",error);
            // 保存下载完成记录
            [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(NSArray * _Nullable array) {
                if (array && array.count > 0) {
                    FileData *fileData = array[0];
                    fileData.status = 3;
                    fileData.progess = 0.0f;
                    [fileData bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileData];
                }
            }];
        });
    }];
}



- (void) deDownFileWithFileModel:(FileData *) fileModel  progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure
{
    NSString *filePath = fileModel.filePath;
    NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileModel.fileName];
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.srcKey)] complete:^(NSArray * _Nullable array) {
        if (array && array.count > 0) {
            
            FileData *fileData = array[0];
            fileData.status = 2;
            [fileData bg_saveOrUpdateAsync:nil];
            
            // 下载
            [RequestService downFileWithBaseURLStr:filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(progress);
                    
                    fileData.progess = progress;
                    [fileData bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Progess_Noti object:fileData];
                });
            } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 保存下载完成记录
                    fileData.status = 1;
                    fileData.progess = 1.0f;
                    [fileData bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileData];
                    // 下载成功-保存操作记录
                    NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
                    NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
                    NSString *fileName = fileModel.fileName;
                    [OperationRecordModel saveOrUpdateWithFileType:@(fileModel.fileType) operationType:@(1) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:fileModel.filePath?:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
                });
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"download error********* %@",error);
                    // 保存下载完成记录
                    fileData.status = 3;
                    fileData.progess = 0.0f;
                    [fileData bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileData];
                });
            }];
        }
    }];
    
    
}
@end
