//
//  EmailListCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/9.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailListCell.h"

@implementation EmailListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _readView.layer.masksToBounds = YES;
    _readView.layer.cornerRadius = 5;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   
    // Configure the view for the selected state
}

@end