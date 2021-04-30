# YKNetworking
 1. 基于AFNetworking 4.0封装,提供多类型GET、POST、PUT、PATCH、DELEGATE、Upload、Download请求
 2. 通过block配置回调数据
 3. 提供断点续传
 4. 提供沙盒缓存机制
 5. 支持多文件下载、上传
 6. 优雅的日志log 
 7. 基于YYCache缓存,高效的缓存效率,缓存类型包括:
 ``` 
 /** 重新请求网络数据,不读写缓存 */
 YKCacheTypeRefresh = 0,
 /** 先获取缓存数据,再请求网络数据并缓存 */
 YKCacheTypeCache,
 /** 先获取网络数据并缓存，如果获取失败则从缓存中拿数据 */
 YKCacheTypeNetwork,
 /** 先获取缓存数据,再请求网络数据并缓存，若缓存数据与网络数据不一致Block将产生两次调用 */
 YKCacheTypeCacheAndNetwork
 ```
 详细用法参考[YKNetworking](https://github.com/KellyCoder/YKNetworking)

 ## 使用 ##
 

 ### 公共配置 ###
 需要新增配置,在此文件添加即可
 ```
 // 在APPDelegate 设置一次即可
 [YKRequestManager setBaseConfig:^(YKRequestConfig * _Nonnull configObj) {
     configObj.baseServer = @"base url";
     configObj.baseParameters = @{@"common":@"test"};
     configObj.consoleLog = YES;
     configObj.indicatorEnabled = YES;
     configObj.headers = @{@"key":@"value"};
     configObj.requestSerializerType = YKRequestSerializerTypeJSON;
     configObj.responseSerializerType = YKResponseSerializerTypeJSON;
     configObj.timeoutInterval = 10.;
 }];
 ```
 
 #### 1.POST ####
 
```

[YKRequestManager requestPOSTWithURL:@"0请求URL" parameters:@{@"key":@"value",@"locale":@"end"}  cacheType:YKCacheTypeRefresh completionHandler:^(BOOL isSuccess, id  _Nullable responseObject, NSError * _Nullable error) {
}];

```

#### 2.GET ####
```

[YKRequestManager requestGETWithURL:@"请求URL" parameters:@{@"key":@"value",@"locale":@"end"} cacheType:YKCacheTypeRefresh completionHandler:^(BOOL isSuccess, id  _Nullable responseObject, NSError * _Nullable error) {
}];

```

#### 3.上传 ####
```
[YKRequestManager uploadFileWithURL:@"上传服务器地址" filePath:@"文件路径" parameters:@{@"key":@"value"} name:@"文件对应服务器上的字段" progress:^(NSProgress * _Nullable progress) {
    
} completionHandler:^(BOOL isSuccess, id  _Nullable responseObject, NSError * _Nullable error) {
    
}];
```

#### 4.下载 ####
```
[YKRequestManager downloadStartWithURL:kDownloadUrl progress:^(NSProgress * _Nullable progress) {
    
} completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
    
}];

```
暂停下载,支持断点续传
```
[YKRequestManager downloadStopWithURL:kDownloadUrl];

```

#### 5.取消请求 ####
```
/// 取消所有请求
- (void)cancelAllRequest;

/// 取消指定网络请求
/// @param identifier taskId
- (void)cancelRequestByIdentifier:(NSUInteger)identifier;
```

#### 6.Log ####
优雅明了打印,更方便查看返回数据
```
- (void)logSocketWithURL:(NSString *)url
              parameters:(nullable NSDictionary *)parameters
          responseObject:(id)responseObject{
    if (!self.consoleLog) return;
    NSString *isSuccess = @"success";
    if ([responseObject isKindOfClass:[NSError class]]) {
        isSuccess = @"failure";
    }
    NSArray *logArray = @[
    @{@"result" : isSuccess},
    @{@"urlLink" : [YKNetworkTool connectWithparams:parameters.mutableCopy url:url]},
    @{@"parameters" : parameters ? parameters : [NSNull null]},
    @{@"responseObject" : responseObject ? responseObject : [NSNull null]}];
    [YKNetworkTool logSocket:logArray];
}

```


版本会持续更新,有问题请联系QQ:326054969,请添加备注,谢谢~
