//
//  MZ_HTTPSessionManager.h
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "MZ_HttpRequest.h"
#import "MZ_HttpResponse.h"
#import "MZ_HttpImageRequest.h"
@interface MZ_HTTPSessionManager : AFHTTPSessionManager
/**
 httpGet 请求
 
 @param request httpRequest
 @param completion 请求结果
 @return 请求任务
 */
-(NSURLSessionDataTask *)startGetWithRequset:(MZ_HttpRequest *)request  Completion:(void(^)(MZ_HttpResponse *response, NSError *error)) completion;
/**
 post 请求
 
 @param request httpRequest
 @param completion 请求结果
 @return 请求任务
 */
-(NSURLSessionDataTask *) startPostRequest:(MZ_HttpRequest *)request Completion:(void (^)(MZ_HttpResponse *response, NSError *error))completion;
/**
 上传图片
 
 @param request request
 @param progress 进度
 @param completion completion
 @return 请求任务
 */
-(NSURLSessionDataTask *) addUploadRequestWithRequest:(MZ_HttpImageRequest *)request Progress:(void (^)(NSProgress * progress))progress Completion:(void (^)(MZ_HttpResponse *response, NSError *err))completion;
@end
