//
//  RLNetWorkTool.h
//  
//
//  Created by Rilma.Liu on 16/2/25.
//  Copyright © 2016年 Rilma.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^ProgressBlock)(NSProgress *progress);
typedef void(^SuccessBlock)(id result);
typedef void(^failureBlock)(NSError *error);
// 返回值类型
typedef NS_ENUM(NSUInteger, ResponseType) {
    ResponseTypeDATA,
    ResponseTypeJSON,
    ResponseTypeXML,
};
// body体类型
typedef NS_ENUM(NSUInteger, BodyType) {
    BodyTypeJSONString,
    BodyTypeNormol,
};


@interface RLNetWorkTool : NSObject

/**
 *  GET请求
 *
 *  @param url          url
 *  @param parameter    参数
 *  @param header       请求头
 *  @param responseType 返回值类型
 *  @param progress     进度
 *  @param success      成功
 *  @param failure      失败
 */
+ (void)getWithURL:(NSString *)url
         Parameter:(NSDictionary *)parameter
        HttpHeader:(NSDictionary<NSString *, NSString *> *)header
      ResponseType:(ResponseType)responseType
          Progress:(ProgressBlock)progress
           Success:(SuccessBlock)success
           Failure:(failureBlock)failure;

+ (void)postWithURL:(NSString *)url
               Body:(id)body
           BodyType:(BodyType)bodyType
         HttpHeader:(NSDictionary<NSString *, NSString *> *)header
       ResponseType:(ResponseType)responseType
           Progress:(ProgressBlock)progress
            Success:(SuccessBlock)success
            Failure:(failureBlock)failure;




@end
