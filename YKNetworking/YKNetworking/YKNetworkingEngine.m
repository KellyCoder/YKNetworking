//
//  YKNetworkingEngine.m
//  YKNetworking
//
//  Created by Kevin on 2021/4/28.
//

#import "YKNetworkingEngine.h"
#import "AFNetworkActivityIndicatorManager.h"

// 默认请求超时时间
static NSTimeInterval const TimeoutIntervalDefault = 15.0;

@implementation YKNetworkingEngine

#pragma mark - init
+ (instancetype)sharedInstance{
    static YKNetworkingEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YKNetworkingEngine alloc]init];
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
        
        // 开始监测网络状态
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        // 打开请求状态旋转菊花
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        // 请求头 请求参数格式
        
    }
    return self;
}

#pragma mark - Public
- (void)networkStatus:(YKNetworkStatusBlock)networkStatusBlock{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
       
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatusBlock ? networkStatus(YKNetworkReachabilityStatusUnknown) : nil;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatusBlock ? networkStatus(YKNetworkReachabilityStatusNotReachable) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatusBlock ? networkStatus(YKNetworkReachabilityStatusWWAN) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatusBlock ? networkStatus(YKNetworkReachabilityStatusWiFi) : nil;
                break;
            default:
                break;
        }
    }];
}

@end
