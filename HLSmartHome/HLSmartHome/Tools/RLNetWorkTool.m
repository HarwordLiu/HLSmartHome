//
//  RLNetWorkTool.m
//
//
//  Created by Rilma.Liu on 16/2/25.
//  Copyright © 2016年 Rilma.Liu. All rights reserved.
//

#import "RLNetWorkTool.h"

@implementation RLNetWorkTool

+ (void)getWithURL:(NSString *)url
         Parameter:(NSDictionary *)parameter
        HttpHeader:(NSDictionary<NSString *, NSString *> *)header
      ResponseType:(ResponseType)responseType
          Progress:(ProgressBlock)progress
           Success:(SuccessBlock)success
           Failure:(failureBlock)failure {
    // 1.初始化sessionManager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 2.处理请求头
    for (NSString *key in header.allKeys) {
        [manager.requestSerializer setValue:header[key] forHTTPHeaderField:key];
    }
    // 3.处理返回值类型
    switch (responseType) {
        case ResponseTypeDATA: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        case ResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case ResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
    }
    
    // 4.设置返回值支持的文本类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", @"text/xml",nil]];
    
    // 5.get请求
    [manager GET:url parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
}

+ (void)postWithURL:(NSString *)url
               Body:(id)body
           BodyType:(BodyType)bodyType
         HttpHeader:(NSDictionary<NSString *, NSString *> *)header
       ResponseType:(ResponseType)responseType
           Progress:(ProgressBlock)progress
            Success:(SuccessBlock)success
            Failure:(failureBlock)failure {
    // 1.初始化sessionManager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 2.处理请求头
    for (NSString *key in header.allKeys) {
        [manager.requestSerializer setValue:header[key] forHTTPHeaderField:key];
    }
    // 3.处理返回值类型
    switch (responseType) {
        case ResponseTypeDATA: {
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        case ResponseTypeJSON: {
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case ResponseTypeXML: {
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
            break;
        }
    }
    
    // 4.设置返回值支持的文本类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil]];
    // 5.处理Body类型
    switch (bodyType) {
        case BodyTypeJSONString: {
            [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
                return parameters;
            }];
            break;
        }
        case BodyTypeNormol: {
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        }
    }
    // 6.post请求
    [manager POST:url parameters:body progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];

}



















@end
