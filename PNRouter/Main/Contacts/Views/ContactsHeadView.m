//
//  ContactsHeadView.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ContactsHeadView.h"

@implementation ContactsHeadView

+ (instancetype) loadContactsHeadView
{
    ContactsHeadView *view = [[[NSBundle mainBundle] loadNibNamed:@"ContactsHeadView" owner:self options:nil] lastObject];
    return view;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end