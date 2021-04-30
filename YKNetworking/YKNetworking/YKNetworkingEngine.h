//
//  YKNetworkingEngine.h
//  YKNetworking
//
//  Created by Kevin on 2021/4/28.
//

#import <AFNetworking/AFNetworking.h>
#import "YKNetworkingConst.h"

NS_ASSUME_NONNULL_BEGIN

@class YKUploadObject,YKRequestConfig;

@interface YKNetworkingEngine : AFHTTPSessionManager

+ (instancetype)sharedInstance;

#pragma mark - Public Method

/// 设置基础配置
/// @param config config
- (void)setBaseConfig:(YKRequestConfig *)config;

/// 获取网络状态
/// @param networkStatusBlock 网络状态
- (void)networkStatus:(YKNetworkStatusBlock)networkStatusBlock;

#pragma mark - Request Method

/// 网络请求
/// @param method 请求方式
/// @param url 请求地址
/// @param parameters 请求参数
/// @param headers 请求header
/// @param cacheType 缓存策略
/// @param progress 进度回调
/// @param success 成功回调
/// @param failure 失败回调
- (void)requestHttpWithMethod:(YKRequestMethodType)method
                          url:(NSString *)url
                   parameters:(nullable NSDictionary *)parameters
                      headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                    cacheType:(YKCacheType)cacheType
                     progress:(nullable YKHttpRequestProgressBlock)progress
                      success:(nullable YKHttpRequsetSuccessBlock)success
                      failure:(nullable YKHttpRequsetFailBlock)failure;

#pragma mark 文件上传
/// 单个上传文件
/// @param url 服务器地址
/// @param filePath 文件路径
/// @param parameters 参数
/// @param headers headers
/// @param name 文件对应服务器上的字段
/// @param progress 进度
/// @param success 成功回调
/// @param failure 失败回调
- (NSURLSessionDataTask *)uploadFileWithURL:(NSString *)url
                                   filePath:(NSString *)filePath
                                 parameters:(nullable NSDictionary *)parameters
                                    headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                                       name:(NSString *)name
                                   progress:(nullable YKHttpRequestProgressBlock)progress
                                    success:(nullable YKHttpRequsetSuccessBlock)success
                                    failure:(nullable YKHttpRequsetFailBlock)failure;


/// 单张/多张图片上传
/// @param url 上传地址
/// @param images 图片数组
/// @param parameters 参数
/// @param headers header
/// @param name 文件对应服务器上的字段
/// @param fileName 文件名前缀,为空则用时间戳命名
/// @param imageScale 图片压缩倍率
/// @param imageType 图片类型
/// @param progress 进度
/// @param success 成功回调
/// @param failure 失败回调
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
                                     failure:(nullable YKHttpRequsetFailBlock)failure;

/// 多文件上传
/// @param url 服务器地址
/// @param uploadArray 上传文件数组
/// @param parameters 参数
/// @param headers header
/// @param progress 进度
/// @param success 成功回调
/// @param failure 失败回调
- (NSURLSessionDataTask *)uploadWithURL:(NSString *)url
                            uploadArray:(NSMutableArray <YKUploadObject *> *)uploadArray
                             parameters:(nullable NSDictionary *)parameters
                                headers:(nullable NSDictionary<NSString *,NSString *>*)headers
                               progress:(nullable YKHttpRequestProgressBlock)progress
                                success:(nullable YKHttpRequsetSuccessBlock)success
                                failure:(nullable YKHttpRequsetFailBlock)failure;

#pragma mark 下载文件
/// 下载文件
/// @param url 下载地址
/// @param resumeData 断点下载二进制数据
/// @param savePath 文件保存路径
/// @param progress 进度
/// @param completionHandler 下载完成回调
- (NSURLSessionDownloadTask *)downloadWithURL:(NSString *)url
                                   resumeData:(nullable NSData *)resumeData
                                     savePath:(NSString *)savePath
                                     progress:(YKHttpRequestProgressBlock)progress
                            completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;


#pragma mark - 取消请求
/// 取消所有请求
- (void)cancelAllRequest;

/// 取消指定网络请求
/// @param identifier taskId
- (void)cancelRequestByIdentifier:(NSUInteger)identifier;

#pragma mark - task管理

/// 设置task
/// @param object object
/// @param key url
- (void)setTaskObject:(id)object forKey:(NSString *)key;

/// 删除task
/// @param key url
- (void)removeTaskObjectForKey:(NSString *)key;

/// 获取对应task
/// @param key url
- (id)getTaskObjectForKey:(NSString *)key;

#pragma mark - AFHTTPSessionManager默认设置
/// 设置请求参数格式,default:JSON
/// @param requestSerializerType YKRequestSerializerType
- (void)setRequestSerializerConfig:(YKRequestSerializerType)requestSerializerType;

/// 设置响应数据格式,default:JSON
/// @param responseSerializerType YKResponseSerializerType
- (void)setResponseSerializerConfig:(YKResponseSerializerType)responseSerializerType;

/// 设置请求头
/// @param value value
/// @param field field
- (void)setHeaderValuer:(NSString *)value forHTTPHeaderField:(NSString *)field;

/// 配置自建证书
/// @param cerPath 证书路径
/// @param validatesDomainName 是否验证域名,default:YES,
- (void)setSecurityPolicyWithCerPath:(NSString *)cerPath validatesDomainName:(BOOL)validatesDomainName;

@end

NS_ASSUME_NONNULL_END
