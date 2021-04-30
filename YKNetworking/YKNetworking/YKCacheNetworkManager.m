//
//  YKCacheNetworkManager.m
//  YKNetworking
//
//  Created by Kevin on 2021/4/29.
//

#import "YKCacheNetworkManager.h"
#import <YYCache/YYCache.h>

static NSString * const YKNetworkCache = @"YKNetworkCache";
static NSString * const YKPathSpace = @"YKKit";
static NSString * const YKDownloadPath = @"YKDownload";


@interface YKCacheNetworkManager ()

/** 缓存对象 */
@property (nonatomic,strong) YYCache *dataCache;

@end

@implementation YKCacheNetworkManager

#pragma mark - init
+ (instancetype)sharedInstance{
    static YKCacheNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YKCacheNetworkManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.dataCache = [YYCache cacheWithName:YKNetworkCache];
        
    }
    return self;
}

#pragma mark - Public
- (void)containsObjectForKey:(NSString *)key
                   withBlock:(nullable void (^)(NSString *key , BOOL contains ))block{
    [self.dataCache containsObjectForKey:key withBlock:block];
}

- (void)setObject:(id<NSCoding>)object
           forKey:(NSString *)key
        withBlock:(void (^)(void))block{
    [self.dataCache setObject:object forKey:key withBlock:block];
}

- (void)objectForKey:(NSString *)key
           withBlock:(void (^)(NSString *key, id <NSCoding> object))block{
    [self.dataCache objectForKey:key withBlock:block];
}

- (void)removeAllObjectsWithBlock:(void (^)(void))block{
    [self.dataCache removeAllObjectsWithBlock:block];
    
}

- (void)removeAllObjectsWithProgressBlock:(nullable void (^) (int removedCount, int totalCount))progress
                                 endBlock:(nullable void (^) (BOOL error))end{
    [self.dataCache removeAllObjectsWithProgressBlock:progress endBlock:end];
}

- (void)removeObjectForKey:(NSString *)key
                 withBlock:(nullable void (^)(NSString *key))block{
    [self.dataCache removeObjectForKey:key withBlock:block];
}

- (void)getAllObjectCacheSizeBlock:(void(^)(NSInteger totalCount))block{
    [self.dataCache.diskCache totalCountWithBlock:block];
}

#pragma mark - 沙盒
- (NSString *)homePath{
    return NSHomeDirectory();
}

- (NSString *)documentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)libraryPath{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)cachesPath{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)tmpPath{
    return NSTemporaryDirectory();
}

- (NSString *)YKKitPath{
    NSString *path = [[self cachesPath] stringByAppendingPathComponent:YKPathSpace];
    [self createDirectoryAtPath:path];
    return path;
}

- (NSString *)downloadPath{
    NSString *path = [[[self cachesPath] stringByAppendingPathComponent:YKPathSpace] stringByAppendingPathComponent:YKDownloadPath];
    [self createDirectoryAtPath:path];
    
    return path;
}

- (void)createDirectoryAtPath:(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//        NSLog(@" ========================== >>> 创建文件夹: %@ ", path);
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    } else {
//        NSLog(@" ========================== >>> 文件夹已存在: %@ ", path);
    }
}

@end
