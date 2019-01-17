//
//  AddFriendCellTableViewCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "AddFriendCellTableViewCell.h"
#import "FriendModel.h"
#import "NSDate+Category.h"
#import "NSString+Base64.h"

@implementation AddFriendCellTableViewCell

- (IBAction)rightAction:(UIButton *)sender {
    if (self.rightBlcok) {
        self.rightBlcok(sender.tag, self.tag);
    }
}


- (void) setFriendModel:(FriendModel *) model{
    _lblName.text = model.username?:@"";
    _lblStatus.text = @"";
    _rightBackView.hidden = YES;
    if (model.dealStaus == 1) {
        _lblStatus.text = @"Accepted";
    } else if (model.dealStaus == 2) {
        _lblStatus.text = @"Expired";
    } else if (model.dealStaus == 3) {
        _lblStatus.text = @"Pending";
    } else {
        NSInteger day = labs([model.requestTime daysAfterDate:[NSDate date]]);
        if (day > 7) {
            model.dealStaus = 2;
            _lblStatus.text = @"Expired";
            [model bg_saveOrUpdate];
        } else {
             _rightBackView.hidden = NO;
        }
    }
    _lblTitle.text = [StringUtil getUserNameFirstWithName:model.username];
    NSString *msg = model.msg?:@"";
    if (msg && ![msg isEmptyString]) {
        msg = [msg base64DecodedString];
    }
    _lblMsg.text = msg;
}
@end