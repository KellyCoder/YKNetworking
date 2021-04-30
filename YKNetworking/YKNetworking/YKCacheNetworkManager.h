//
//  YKCacheNetworkManager.h
//  YKNetworking
//
//  Created by Kevin on 2021/4/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YKCacheNetworkManager : NSObject

+ (instancetype)sharedInstance;

/// 对应key是否存在缓存
/// @param key key
/// @param block block
- (void)containsObjectForKey:(NSString *)key
                   withBlock:(nullable void (^)(NSString *key , BOOL contains ))block;

/// 设置缓存数据
/// @param object object
/// @param key key
/// @param block block
- (void)setObject:(id<NSCoding>)object
           forKey:(NSString *)key
        withBlock:(void (^)(void))block;

/// 获取缓存数据
/// @param key key
/// @param block block
- (void)objectForKey:(NSString *)key
           withBlock:(void (^)(NSString *key, id <NSCoding> object))block;

/// 清空所有缓存
/// @param block block
- (void)removeAllObjectsWithBlock:(void (^)(void))block;

/// 清空缓存,带删除进度
/// @param progress 删除进度
/// @param end 结果block回调
- (void)removeAllObjectsWithProgressBlock:(nullable void (^) (int removedCount, int totalCount))progress
                                 endBlock:(nullable void (^) (BOOL error))end;

/// 删除指定key缓存
/// @param key key
/// @param block block
- (void)removeObjectForKey:(NSString *)key
                 withBlock:(nullable void (^)(NSString *key))block;

/// 获取缓存总大小,bytes
/// @param block block
- (void)getAllObjectCacheSizeBlock:(void(^)(NSInteger totalCount))block;

#pragma mark - 沙盒
/// 沙盒Home的文件目录
- (NSString *)homePath;

/// 沙盒Document的文件目录
- (NSString *)documentPath;

/// 沙盒Library的文件目录
- (NSString *)libraryPath;

/// 沙盒Library/Caches的文件目录
- (NSString *)cachesPath;

/// 沙盒tmp的文件目录
- (NSString *)tmpPath;

/// 沙盒自创建的YKKit文件目录,路径:Library/Caches/YKKit
- (NSString *)YKKitPath;

/// 下载路径
- (NSString *)downloadPath;

@end

NS_ASSUME_NONNULL_END
