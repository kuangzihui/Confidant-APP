//
//  FriendModel.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FriendModel.h"

@implementation FriendModel

// 实现这个方法的目的：告诉MJExtension框架模型中的属性名对应着字典的哪个key
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"username" : @"Name",
             @"remarks"  : @"Remarks",
              @"userId" : @"Id",
              @"publicKey" : @"UserKey",
              @"onLineStatu" : @"Status"
             };
}

@end