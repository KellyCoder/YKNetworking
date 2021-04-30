//
//  YKNetworkObject.m
//  YKNetworking
//
//  Created by Kevin on 2021/4/29.
//

#import "YKNetworkObject.h"

@implementation YKNetworkObject

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

#pragma mark - Lazy Load
- (NSMutableArray<YKUploadObject *> *)uploadDatas {
    if (!_uploadDatas) {
        _uploadDatas = [[NSMutableArray alloc]init];
    }
    return _uploadDatas;
}

@end

#pragma mark - 基础配置类
@implementation YKRequestConfig
@end


#pragma mark - upload
@implementation YKUploadObject

+ (instancetype)formDataWithName:(NSString *)name fileData:(NSData *)fileData {
    YKUploadObject *formData = [[YKUploadObject alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileData:(NSData *)fileData {
    YKUploadObject *formData = [[YKUploadObject alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL {
    YKUploadObject *formData = [[YKUploadObject alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType fileURL:(NSURL *)fileURL {
    YKUploadObject *formData = [[YKUploadObject alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}

@end
