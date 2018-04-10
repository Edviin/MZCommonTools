//
//  MZ_HTTPSessionManager.m
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import "MZ_HTTPSessionManager.h"

#define kTimeOutInterval 30 // 请求超时的时间
typedef void (^NetWorkSuccessBlock)(NSDictionary *dict); // 访问成功block
typedef void (^NetWorkErrorBlock)(NSError *error); // 访问失败block
@implementation MZ_HTTPSessionManager

+(MZ_HTTPSessionManager *)manager
{
    MZ_HTTPSessionManager *manager = [MZ_HTTPSessionManager manager];
    // 超时时间
    manager.requestSerializer.timeoutInterval = kTimeOutInterval;
    
    // 声明上传的是json格式的参数，需要你和后台约定好，不然会出现后台无法获取到你上传的参数问题
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传普通格式
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer]; // 上传JSON格式
    
    // 声明获取到的数据格式
    manager.responseSerializer = [AFHTTPResponseSerializer serializer]; // AFN不会解析,数据是data，需要自己解析
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer]; // AFN会JSON解析返回的数据
    // 个人建议还是自己解析的比较好，有时接口返回的数据不合格会报3840错误，大致是AFN无法解析返回来的数据
    return manager;
}

/**
 httpGet 请求
 
 @param request httpRequest
 @param completion 请求结果
 @return 请求任务
 */
-(NSURLSessionDataTask *)startGetWithRequset:(MZ_HttpRequest *)request  Completion:(void (^)(MZ_HttpResponse *, NSError *))completion{
    MZ_HTTPSessionManager *manager = [MZ_HTTPSessionManager manager];
    
    __weak  MZ_HTTPSessionManager  *sself = self;
    //    设置相关的请求头，通过requestSerializer来实现，可以根据自己的需求定义一个或者多个请求头，
    if (request.header) {
        for (NSString *key in request.header.allKeys) {
            [manager .responseSerializer setValue:key forKey:[request.header objectForKey:key]];
        }
    }
    return  [manager GET:request.url parameters:request.data progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         
         if ([(NSHTTPURLResponse *)task.response statusCode] != 200) {
             if (completion) {
                 NSError *error = [NSError errorWithDomain:request.url code:[(NSHTTPURLResponse *)task.response statusCode] userInfo:@{NSLocalizedDescriptionKey: [sself judgeStatus:[(NSHTTPURLResponse *)task.response statusCode]]}];
                 NSLog(@"***************请求失败  错误结果:%@",responseObject);
                 completion(nil, error);
             }
         }else{
             
             id findata = responseObject ;
          
             NSLog(@"***************请求成功 结果:%@",findata);
             MZ_HttpResponse *httpResponse = [[MZ_HttpResponse alloc] initWithHeader:[(NSHTTPURLResponse *)task.response allHeaderFields] Data:findata];
             completion(httpResponse, nil);
         }
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
         if (completion) {
             NSLog(@"%@",error);  //这里打印错误信息
             completion(nil, error);
         }
     }];
}
/**
 post 请求
 
 @param request httpRequest
 @param completion 请求结果
 @return 请求任务
 */
-(NSURLSessionDataTask *) startPostRequest:(MZ_HttpRequest *)request Completion:(void (^)(MZ_HttpResponse *, NSError *))completion{
    
    MZ_HTTPSessionManager *manager = [MZ_HTTPSessionManager manager];
    __weak  MZ_HTTPSessionManager  *sself = self;
    if (request.header) {
        for (NSString *key in request.header.allKeys) {
            [manager.responseSerializer setValue:key forKey:[request.header objectForKey:key]];
        }
    }

    return [manager POST:request.url parameters:request.data progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([(NSHTTPURLResponse *)task.response statusCode] != 200) {
            if (completion) {
                NSError *error = [NSError errorWithDomain:request.url code:[(NSHTTPURLResponse *)task.response statusCode] userInfo:@{NSLocalizedDescriptionKey: [sself judgeStatus:[(NSHTTPURLResponse *)task.response statusCode]]}];
                NSLog(@"***************请求完成  错误结果:%@",responseObject);
                completion(nil, error);
            }
        }else{
            id findata = responseObject;

            MZ_HttpResponse *httpResponse = [[MZ_HttpResponse alloc] initWithHeader:[(NSHTTPURLResponse *)task.response allHeaderFields] Data:findata];
            NSLog(@"***************请求完成结果:%@",findata);
            completion(httpResponse, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            NSLog(@"%@",error);  //这里打印错误信息
            completion(nil, error);
        }
    }];
}


/**
 上传图片
 
 @param request request
 @param progress 进度
 @param completion completion
 @return result
 */
-(NSURLSessionDataTask *)addUploadRequestWithRequest:(MZ_HttpImageRequest *)request Progress:(void (^)(NSProgress *))progress Completion:(void (^)(MZ_HttpResponse *, NSError *))completion{
    MZ_HTTPSessionManager *manager = [MZ_HTTPSessionManager manager];
    __weak  MZ_HTTPSessionManager  *sself = self;
    
    if (request.header) {
        for (NSString *key in request.header.allKeys) {
            [manager.responseSerializer setValue:key forKey:[request.header objectForKey:key]];
        }
    }

    return  [manager POST:request.url parameters:request.data constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (MZ_HttpImageData *imageData in request.imagesArr) {
            [formData appendPartWithFileData:imageData.data name:imageData.name fileName:imageData.fileName mimeType:@"image/png"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([(NSHTTPURLResponse *)task.response statusCode] != 200) {
            if (completion) {
                NSError *error = [NSError errorWithDomain:request.url code:[(NSHTTPURLResponse *)task.response statusCode] userInfo:@{NSLocalizedDescriptionKey: [sself judgeStatus:[(NSHTTPURLResponse *)task.response statusCode]]}];
                NSLog(@"***************请求完成  错误结果:%@",responseObject);
                completion(nil, error);
            }
        }else{
            id findata = responseObject;
            MZ_HttpResponse *httpResponse = [[MZ_HttpResponse alloc] initWithHeader:[(NSHTTPURLResponse *)task.response allHeaderFields] Data:findata];
            NSLog(@"***************请求完成结果:%@",findata);
            completion(httpResponse, nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {//上传失败
            NSLog(@"%@",error);  //这里打印错误信息
            completion(nil , error);
        }
        
    }];
    
}
/**
 判断请求回来的状态,是否可以继续传值
 
 @param statusCode 响应状态
 @return 是否正常
 */
-(NSString *) judgeStatus:(NSInteger) statusCode{
    NSString *errorMsg = @"请求错误，请稍后重试";
    switch (statusCode) {
        case 301:
            errorMsg = @"code:301  网站已经移向别处了";
            break;
        case 400:
            errorMsg = @"code:400  请求出现语法错误";
            break;
        case 404:
            errorMsg = @"code:404  无法找到指定的URL";
            break;
        case 403:
            errorMsg = @"code:403  请求资源不可用";
            break;
        case 500:
            errorMsg = @"code:500  服务器故障";
            break;
        default:
            errorMsg = @"网络错误，请稍后重试";
            break;
    }
    return errorMsg;
}

@end
