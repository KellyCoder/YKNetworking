//
//  YKNetworkingEngine.m
//  YKNetworking
//
//  Created by Kevin on 2021/4/28.
//

#import "YKNetworkingEngine.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "YKCacheNetworkManager.h"
#import "YKNetworkObject.h"
#import "YKNetworkTool.h"

// 默认请求超时时间
static NSTimeInterval const TimeoutIntervalDefault = 15.0;

@interface YKNetworkingEngine ()

/** 缓存对象 */
@property (nonatomic,strong) YKCacheNetworkManager *cacheManager;

/** baseURL域名 */
@property (nonatomic, copy) NSString *baseServer;
/** 公共参数 */
@property (nonatomic, strong, nullable) NSDictionary *baseParameters;
/** 超时时间,默认15s */
@property (nonatomic) NSTimeInterval timeoutInterval;
/** 请求头 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *,NSString *> *headers;
/** 是否开启打印Log,默认NO */
@property (nonatomic) BOOL consoleLog;
/** 旋转菊花开关,默认开 */
@property (nonatomic) BOOL indicatorEnabled;
/** task周期管理,key为请求url地址 */
@property (nonatomic,strong) NSMutableDictionary *taskCycleDic;

@end

@implementation YKNetworkingEngine

#pragma mark - init
+ (instancetype)sharedInstance{
    static YKNetworkingEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YKNetworkingEngine alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*",@"multipart/form-data",@"application/x-www-form-urlencoded", nil];
        
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = TimeoutIntervalDefault;
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        //自带缓存策略
        //        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        // 开始监测网络状态
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        // 打开请求状态旋转菊花
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        // 初始化缓存对象
        self.cacheManager = [[YKCacheNetworkManager alloc] init];
        // 任务周期管理
        self.taskCycleDic = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public Method
- (void)setBaseConfig:(YKRequestConfig *)config{
    if (config.baseServer) {
        self.baseServer = config.baseServer;
    }
    
    if (config.baseParameters) {
        self.baseParameters = config.baseParameters;
    }
    
    if (config.timeoutInterval) {
        self.timeoutInterval = config.timeoutInterval;
    }
    
    if (config.headers) {
        self.headers = config.headers;
    }
    
    self.consoleLog = config.consoleLog;
    
    self.indicatorEnabled = config.indicatorEnabled;
}

- (void)networkStatus:(YKNetworkStatusBlock)networkStatusBlock{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatusBlock ? networkStatusBlock(YKNetworkReachabilityStatusUnknown) : nil;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatusBlock ? networkStatusBlock(YKNetworkReachabilityStatusNotReachable) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatusBlock ? networkStatusBlock(YKNetworkReachabilityStatusWWAN) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatusBlock ? networkStatusBlock(YKNetworkReachabilityStatusWiFi) : nil;
                break;
            default:
                break;
        }
    }];
}

//打印返回数据
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
    @{@"url" : url},
    @{@"parameters" : parameters ? parameters : [NSNull null]},
    @{@"responseObject" : responseObject ? responseObject : [NSNull null]}];
    [YKNetworkTool logSocket:logArray];
}

- (void)logProgressWithURL:(NSString *)url progress:(NSProgress *)progress{
    if (!self.consoleLog) return;
    CGFloat value = 1.0 * progress.completedUnitCount / progress.totalUnitCount;
    NSArray *logArray = @[
    @{@"url" : url},
    @{@"progress" : @(value)}];
    [YKNetworkTool logSocket:logArray];
}

#pragma mark - Request Method
- (void)requestHttpWithMethod:(YKRequestMethodType)method
                          url:(NSString *)url
                   parameters:(nullable NSDictionary *)parameters
                      headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                    cacheType:(YKCacheType)cacheType
                     progress:(nullable YKHttpRequestProgressBlock)progress
                      success:(nullable YKHttpRequsetSuccessBlock)success
                      failure:(nullable YKHttpRequsetFailBlock)failure{
    
    // 组装url
    if (_baseServer.length > 0) {
        url = [NSString stringWithFormat:@"%@%@",_baseServer,url];
    }
    // 组装参数
    if (_baseParameters.count) {
        NSMutableDictionary *mutableBaseParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        [mutableBaseParameters addEntriesFromDictionary:_baseParameters];
        parameters = [mutableBaseParameters copy];
    }

    switch (cacheType) {
        case YKCacheTypeCache:{ //先获取缓存数据,再请求网络数据并缓存
            [self getNetworkCacheWithURL:url parameters:parameters withBlock:^(NSString *key, id<NSCoding> object) {
                
                if (object){
                    [self logSocketWithURL:url parameters:parameters responseObject:object];
                    success ? success([NSURLSessionDataTask new], object) : nil;
                }
                
                [self requestMethod:method url:url parameters:parameters headers:headers progress:progress success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
                    
                    if (!object){
                        [self logSocketWithURL:url parameters:parameters responseObject:responseObject];
                        success ? success(dataTask, responseObject) : nil;
                    }
                    //设置缓存
                    [self setNetworkCacheWithURL:url parameters:parameters responseObject:responseObject withBlock:nil];
                    
                } failure:^(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nullable error) {
                    
                    [self logSocketWithURL:url parameters:parameters responseObject:error];
                    failure ? failure(dataTask, error) : nil;
                }];
                
            }];
            
        }
            break;
        case YKCacheTypeNetwork:{ //先获取网络数据并缓存，如果获取失败则从缓存中拿数据
            [self requestMethod:method url:url parameters:parameters headers:headers progress:progress success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
                [self logSocketWithURL:url parameters:parameters responseObject:responseObject];
                success ? success(dataTask, responseObject) : nil;
                // 设置缓存
                [self setNetworkCacheWithURL:url parameters:parameters responseObject:responseObject withBlock:nil];
                
            } failure:^(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nullable error) {
                
                // 请求失败从缓存拿数据
                [self getNetworkCacheWithURL:url parameters:parameters withBlock:^(NSString *key, id<NSCoding> object) {
                    if (object){
                        [self logSocketWithURL:url parameters:parameters responseObject:object];
                        success ? success(dataTask, object) : nil;
                    }else{
                        [self logSocketWithURL:url parameters:parameters responseObject:error];
                    }
                }];
                failure ? failure(dataTask, error) : nil;
            }];
        }
            break;
        case YKCacheTypeCacheAndNetwork:{ //先获取缓存数据,再请求网络数据并缓存，若缓存数据与网络数据不一致Block将调用两次
            [self getNetworkCacheWithURL:url parameters:parameters withBlock:^(NSString *key, id<NSCoding> object) {
                
                [self logSocketWithURL:url parameters:parameters responseObject:object];
                if (object) success ? success([NSURLSessionDataTask new], object) : nil;
                
                //重新请求网络数据
                [self requestMethod:method url:url parameters:parameters headers:headers progress:progress success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
                    //防止相同数据多次请求
                    if (object != responseObject && responseObject) {
                        [self logSocketWithURL:url parameters:parameters responseObject:responseObject];
                        success ? success(dataTask, responseObject) : nil;
                    }
                    
                } failure:^(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nullable error) {
                    [self logSocketWithURL:url parameters:parameters responseObject:error];
                    failure ? failure(dataTask, error) : nil;
                }];
            }];
            
        }
        default:{ // 默认重新请求网络数据,不读写缓存
            [self requestMethod:method url:url parameters:parameters headers:headers progress:progress success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
                [self logSocketWithURL:url parameters:parameters responseObject:responseObject];
                success ? success(dataTask, responseObject) : nil;
            } failure:^(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nullable error) {
                [self logSocketWithURL:url parameters:parameters responseObject:error];
                failure ? failure(dataTask, error) : nil;
            }];
        }
            break;
    }
}

- (void)requestMethod:(YKRequestMethodType)method
                  url:(NSString *)url
           parameters:(nullable NSDictionary *)parameters
              headers:(nullable NSDictionary<NSString *,NSString *>*)headers
             progress:(nullable YKHttpRequestProgressBlock)progress
              success:(nullable YKHttpRequsetSuccessBlock)success
              failure:(nullable YKHttpRequsetFailBlock)failure{
    
    NSURLSessionDataTask *dataTask = nil;
    
    switch (method) {
        case YKRequestMethodTypePOST:{
            dataTask = [self POST:url parameters:parameters headers:headers progress:progress success:success failure:failure];
        }
            break;
        case YKRequestMethodTypePUT:{
            dataTask = [self PUT:url parameters:parameters headers:headers success:success failure:failure];
        }
            break;
        case YKRequestMethodTypePATCH:{
            dataTask = [self PATCH:url parameters:parameters headers:headers success:success failure:failure];
        }
            break;
        case YKRequestMethodTypeDELETE:{
            dataTask = [self DELETE:url parameters:parameters headers:headers success:success failure:failure];
        }
            break;
        default:{
            dataTask = [self GET:url parameters:parameters headers:headers progress:progress success:success failure:failure];
        }
            break;
    }
}

- (void)cancelAllRequest{
    [self.operationQueue cancelAllOperations];
}

- (void)cancelRequestByIdentifier:(NSUInteger)identifier{
    if (identifier == 0) return;
    [self.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL *stop) {
        if (task.taskIdentifier == identifier) {
            [task cancel];
            *stop = YES;
        }
    }];
}

#pragma mark 文件上传
- (NSURLSessionDataTask *)uploadFileWithURL:(NSString *)url
                                   filePath:(NSString *)filePath
                                 parameters:(nullable NSDictionary *)parameters
                                    headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                                       name:(NSString *)name
                                   progress:(nullable YKHttpRequestProgressBlock)progress
                                    success:(nullable YKHttpRequsetSuccessBlock)success
                                    failure:(nullable YKHttpRequsetFailBlock)failure{
    NSURLSessionDataTask *uploadTask = [self  POST:[self stringUTF8Encoding:url] parameters:parameters headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        [self logProgressWithURL:url progress:uploadProgress];
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self logSocketWithURL:url parameters:parameters responseObject:responseObject];
        success ? success(task, responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logSocketWithURL:url parameters:parameters responseObject:error];
        failure ? failure(task, error) : nil;
    }];
    return uploadTask;
}

- (NSURLSessionDataTask *)uploadImageWithURL:(NSString *)url
                                      images:(NSArray<UIImage *> *)images
                                  parameters:(nullable NSDictionary *)parameters
                                     headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                                        name:(NSString *)name
                                    fileName:(nullable NSString *)fileName
                                  imageScale:(CGFloat)imageScale
                                   imageType:(NSString *)imageType
                                    progress:(nullable YKHttpRequestProgressBlock)progress
                                     success:(nullable YKHttpRequsetSuccessBlock)success
                                     failure:(nullable YKHttpRequsetFailBlock)failure{
    NSURLSessionDataTask *uploadTask = [self  POST:[self stringUTF8Encoding:url] parameters:parameters headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [images enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData *imageData = UIImageJPEGRepresentation(obj, imageScale);
            NSString *imageFileName = fileName;
            if (!imageFileName) {
                // 默认图片的文件名, 若fileNames为nil就使用
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyyMMddHHmmss";
                NSString *str = [formatter stringFromDate:[NSDate date]];
                
                imageFileName = [NSString stringWithFormat:@"%@%lu.%@", str, idx, imageType ? imageType : @"jpg"];
            }
            NSString *fileNameStr = [NSString stringWithFormat:@"%@%lu.%@",fileName,(unsigned long)idx,imageType ? imageType : @"jpeg"];
            NSString *mimeType = [NSString stringWithFormat:@"image/%@",imageType ? imageType : @"jpeg"];
            [formData appendPartWithFileData:imageData name:name fileName:fileNameStr
                                    mimeType:mimeType];
        }];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        [self logProgressWithURL:url progress:uploadProgress];
        progress ? progress(uploadProgress) : nil;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self logSocketWithURL:url parameters:parameters responseObject:responseObject];
        success ? success(task, responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self logSocketWithURL:url parameters:parameters responseObject:error];
        failure ? failure(task, error) : nil;
    }];
    
    return uploadTask;
}

- (NSURLSessionDataTask *)uploadWithURL:(NSString *)url
                            uploadArray:(NSMutableArray <YKUploadObject *> *)uploadArray
                             parameters:(nullable NSDictionary *)parameters
                                headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                               progress:(nullable YKHttpRequestProgressBlock)progress
                                success:(nullable YKHttpRequsetSuccessBlock)success
                                failure:(nullable YKHttpRequsetFailBlock)failure{
    NSURLSessionDataTask *uploadTask = [self POST:[self stringUTF8Encoding:url] parameters:parameters headers:headers constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [uploadArray enumerateObjectsUsingBlock:^(YKUploadObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.fileData) {
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                } else {
                    [formData appendPartWithFormData:obj.fileData name:obj.name];
                }
            } else if (obj.fileURL) {
                NSError *fileError = nil;
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:&fileError];
                } else {
                    [formData appendPartWithFileURL:obj.fileURL name:obj.name error:&fileError];
                }
                if (fileError) {
                    *stop = YES;
                }
            }
        }];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            [self logProgressWithURL:url progress:uploadProgress];
            progress ? progress(uploadProgress) : nil;
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self logSocketWithURL:url parameters:parameters responseObject:responseObject];
            success ? success(task, responseObject) : nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self logSocketWithURL:url parameters:parameters responseObject:error];
            failure ? failure(task, error) : nil;
        }];
    
    return uploadTask;
}

#pragma mark 下载文件
- (NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                   resumeData:(nullable NSData *)resumeData
                                     savePath:(NSString *)savePath
                                     progress:(YKHttpRequestProgressBlock)progress
                            completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self stringUTF8Encoding:url]]];
    
    NSString *fileName = [request.URL lastPathComponent];
    NSURL *downloadFileSavePath = [NSURL fileURLWithPath:[NSString pathWithComponents:@[savePath, fileName]] isDirectory:NO];
    
    NSURLSessionDownloadTask *downloadTask = nil;
    if (resumeData.length > 0) {
        downloadTask = [self downloadWithResumeData:resumeData progress:^(NSProgress *downloadProgress) {
            [self logProgressWithURL:url progress:downloadProgress];
            progress ? progress(downloadProgress) : nil;
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return downloadFileSavePath;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [self logSocketWithURL:url parameters:nil responseObject:filePath];
            completionHandler ? completionHandler(response, filePath, error) : nil;
        }];
        
    }else{
        downloadTask = [self downloadWithUrlRequest:request progress:^(NSProgress *downloadProgress) {
            [self logProgressWithURL:url progress:downloadProgress];
            progress ? progress(downloadProgress) : nil;
        } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return downloadFileSavePath;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            [self logSocketWithURL:url parameters:nil responseObject:filePath];
            completionHandler ? completionHandler(response, filePath, error) : nil;
        }];
    }
    
    // task管理
    [self setTaskObject:downloadTask forKey:url];
    
    [downloadTask resume];
    
    return downloadTask;
}

// 下载文件
- (NSURLSessionDownloadTask *)downloadWithUrlRequest:(NSURLRequest *)urlRequest
                                            progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                         destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                   completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:urlRequest
                                                                  progress:downloadProgressBlock
                                                               destination:destination
                                                         completionHandler:completionHandler];
    return downloadTask;
}
// 断点续传
- (NSURLSessionDownloadTask *)downloadWithResumeData:(NSData *_Nonnull)resumeData
                                            progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                         destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                   completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithResumeData:resumeData
                                                                     progress:downloadProgressBlock
                                                                  destination:destination
                                                            completionHandler:completionHandler];
    return downloadTask;
}

#pragma mark - task管理
- (void)setTaskObject:(id)object forKey:(NSString *)key{
    [self.taskCycleDic setObject:object forKey:key];
}

- (void)removeTaskObjectForKey:(NSString *)key{
    [self.taskCycleDic removeObjectForKey:key];
}

- (id)getTaskObjectForKey:(NSString *)key{
    return [self.taskCycleDic objectForKey:key];
}

#pragma mark - 网络缓存
// 组装缓存key
- (NSString *)cacheKeyWithURL:(NSString *)url parameters:(nullable NSDictionary *)parameters{
    if (!parameters) return url;
    
    return [NSString stringWithFormat:@"%@%@",url,[self dictionaryToJson:parameters]];
}
// 设置缓存
- (void)setNetworkCacheWithURL:(NSString *)url
                    parameters:(nullable NSDictionary *)parameters
                responseObject:(id)responseObject
                     withBlock:(nullable void (^)(void))block{
    NSString *key = [self cacheKeyWithURL:url parameters:parameters];
    [self.cacheManager setObject:responseObject forKey:key withBlock:block];
}
// 获取缓存
- (void)getNetworkCacheWithURL:(NSString *)url
                    parameters:(nullable NSDictionary *)parameters
                     withBlock:(nullable void (^)(NSString *key, id <NSCoding> object))block{
    NSString *key = [self cacheKeyWithURL:url parameters:parameters];
    [self.cacheManager objectForKey:key withBlock:block];
}


#pragma mark - 网络请求相关默认设置
- (void)setRequestSerializerConfig:(YKRequestSerializerType)requestSerializerType{
    self.requestSerializer = requestSerializerType == YKRequestSerializerTypeJSON ? [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
}

- (void)setResponseSerializerConfig:(YKResponseSerializerType)responseSerializerType{
    self.responseSerializer = responseSerializerType == YKResponseSerializerTypeJSON ? [AFJSONResponseSerializer serializer] : [AFHTTPResponseSerializer serializer];
}

- (void)setHeaderValuer:(NSString *)value forHTTPHeaderField:(NSString *)field{
    [self.requestSerializer setValue:value forHTTPHeaderField:field];
}

- (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName{
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    //使用证书验证模式
    AFSecurityPolicy *securitypolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //如果需要验证自建证书(无效证书)，需要设置为YES
    securitypolicy.allowInvalidCertificates = YES;
    //是否需要验证域名，默认为YES
    securitypolicy.validatesDomainName = validatesDomainName;
    securitypolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
    self.securityPolicy = securitypolicy;
}

- (void)setIndicatorEnabled:(BOOL)indicatorEnabled{
    _indicatorEnabled = indicatorEnabled;
    // 打开请求状态旋转菊花
    [AFNetworkActivityIndicatorManager sharedManager].enabled = indicatorEnabled;
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval{
    _timeoutInterval = timeoutInterval;
    self.requestSerializer.timeoutInterval = timeoutInterval;
}

- (void)setHeaders:(NSDictionary<NSString *,NSString *> *)headers{
    _headers = headers;
    if ([headers allKeys].count > 0) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            [self.requestSerializer setValue:value forHTTPHeaderField:field];
        }];
    }
}

#pragma mark - private
- (NSString *)stringUTF8Encoding:(NSString *)string{
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

// NSDictionary转json
- (NSString *)dictionaryToJson:(id)jsonObject{
    if (!jsonObject) return nil;
    if ([jsonObject isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:jsonObject encoding:NSUTF8StringEncoding];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
    if (jsonData.length == 0) return nil;
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
