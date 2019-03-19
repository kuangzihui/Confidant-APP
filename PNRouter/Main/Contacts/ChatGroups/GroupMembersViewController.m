//
//  ChooseContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "GroupMembersViewController.h"
#import "ChooseDownView.h"
#import "ChatListDataUtil.h"
#import "ChooseContactShowModel.h"
#import "NSString+Base64.h"
#import "ChooseContactTableCell.h"
#import "GroupMembersHeaderView.h"
#import "FriendModel.h"
#import "GroupMembersModel.h"

@interface GroupMembersViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;

@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;

@property (nonatomic) BOOL isSearch;

@end

@implementation GroupMembersViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupUserPullSuccessNoti:) name:GroupUserPull_SUCCESS_NOTI object:nil];
}

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    
    _searchTF.delegate = self;
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
    
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:ChooseContactTableCellResue bundle:nil] forCellReuseIdentifier:ChooseContactTableCellResue];
    [_tableV registerNib:[UINib nibWithNibName:GroupMembersHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:GroupMembersHeaderViewReuse];
    
    [self sendGroupUserPull];
}

#pragma mark - Request
- (void)sendGroupUserPull {
    [SendRequestUtil sendGroupUserPullWithGId:_inputGId?:@"" TargetNum:@(0) StartId:@"0" showHud:YES];
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addAction:(id)sender {
    
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return _isSearch? self.searchDataArray.count : self.dataArray.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
//    ChooseContactShowModel *model = arr[section];
//    if (model.showCell) {
//        return model.routerArr.count;
//    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ChooseContactTableCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return GroupMembersHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GroupMembersHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:GroupMembersHeaderViewReuse];
    
    NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
    GroupMembersModel *model = arr[section];
    [view configHeaderWithModel:model];
    
    return view;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChooseContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseContactTableCellResue];
    
//    ChooseContactShowModel *model = _isSearch? self.searchDataArray[indexPath.section] : self.dataArray[indexPath.section];
//    ChooseContactRouterModel *crModel = model.routerArr[indexPath.row];
//    [cell configCellWithModel:crModel];
//    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UITextFeildDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    return YES;
}

#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void) textFieldTextChange:(UITextField *) tf
{
    if ([tf.text.trim isEmptyString]) {
        _isSearch = NO;
    } else {
        _isSearch = YES;
        [self.searchDataArray removeAllObjects];
        @weakify_self
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseContactShowModel *model = obj;
            NSString *userName = [[model.Name base64DecodedString] lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchDataArray addObject:model];
            }
        }];
    }
    [_tableV reloadData];
}

#pragma mark - Noti
- (void)groupUserPullSuccessNoti:(NSNotification *)noti {
    NSArray *arr = noti.object;
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:arr];
    [_tableV reloadData];
}

#pragma mark - Lazy
- (NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end