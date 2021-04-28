//
//  YKNetworkingEngine.h
//  YKNetworking
//
//  Created by Kevin on 2021/4/28.
//

#import <AFNetworking/AFNetworking.h>
#import "YKNetworkingConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface YKNetworkingEngine : AFHTTPSessionManager

+ (instancetype)sharedInstance;

/// 获取网络状态
/// @param networkStatus 网络状态
- (void)networkStatus:(YKNetworkStatusBlock)networkStatusBlock;

@end

NS_ASSUME_NONNULL_END
