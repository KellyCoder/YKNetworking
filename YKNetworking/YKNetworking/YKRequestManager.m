//
//  YKRequestManager.m
//  YKNetworking
//
//  Created by Kevin on 2021/4/29.
//

#import "YKRequestManager.h"
#import "YKNetworkObject.h"
#import "YKNetworkingEngine.h"
#import "YKCacheNetworkManager.h"

@implementation YKRequestManager

#pragma mark - Public Method
+ (void)setBaseConfig:(nullable void(^)(YKRequestConfig *configObj))config{
    YKRequestConfig *obj = [[YKRequestConfig alloc] init];
    config(obj);
    
    [[YKNetworkingEngine sharedInstance] setBaseConfig:obj];
}

+ (void)networkStatus:(YKNetworkStatusBlock)networkStatusBlock{
    [[YKNetworkingEngine sharedInstance] networkStatus:^(YKNetworkReachabilityStatus status) {
        networkStatusBlock ? networkStatusBlock(status) : nil;
    }];
}

#pragma mark - Request Method
+ (void)requestPOSTWithURL:(NSString *)url
                parameters:(nullable NSDictionary *)parameters
                 cacheType:(YKCacheType)cacheType
         completionHandler:(YKHttpRequestResultBlock)completionHandler{
    [[YKNetworkingEngine sharedInstance] requestHttpWithMethod:YKRequestMethodTypePOST
                                                           url:url
                                                    parameters:parameters
                                                       headers:nil
                                                     cacheType:cacheType
                                                      progress:nil
                                                       success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
        completionHandler ? completionHandler(YES,responseObject,nil) : nil;
    }
                                                       failure:^(NSURLSessionDataTask * _Nonnull dataTask, NSError * _Nullable error) {
        completionHandler ? completionHandler(NO,nil,error) : nil;
    }];
}

+ (void)requestGETWithURL:(NSString *)url
               parameters:(nullable NSDictionary *)parameters
                cacheType:(YKCacheType)cacheType
        completionHandler:(YKHttpRequestResultBlock)completionHandler{
    [[YKNetworkingEngine sharedInstance] requestHttpWithMethod:YKRequestMethodTypeGET
                                                           url:url
                                                    parameters:parameters
                                                       headers:nil
                                                     cacheType:cacheType
                                                      progress:nil
                                                       success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
        completionHandler ? completionHandler(YES,responseObject,nil) : nil;
    }
                                                       failure:^(NSURLSessionDataTask * _Nonnull dataTask, NSError * _Nullable error) {
        completionHandler ? completionHandler(NO,nil,error) : nil;
    }];
}

#pragma mark 文件上传
+ (void)uploadFileWithURL:(NSString *)url
                 filePath:(NSString *)filePath
               parameters:(nullable NSDictionary *)parameters
                     name:(NSString *)name
                 progress:(nullable YKHttpRequestProgressBlock)progress
        completionHandler:(YKHttpRequestResultBlock)completionHandler{
    [[YKNetworkingEngine sharedInstance] uploadFileWithURL:url
                                                  filePath:filePath
                                                parameters:parameters
                                                   headers:nil
                                                      name:name
                                                  progress:progress
                                                   success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
        completionHandler ? completionHandler(YES,responseObject,nil) : nil;
    }
                                                   failure:^(NSURLSessionDataTask * _Nonnull dataTask, NSError * _Nullable error) {
        completionHandler ? completionHandler(NO,nil,error) : nil;
    }];
}

+ (void)uploadImageWithURL:(NSString *)url
                    images:(NSArray<UIImage *> *)images
                parameters:(nullable NSDictionary *)parameters
                      name:(NSString *)name
                  fileName:(nullable NSString *)fileName
                imageScale:(CGFloat)imageScale
                 imageType:(NSString *)imageType
                  progress:(nullable YKHttpRequestProgressBlock)progress
         completionHandler:(YKHttpRequestResultBlock)completionHandler{
    
    [[YKNetworkingEngine sharedInstance] uploadImageWithURL:url
                                                     images:images
                                                 parameters:parameters
                                                    headers:nil
                                                       name:name
                                                   fileName:fileName
                                                 imageScale:imageScale
                                                  imageType:imageType
                                                   progress:progress
                                                    success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
        completionHandler ? completionHandler(YES,responseObject,nil) : nil;
    }
                                                    failure:^(NSURLSessionDataTask * _Nonnull dataTask, NSError * _Nullable error) {
        completionHandler ? completionHandler(NO,nil,error) : nil;
    }];
}

+ (void)uploadWithURL:(NSString *)url
          uploadArray:(NSMutableArray <YKUploadObject *> *)uploadArray
           parameters:(nullable NSDictionary *)parameters
             progress:(nullable YKHttpRequestProgressBlock)progress
    completionHandler:(YKHttpRequestResultBlock)completionHandler{
    [[YKNetworkingEngine sharedInstance] uploadWithURL:url
                                           uploadArray:uploadArray
                                            parameters:parameters
                                               headers:nil
                                              progress:progress
                                               success:^(NSURLSessionDataTask * _Nonnull dataTask, id  _Nullable responseObject) {
        completionHandler ? completionHandler(YES,responseObject,nil) : nil;
    }
                                               failure:^(NSURLSessionDataTask * _Nonnull dataTask, NSError * _Nullable error) {
        completionHandler ? completionHandler(NO,nil,error) : nil;
    }];
}

#pragma mark 下载文件
+ (void)downloadWithURL:(NSString *)url
             resumeData:(nullable NSData *)resumeData
               progress:(YKHttpRequestProgressBlock)progress
      completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    NSURLSessionDownloadTask *task = nil;
    NSString *savePath = [[YKCacheNetworkManager sharedInstance] downloadPath];
    
    task = [[YKNetworkingEngine sharedInstance] downloadWithURL:url
                                                     resumeData:resumeData
                                                       savePath:savePath
                                                       progress:^(NSProgress * _Nullable progress) {
        
    }
                                              completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        
    }];
}

// 开始下载
+ (void)downloadStartWithURL:(NSString *)url
                    progress:(YKHttpRequestProgressBlock)progress
           completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler{
    
    [[YKCacheNetworkManager sharedInstance] objectForKey:url withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        NSData *resumeData = (NSData *)object;
        
        [self downloadWithURL:url resumeData:resumeData progress:progress completionHandler:completionHandler];
    }];
    
}

// 暂停下载
+ (void)downloadStopWithURL:(NSString *)url{
    // 获取任务task
    NSURLSessionDownloadTask *downloadTask = [[YKNetworkingEngine sharedInstance] getTaskObjectForKey:url];
    // 获取下载数据
    [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        // 缓存下载数据
        [[YKCacheNetworkManager sharedInstance] setObject:resumeData forKey:url withBlock:^{
        }];
    }];
}

@end
