//
//  YKRequestManager.h
//  YKNetworking
//
//  Created by Kevin on 2021/4/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YKNetworkingConst.h"

NS_ASSUME_NONNULL_BEGIN

@class YKUploadObject,YKRequestConfig;

@interface YKRequestManager : NSObject

#pragma mark - Public Method

/// 设置基础网络配置,在AppDelegate设置此配置
/// @param config config
+ (void)setBaseConfig:(nullable void(^)(YKRequestConfig *configObj))config;

/// 获取网络状态
/// @param networkStatusBlock networkStatusBlock
+ (void)networkStatus:(YKNetworkStatusBlock)networkStatusBlock;

#pragma mark - Request Method
/** 只写了GET POST,其余的需要用到直接参照添加即可 */

/// POST请求
/// @param url 请求连接
/// @param parameters 参数
/// @param cacheType 缓存策略
/// @param completionHandler 请求完成回调
+ (void)requestPOSTWithURL:(NSString *)url
                parameters:(nullable NSDictionary *)parameters
                 cacheType:(YKCacheType)cacheType
         completionHandler:(YKHttpRequestResultBlock)completionHandler;

/// GET请求
/// @param url 请求连接
/// @param parameters 参数
/// @param cacheType 缓存策略
/// @param completionHandler 请求完成回调
+ (void)requestGETWithURL:(NSString *)url
               parameters:(nullable NSDictionary *)parameters
                cacheType:(YKCacheType)cacheType
        completionHandler:(YKHttpRequestResultBlock)completionHandler;

#pragma mark 文件上传

/// 单个上传文件
/// @param url 服务器地址
/// @param filePath 文件路径
/// @param parameters 参数
/// @param name 文件对应服务器上的字段
/// @param progress 进度
/// @param completionHandler 请求完成回调
+ (void)uploadFileWithURL:(NSString *)url
                 filePath:(NSString *)filePath
               parameters:(nullable NSDictionary *)parameters
                     name:(NSString *)name
                 progress:(nullable YKHttpRequestProgressBlock)progress
        completionHandler:(YKHttpRequestResultBlock)completionHandler;

/// 单张/多张图片上传
/// @param url 上传地址
/// @param images 图片数组
/// @param parameters 参数
/// @param name 文件对应服务器上的字段
/// @param fileName 文件名前缀,为空则用时间戳命名
/// @param imageScale 图片压缩倍率
/// @param imageType 图片类型
/// @param progress 进度
/// @param completionHandler 请求完成回调
+ (void)uploadImageWithURL:(NSString *)url
                    images:(NSArray<UIImage *> *)images
                parameters:(nullable NSDictionary *)parameters
                      name:(NSString *)name
                  fileName:(nullable NSString *)fileName
                imageScale:(CGFloat)imageScale
                 imageType:(NSString *)imageType
                  progress:(nullable YKHttpRequestProgressBlock)progress
         completionHandler:(YKHttpRequestResultBlock)completionHandler;

/// 多文件上传
/// @param url 服务器地址
/// @param uploadArray 上传文件数组
/// @param parameters 参数
/// @param progress 进度
/// @param completionHandler 请求完成回调
+ (void)uploadWithURL:(NSString *)url
          uploadArray:(NSMutableArray <YKUploadObject *> *)uploadArray
           parameters:(nullable NSDictionary *)parameters
             progress:(nullable YKHttpRequestProgressBlock)progress
    completionHandler:(YKHttpRequestResultBlock)completionHandler;

#pragma mark 下载文件
/// 下载文件
/// @param url 下载地址
/// @param resumeData 断点下载二进制数据
/// @param progress 进度
/// @param completionHandler 下载完成回调
+ (void)downloadWithURL:(NSString *)url
             resumeData:(nullable NSData *)resumeData
               progress:(YKHttpRequestProgressBlock)progress
      completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/// 开始下载
/// @param url 下载地址
/// @param progress 进度
/// @param completionHandler 下载完成回调
+ (void)downloadStartWithURL:(NSString *)url
                    progress:(YKHttpRequestProgressBlock)progress
           completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/// 暂停下载
/// @param url 下载地址
+ (void)downloadStopWithURL:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
