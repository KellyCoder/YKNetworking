//
//  TableViewController.m
//  YKNetworking
//
//  Created by Kevin on 2021/4/28.
//

#import "TableViewController.h"

#import "YKNetworking.h"

static NSString * kDownloadUrl = @"下载URL";

@interface TableViewController ()

@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.dataArray = @[
        @[
            @"GET请求",
            @"POST请求",
            @"上传",
            @"下载",
        ]
    ];

    
    // 在APPDelegate 设置base data
    [YKRequestManager setBaseConfig:^(YKRequestConfig * _Nonnull configObj) {
        configObj.baseServer = @"URL域名";
        configObj.baseParameters = @{@"common":@"test"};
        configObj.consoleLog = YES;
    }];
    
    
    //断点续传
    UIBarButtonItem *start = [[UIBarButtonItem alloc] initWithTitle:@"开始下载" style:UIBarButtonItemStylePlain target:self action:@selector(startClick)];
    self.navigationItem.leftBarButtonItem = start;
    
    UIBarButtonItem *stop = [[UIBarButtonItem alloc] initWithTitle:@"停止下载" style:UIBarButtonItemStylePlain target:self action:@selector(stopClick)];
    self.navigationItem.rightBarButtonItem = stop;
    
}

- (void)startClick{
    [YKRequestManager downloadStartWithURL:kDownloadUrl progress:^(NSProgress * _Nullable progress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
    }];
}

- (void)stopClick{
    [YKRequestManager downloadStopWithURL:kDownloadUrl];
}


#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArray = self.dataArray[section];
    return sectionArray.count;
}

#pragma mark - UITableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        [YKRequestManager requestGETWithURL:@"请求" parameters:@{@"key":@"value",@"locale":@"end"} cacheType:YKCacheTypeRefresh completionHandler:^(BOOL isSuccess, id  _Nullable responseObject, NSError * _Nullable error) {
        }];
        
    }else if (indexPath.row == 1) {
        
        [YKRequestManager requestPOSTWithURL:@"请求的URL" parameters:@{@"key":@"value",@"locale":@"end"} cacheType:YKCacheTypeRefresh completionHandler:^(BOOL isSuccess, id  _Nullable responseObject, NSError * _Nullable error) {
        }];
        
    }else if (indexPath.row == 2) {
        
        [YKRequestManager uploadFileWithURL:@"上传服务器地址" filePath:@"文件路径" parameters:@{@"key":@"value"} name:@"文件对应服务器上的字段" progress:^(NSProgress * _Nullable progress) {
            
        } completionHandler:^(BOOL isSuccess, id  _Nullable responseObject, NSError * _Nullable error) {
            
        }];
        
    }else if (indexPath.row == 3) {
        [YKRequestManager downloadStartWithURL:kDownloadUrl progress:^(NSProgress * _Nullable progress) {
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
            
        }];
    }
    
}



@end
