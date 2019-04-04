//
//  RouterManagerViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/27.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "RouterManagerViewController.h"
#import "RouterManagementCell.h"
#import "QRViewController.h"
#import "RouterModel.h"
#import "RouterDetailViewController.h"
#import "PNRouter-Swift.h"
#import "SocketCountUtil.h"
#import "SystemUtil.h"
#import "PNDefaultHeaderView.h"
#import "UsedSpaceTableViewCell.h"
#import "SettingCell.h"
#import "UserManagerViewController.h"
#import "EditTextViewController.h"
#import "InvitationQRCodeViewController.h"
#import "ChooseCircleViewController.h"
#import "DiskManagerViewController.h"
#import "GetDiskTotalInfoModel.h"
#import "UnitUtil.h"

typedef enum : NSUInteger {
    RouterConnectStatusWait,
    RouterConnectStatusConnecting,
    RouterConnectStatusSuccess,
    RouterConnectStatusFail,
} RouterConnectStatus;

#define Circle_Members_Str @"Circle Members"
#define Circle_Name_Str @"Circle Name"
#define Circle_QR_Code_Str @"Circle QR Code"
#define Used_Space_Str @"Used Space"
#define Manage_Disks_Str @"Manage Disks"
#define Enable_Auto_Login_Str @"Enable Auto Login"
#define Circle_Alias_Str @"Cirle Alias"

@interface RouterManagerViewController () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL isAdmin;
}


@property (weak, nonatomic) IBOutlet UILabel *routerNameLab;

@property (weak, nonatomic) IBOutlet UIImageView *currentCircleIcon;

@property (weak, nonatomic) IBOutlet UITableView *routerTable;
@property (nonatomic, strong) NSMutableArray *routerArr;
@property (nonatomic) RouterConnectStatus connectStatus;

@property (nonatomic, strong) RouterModel *connectRouteM;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIView *quickBackView;
@property (nonatomic, strong) GetDiskTotalInfoModel *getDiskTotalInfoM;

@end

@implementation RouterManagerViewController

- (IBAction)quickSwitchAction:(id)sender {
    [self jumpToChooseCircle];
}

#pragma mark - Observe
- (void)observe {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatus) name:RELOAD_SOCKET_FAILD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDiskTotalInfoSuccessNoti:) name:GetDiskTotalInfo_Noti object:nil];
}

#pragma mark - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _quickBackView.layer.cornerRadius = 14.0f;
    _quickBackView.layer.masksToBounds = YES;
    _quickBackView.layer.borderColor = RGB(44, 44, 44).CGColor;
    _quickBackView.layer.borderWidth = .5f;
    
    _codeBtn.hidden = YES;
    [self observe];
    _routerArr = [NSMutableArray array];
    _routerTable.delegate = self;
    _routerTable.dataSource = self;
    
    [_routerTable registerNib:[UINib nibWithNibName:RouterManagementCellReuse bundle:nil] forCellReuseIdentifier:RouterManagementCellReuse];
    [_routerTable registerNib:[UINib nibWithNibName:UsedSpaceTableViewCellReuse bundle:nil] forCellReuseIdentifier:UsedSpaceTableViewCellReuse];
    [_routerTable registerNib:[UINib nibWithNibName:SettingCellReuse bundle:nil] forCellReuseIdentifier:SettingCellReuse];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    _currentCircleIcon.layer.cornerRadius = 32.0f;
    
    _currentCircleIcon.layer.masksToBounds = YES;
    
    _currentCircleIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    _currentCircleIcon.layer.borderWidth = 2.0f;
    
    _connectRouteM = [RouterModel getConnectRouter];
    _routerNameLab.text = _connectRouteM.name?:@"";
    NSString *userKey = @"";
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_routerNameLab.text]];
    _currentCircleIcon.image = defaultImg;
    
    NSString *userType = [_connectRouteM.userSn substringWithRange:NSMakeRange(0, 2)];
    [_routerArr removeAllObjects];
    if ([userType isEqualToString:@"01"]) { // 管理员
        [self sendGetDiskTotalInfo];
        isAdmin = YES;
        [_routerArr addObjectsFromArray:@[@[Circle_Members_Str],@[Circle_Name_Str,Circle_QR_Code_Str],@[Used_Space_Str,Manage_Disks_Str],@[Enable_Auto_Login_Str]]];
    } else {
        isAdmin = NO;
        [_routerArr addObjectsFromArray:@[@[Circle_Alias_Str,Circle_QR_Code_Str],@[Enable_Auto_Login_Str]]];
    }
    [_routerTable reloadData];
}

#pragma mark - Operation
- (void)refreshStatus {
    
    if ([SystemUtil isSocketConnect]) {
        NSInteger status = [SocketUtil.shareInstance getSocketConnectStatus];
        if (status == socketConnectStatusNone) {
            self.connectStatus = RouterConnectStatusWait;
        } else if (status == socketConnectStatusConnecting) {
            self.connectStatus = RouterConnectStatusConnecting;
        } else if (status == socketConnectStatusConnected) {
            self.connectStatus = RouterConnectStatusSuccess;
        } else if (status == socketConnectStatusDisconnecting) {
            self.connectStatus = RouterConnectStatusFail;
        } else if (status == socketConnectStatusDisconnected) {
            self.connectStatus = RouterConnectStatusFail;
        }
    } else {
        if (AppD.manager) {
            self.connectStatus = RouterConnectStatusSuccess;
        } else {
             self.connectStatus = RouterConnectStatusFail;
        }
    }
    
   
}

- (void)refreshTableData {
    [_routerArr removeAllObjects];
    [_routerArr addObjectsFromArray:[RouterModel getLocalRouters]];
    [_routerTable reloadData];
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)scanAction:(id)sender {
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            
        }
    }];
    [self presentModalVC:vc animated:YES];
}

- (IBAction)clickRouterAction:(id)sender {
    [self jumpToRouterDetail:_connectRouteM];
}

- (IBAction)tryAgainAction:(id)sender {
    if ([SystemUtil isSocketConnect]) {
        [SocketCountUtil getShareObject].reConnectCount = 0;
        [AppD.window showHudInView:AppD.window hint:@"connection..."];
        NSString *connectURL = [SystemUtil connectUrl];
        [SocketUtil.shareInstance connectWithUrl:connectURL];
        [self refreshStatus];
    }
}

#pragma mark - Request
- (void)sendGetDiskTotalInfo {
    [SendRequestUtil sendGetDiskTotalInfoWithShowHud:NO];
}

#pragma mark - Transition
- (void)jumpToRouterDetail:(RouterModel *)model {
    RouterDetailViewController *vc = [[RouterDetailViewController alloc] init];
    vc.routerM = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return _routerArr.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_routerArr[section] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = _routerArr[indexPath.section][indexPath.row];
    if ([title isEqualToString:Used_Space_Str]) {
        return UsedSpaceTableViewCell_Height;
    }
    return RouterManagementCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
         RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
        cell.nameLab.text = _routerArr[indexPath.section][indexPath.row];
        if (isAdmin) {
            cell.icon.hidden = YES;
            cell.lblDesc.text = @"";
        } else {
            if (indexPath.row == 0) {
                cell.icon.hidden = YES;
                cell.lblDesc.text = _connectRouteM.aliasName?:@"";
            } else {
                cell.icon.hidden = NO;
                cell.lblDesc.text = @"";
            }
        }
        return cell;
    } else if (indexPath.section == 1) {
        if (isAdmin) {
            RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
            cell.nameLab.text = _routerArr[indexPath.section][indexPath.row];
            if (indexPath.row == 0) {
                cell.icon.hidden = YES;
                cell.lblDesc.text = _connectRouteM.aliasName?:@"";
            } else {
                cell.icon.hidden = NO;
                cell.lblDesc.text = @"";
            }
            return cell;
        } else {
            SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellReuse];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.leftContraintV.constant = 16;
            cell.titleLab.text = _routerArr[indexPath.section][indexPath.row];
            [cell.switc setOn:_connectRouteM.isOpen animated:YES];
            [cell.switc addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UsedSpaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UsedSpaceTableViewCellReuse];
            if (_getDiskTotalInfoM) {
                CGFloat useDigital = [UnitUtil getDigitalOfM:_getDiskTotalInfoM.UsedCapacity];
                CGFloat totalDigital = [UnitUtil getDigitalOfM:_getDiskTotalInfoM.TotalCapacity];
                CGFloat usePercent = useDigital/totalDigital;
                cell.useLab.text = [NSString stringWithFormat:@"%@ / %@ （%.1f%@）",_getDiskTotalInfoM.UsedCapacity?:@"",_getDiskTotalInfoM.TotalCapacity?:@"",usePercent*100,@"%"];
                cell.useProgressV.progress = usePercent;
            }
            return cell;
        } else {
            RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
            cell.nameLab.text = _routerArr[indexPath.section][indexPath.row];
            cell.lblDesc.text = @"";
            cell.icon.hidden = YES;
            return cell;
        }
    } else {
        SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellReuse];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.leftContraintV.constant = 16;
        cell.titleLab.text = _routerArr[indexPath.section][indexPath.row];
        [cell.switc setOn:_connectRouteM.isOpen animated:YES];
        [cell.switc addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
       
        if (isAdmin) {
            // 圈子人数
            [self jumpToUserManager];
        } else {
            if (indexPath.row == 0) {
               // 圈子别名
                 [self jumpToAlias];
            } else {
               // 圈子code
                 [self jumpToRouterCode];
            }
        }
       
    } else if (indexPath.section == 1) {
        if (isAdmin) {
            if (indexPath.row == 0) {
                // 圈子别名
                [self jumpToAlias];
            } else {
                 // 圈子code
                [self jumpToRouterCode];
            }
            
        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
           // 圈子磁盘空间和使用量
        } else {
            [self jumpToDiskManagement];
        }
    }
}

#pragma mark - Transition
- (void)jumpToAlias {
    EditTextViewController *vc = [[EditTextViewController alloc] initWithType:EditAlis];
    vc.routerM = _connectRouteM;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToRouterCode {
    InvitationQRCodeViewController *vc = [[InvitationQRCodeViewController alloc] init];
    vc.routerM = _connectRouteM;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToChooseCircle {
    ChooseCircleViewController *vc = [[ChooseCircleViewController alloc] init];
    [self presentModalVC:vc animated:YES];
}

- (void)jumpToDiskManagement {
    DiskManagerViewController *vc = [DiskManagerViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToUserManager {
    // 磁盘管理
    UserManagerViewController *vc = [[UserManagerViewController alloc] initWithRid:_connectRouteM.toxid];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - switch开关change
- (void) swChange:(UISwitch *) sender
{
    [RouterModel updateRouterLoginSwitchWithSn:_connectRouteM.userSn isOpen:sender.isOn];
}

#pragma mark - Noti
- (void)getDiskTotalInfoSuccessNoti:(NSNotification *)noti {
    NSDictionary *receiveDic = noti.object;
    NSDictionary *paramsDic = receiveDic[@"params"];
    _getDiskTotalInfoM = [GetDiskTotalInfoModel getObjectWithKeyValues:paramsDic];
    DDLogDebug(@"---%@",_getDiskTotalInfoM);
    [_routerTable reloadData];
}

#pragma mark - Lazy
//- (void)setConnectStatus:(RouterConnectStatus)connectStatus {
//    _connectStatus = connectStatus;
//    if (_connectStatus == RouterConnectStatusWait) {
//        _connectBtnHeight.constant = 43;
//        [_connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
//        _connectTipBackHeight.constant = 0;
//    } else if (_connectStatus == RouterConnectStatusConnecting) {
//        _connectBtnHeight.constant = 0;
//        _connectTipBackHeight.constant = 30;
//        _connectTipLab.text = @"Connection...";
//        _connectTipIcon.image = [UIImage imageNamed:@"icon_loading"];
//    } else if (_connectStatus == RouterConnectStatusSuccess) {
//        _connectBtnHeight.constant = 0;
//        _connectTipBackHeight.constant = 30;
//        _connectTipLab.text = @"Successful connection";
//        _connectTipIcon.image = [UIImage imageNamed:@"icon_connected"];
//    } else if (_connectStatus == RouterConnectStatusFail) {
//        _connectBtnHeight.constant = 43;
//        [_connectBtn setTitle:@"Try again" forState:UIControlStateNormal];
//        _connectTipBackHeight.constant = 30;
//        _connectTipLab.text = @"Failed to connect";
//        _connectTipIcon.image = nil;
//    }
//}

@end
