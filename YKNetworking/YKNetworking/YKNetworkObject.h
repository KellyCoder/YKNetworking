//
//  YKNetworkObject.h
//  YKNetworking
//
//  Created by Kevin on 2021/4/29.
//

#import <Foundation/Foundation.h>
#import "YKNetworkingConst.h"

NS_ASSUME_NONNULL_BEGIN

@class YKUploadObject;

@interface YKNetworkObject : NSObject

/** 上传数据 */
@property (nonatomic,strong,nullable) NSMutableArray<YKUploadObject *> *uploadDatas;


@end

#pragma mark - 基础配置类
@interface YKRequestConfig : NSObject

/** baseURL域名 */
@property (nonatomic, copy) NSString *baseServer;
/** 公共参数 */
@property (nonatomic, strong, nullable) NSDictionary *baseParameters;
/** 超时时间,默认15s */
@property (nonatomic) NSTimeInterval timeoutInterval;
/** 请求头 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *,NSString *> *headers;
/** 是否开启打印Log,默认NO */
@property (nonatomic) BOOL consoleLog;
/** 旋转菊花开关,默认开 */
@property (nonatomic) BOOL indicatorEnabled;
/** 请求参数类型 */
@property (nonatomic) YKRequestSerializerType requestSerializerType;
/** 响应数据类型 */
@property (nonatomic) YKResponseSerializerType responseSerializerType;

@end

#pragma mark - upload
@interface YKUploadObject : NSObject

/** 文件对应服务器上的字段 */
@property (nonatomic, copy) NSString *name;
/** 文件名 */
@property (nonatomic, copy) NSString *fileName;
/** mime类型,参考:http://www.iana.org/assignments/media-types/.
    例子:图片 png、jpeg、jpg
 */
@property (nonatomic, copy) NSString *mimeType;
/** 文件二进制数据 */
@property (nonatomic, strong, nullable) NSData *fileData;
/** 文件URL */
@property (nonatomic, strong, nullable) NSURL *fileURL;

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData;

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData;

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL;

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
