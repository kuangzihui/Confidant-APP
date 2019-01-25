//
//  FilePreviewViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/23.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FilePreviewViewController.h"
#import <QuickLook/QuickLook.h>

@interface FilePreviewViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSMutableArray *sourceArr;


@end

@implementation FilePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self previewFile];
}

#pragma mark - Operation
- (void)previewFile {
    _sourceArr = [NSMutableArray array];
    [_sourceArr addObject:_filePath];
    
    _previewController = [[QLPreviewController alloc] init];
    _previewController.dataSource = self;
    _previewController.delegate = self;
    [_contentView addSubview:_previewController.view];
    
    @weakify_self
    [_previewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(weakSelf.contentView).offset(0);
    }];
    
//    if (fileType == 4) {
//        previewView.backView.backgroundColor = [UIColor blackColor];
//    }
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(id)sender {
    
}


#pragma mark - request methods

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return _sourceArr.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    NSURL *url = [NSURL fileURLWithPath:_sourceArr[index]];
    return  url;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id<QLPreviewItem>)item inSourceView:(UIView *__autoreleasing  _Nullable *)view{
    return _contentView.bounds;
}

@end