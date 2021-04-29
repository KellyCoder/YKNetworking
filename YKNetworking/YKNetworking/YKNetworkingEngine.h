//
//  YKNetworkingEngine.h
//  YKNetworking
//
//  Created by Kevin on 2021/4/28.
//

#import <AFNetworking/AFNetworking.h>
#import "YKNetworkingConst.h"

NS_ASSUME_NONNULL_BEGIN

@class YKUploadObject;

@interface YKNetworkingEngine : AFHTTPSessionManager

/** 根路径 */
@property (nonatomic,copy) NSString *baseUrl;
/** 公共基础参数 */
@property (nonatomic,copy) NSDictionary *baseParameters;
/** 旋转菊花开关,默认开 */
@property (nonatomic) BOOL IndicatorEnabled;

+ (instancetype)sharedInstance;

#pragma mark - Public Method
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
- (void)downloadWithURL:(NSString *)url
             resumeData:(NSData *)resumeData
               savePath:(NSString *)savePath
               progress:(YKHttpRequestProgressBlock)progress
      completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler;

/// 取消所有请求
- (void)cancelAllRequest;

#pragma mark - AFHTTPSessionManager默认设置

/// 设置请求超时时间,default:15s
/// @param timeoutInterval timeoutInterval
- (void)setRequestTimeoutInterval:(NSTimeInterval)timeoutInterval;

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

/// 设置请求头
/// @param header header
- (void)setHeader:(NSDictionary *)header;

@end

NS_ASSUME_NONNULL_END
