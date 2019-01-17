//
//  SocketManageUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/29.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "SocketManageUtil.h"
#import "SocketDataUtil.h"

@implementation SocketManageUtil

+ (instancetype) getShareObject
{
    static SocketManageUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        shareObject.socketArray = [NSMutableArray array];
    });
    return shareObject;
}
- (void) clearDisConnectSocket {
   
    @weakify_self
    [self.socketArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SocketDataUtil *socket = (SocketDataUtil *) obj;
        if (socket.isComplete) {
            [weakSelf.socketArray removeObject:obj];
            NSLog(@"删除socket~~~~~~~~~");
        }
    }];
}
@end