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
