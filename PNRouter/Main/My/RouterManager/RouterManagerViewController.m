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

typedef enum : NSUInteger {
    RouterConnectStatusWait,
    RouterConnectStatusConnecting,
    RouterConnectStatusSuccess,
    RouterConnectStatusFail,
} RouterConnectStatus;

@interface RouterManagerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *connectBtnHeight; // 43
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *connectTipBackHeight; // 44
@property (weak, nonatomic) IBOutlet UILabel *routerNameLab;
@property (weak, nonatomic) IBOutlet UILabel *connectTipLab;
@property (weak, nonatomic) IBOutlet UIImageView *connectTipIcon;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;

@property (weak, nonatomic) IBOutlet UITableView *routerTable;
@property (nonatomic, strong) NSMutableArray *routerArr;
@property (nonatomic) RouterConnectStatus connectStatus;

@property (nonatomic, strong) RouterModel *connectRouteM;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

@end

@implementation RouterManagerViewController

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatus) name:RELOAD_SOCKET_FAILD_NOTI object:nil];
}

#pragma mark - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _codeBtn.hidden = YES;
    [self observe];
//    _connectBtn.layer.cornerRadius = 5.0f;
//    _connectBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    _connectBtn.layer.borderWidth = 1.0f;
    
    _routerArr = [NSMutableArray array];
    [_routerTable registerNib:[UINib nibWithNibName:RouterManagementCellReuse bundle:nil] forCellReuseIdentifier:RouterManagementCellReuse];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _connectRouteM = [RouterModel getConnectRouter];
    _routerNameLab.text = _connectRouteM.name?:@"";
    [self refreshStatus];
    [self refreshTableData];
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
    [_routerArr addObjectsFromArray:[RouterModel getLocalRouter]];
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

#pragma mark - Transition
- (void)jumpToRouterDetail:(RouterModel *)model {
    RouterDetailViewController *vc = [[RouterDetailViewController alloc] init];
    vc.routerM = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _routerArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return RouterManagementCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
    
    RouterModel *model = _routerArr[indexPath.row];
    [cell configWithModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RouterModel *model = _routerArr[indexPath.row];
    [self jumpToRouterDetail:model];
    
}

#pragma mark - Lazy
- (void)setConnectStatus:(RouterConnectStatus)connectStatus {
    _connectStatus = connectStatus;
    if (_connectStatus == RouterConnectStatusWait) {
        _connectBtnHeight.constant = 43;
        [_connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
        _connectTipBackHeight.constant = 0;
    } else if (_connectStatus == RouterConnectStatusConnecting) {
        _connectBtnHeight.constant = 0;
        _connectTipBackHeight.constant = 44;
        _connectTipLab.text = @"Connection...";
        _connectTipIcon.image = [UIImage imageNamed:@"icon_loading"];
    } else if (_connectStatus == RouterConnectStatusSuccess) {
        _connectBtnHeight.constant = 0;
        _connectTipBackHeight.constant = 44;
        _connectTipLab.text = @"Successful connection";
        _connectTipIcon.image = [UIImage imageNamed:@"icon_connected"];
    } else if (_connectStatus == RouterConnectStatusFail) {
        _connectBtnHeight.constant = 43;
        [_connectBtn setTitle:@"Try again" forState:UIControlStateNormal];
        _connectTipBackHeight.constant = 44;
        _connectTipLab.text = @"Failed to connect";
        _connectTipIcon.image = nil;
    }
}

@end