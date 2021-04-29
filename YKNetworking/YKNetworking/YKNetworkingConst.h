//
//  YKNetworkingConst.h
//  YKNetworking
//
//  Created by Kevin on 2021/4/28.
//

#ifndef YKNetworkingConst_h
#define YKNetworkingConst_h

// 缓存策略类型
typedef NS_ENUM(NSUInteger, YKCacheType){
    /** 重新请求网络数据,不读写缓存 */
    YKCacheTypeRefresh = 0,
    /** 先获取缓存数据,再请求网络数据并缓存 */
    YKCacheTypeCache,
    /** 先获取网络数据并缓存，如果获取失败则从缓存中拿数据 */
    YKCacheTypeNetwork,
    /** 先获取缓存数据,再请求网络数据并缓存，若缓存数据与网络数据不一致Block将产生两次调用 */
    YKCacheTypeCacheAndNetwork
};

// HTTP请求类型
typedef NS_ENUM(NSUInteger, YKRequestMethodType){
    /** GET */
    YKRequestMethodTypeGET = 0,
    /** POST */
    YKRequestMethodTypePOST,
    /** PUT */
    YKRequestMethodTypePUT,
    /** PATCH */
    YKRequestMethodTypePATCH,
    /** Upload */
    YKRequestMethodTypeUpload,
    /** Download */
    YKRequestMethodTypeDownload,
    /** DELETE */
    YKRequestMethodTypeDELETE
};

//// 请求参数的格式
typedef NS_ENUM(NSUInteger, YKRequestSerializerType){
    /** 请求数据为JSON格式 */
    YKRequestSerializerTypeJSON,
    /** 请求数据为二进制格式 */
    YKRequestSerializerTypeHTTP
};


// 返回响应数据的格式.
typedef NS_ENUM(NSUInteger, YKResponseSerializerType) {
    /** 响应数据为JSON格式 */
    YKResponseSerializerTypeJSON,
    /** 响应数据为二进制格式 */
    YKResponseSerializerTypeHTTP
};

// 当前网络状态
typedef NS_ENUM(NSUInteger, YKNetworkReachabilityStatus) {
    /** 未知网络 */
    YKNetworkReachabilityStatusUnknown      = -1,
    /** 无网路 */
    YKNetworkReachabilityStatusNotReachable = 0,
    /** WWAN */
    YKNetworkReachabilityStatusWWAN         = 1,
    /** WiFi */
    YKNetworkReachabilityStatusWiFi         = 2
};

// 网络状态block
typedef void(^YKNetworkStatusBlock)(YKNetworkReachabilityStatus status);

// 网络请求结果回调block
typedef void(^YKHttpRequestResultBlock)(BOOL isSuccess, id _Nullable responseObject, NSError * _Nullable error);
 
// 网络请求结果成功回调block
typedef void(^YKHttpRequsetSuccessBlock)(NSURLSessionDataTask * _Nonnull dataTask,id _Nullable responseObject);

// 网络请求结果失败回调block
typedef void(^YKHttpRequsetFailBlock)(NSURLSessionDataTask * _Nonnull dataTask,NSError * _Nullable error);

// 进度回调block
typedef void(^YKHttpRequestProgressBlock)(NSProgress * _Nullable progress);



#endif /* YKNetworkingConst_h */
