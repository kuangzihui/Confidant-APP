//
//  PNEmailDetailViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"
@class EmailListInfo;
NS_ASSUME_NONNULL_BEGIN

@interface PNEmailDetailViewController : PNBaseViewController
- (id) initWithEmailListModer:(EmailListInfo *) listInfo;
@end

NS_ASSUME_NONNULL_END
