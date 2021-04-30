//
//  YKNetworkTool.h
//  YKNetworking
//
//  Created by Kevin on 2021/4/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YKNetworkTool : NSObject

+ (void)logSocket:(NSArray *)logArray;

/// 拼接URL和参数
/// @param params 参数
/// @param urlLink url
+ (NSString *)connectWithparams:(NSMutableDictionary *)params url:(NSString *)urlLink;

@end

NS_ASSUME_NONNULL_END
