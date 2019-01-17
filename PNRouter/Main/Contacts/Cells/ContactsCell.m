//
//  ContactsCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ContactsCell.h"
#import "FriendModel.h"
#import "NSString+Base64.h"
#import "RouterUserModel.h"

@implementation ContactsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setModeWithModel:(FriendModel *) model
{
    _descContraintW.constant = 0;
    _lblDesc.text = @"";
    _lblName.text = [model.username base64DecodedString]?:model.username;
    _lblTitle.text =[StringUtil getUserNameFirstWithName:_lblName.text];
}
- (void) setModeWithRoutherUserModel:(RouterUserModel *) model
{
    _descContraintW.constant = 80;
    if (model.Active == 1) {
        _lblDesc.text = @"Activated";
    } else {
        _lblDesc.text = @"not Activated";
    }
    
    _lblName.text = model.NickName?:@"";
    _lblTitle.text =[StringUtil getUserNameFirstWithName:model.NickName];
}

@end