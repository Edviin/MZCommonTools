//
//  MZ_HttpCoreManager.m
//  MZCommonTool
//
//  Created by MZ on 2018/4/10.
//  Copyright © 2018年 MZ. All rights reserved.
//

#import "MZ_HttpCoreManager.h"
#import "MZ_HttpRequest.h"
#import "MZ_HTTPSessionManager.h"
#import "MZObject.h"
static id handleSerializeJsonObject(Class resultClass, id jsonObject) {
    if([resultClass isSubclassOfClass:[MZObject class]]) {
        if([jsonObject isKindOfClass:[NSDictionary class]]) {
            return [[resultClass class] serializeWithJsonObject:jsonObject];
        }
        
        if([jsonObject isKindOfClass:NSArray.class]) {
            return [[resultClass class] serializeWithJsonObjects:jsonObject];
        }
    }
    
    return jsonObject;
}

static NSString* Domain = @"MZ_RacNetWork";

typedef void (^MZCoreManagerRestTaskCompletion)(id __nullable retObject, NSError * __nullable error);

@interface MZ_HttpCoreManager ()
//全局接口错误处理回调Block
@property (nonatomic, assign, readwrite, nullable) MZCoreManagerRestTaskGlobalErrorHandler globalErrorHandler;
//全局接口处理回调Block
@property (nonatomic, assign, readwrite, nullable) MZCoreManagerRestTaskGlobalCompletionHandler globalCompletionHandler;

@end
@implementation MZ_HttpCoreManager
+ (instancetype) sharedInstance {
    static MZ_HttpCoreManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MZ_HttpCoreManager alloc] init];
    });
    return manager;
}
- (instancetype)init {
    
    if(self = [super init]) {
        _host = [kDCHost_Rest_Master copy];
    }
    
    return self;
}
- (void)setGlobalErrorHandlerWithHandler:(MZCoreManagerRestTaskGlobalErrorHandler)handler {
    
    self.globalErrorHandler = handler;
}

- (void)setGlobalCompletionHandlerWithHandler:(MZCoreManagerRestTaskGlobalCompletionHandler)handler {
    
    self.globalCompletionHandler = handler;
}

-(NSURLSessionDataTask *)postWithHttRequest:(NSDictionary *)data andAPi:(NSString *)api   ResultClass:(Class)resultClass  Completion:( MZCoreManagerRestTaskCompletion)completion;{
    NSString * postUrl = [NSString stringWithFormat:@"%@%@",_host,api];
    
    MZ_HttpRequest *requset = [[MZ_HttpRequest alloc]initWithURL:postUrl Header:nil Data:data ];
    MZ_HTTPSessionManager *manager = [[MZ_HTTPSessionManager alloc]init];
    
    MZ_HttpRequest *newRequest =  [MZ_HttpRequest copyWithRequest:requset];
    
    return [manager   startPostRequest:newRequest Completion:^(MZ_HttpResponse *response, NSError *error) {
        id retObject = nil;
        NSError * retError = nil;
        
        if(error) {
            retError = error;
        }else{
            __block id<MZ_Object> retObject1 = handleSerializeJsonObject(resultClass, response.data);
            retObject = retObject1;
        }
        if(retError && self.globalErrorHandler) {
            BOOL handled = self.globalErrorHandler(retObject, retError);
            if(handled) return;
        }
        if(self.globalCompletionHandler) {
            BOOL handled = self.globalCompletionHandler(retObject, retError);
            if(handled) return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(completion) {
                completion(retObject, retError);
            }
        });
    }];
}

-(NSURLSessionDataTask *)GetWithHttRequest:(NSDictionary *)data andAPi:(NSString *)api  ResultClass:(Class)resultClass  Completion:( MZCoreManagerRestTaskCompletion)completion;{
    NSString * postUrl = [NSString stringWithFormat:@"%@%@",_host,api];
    
    MZ_HttpRequest *requset = [[MZ_HttpRequest alloc]initWithURL:postUrl Header:nil Data:data ];
    MZ_HTTPSessionManager *manager = [[MZ_HTTPSessionManager alloc]init];
    
    MZ_HttpRequest *newRequest =  [MZ_HttpRequest copyWithRequest:requset];
    
    return [manager  startGetWithRequset:newRequest Completion:^(MZ_HttpResponse *response, NSError *error) {
        id retObject = nil;
        NSError * retError = nil;
        
        if(error) {
            retError = error;
        }else{
            __block id<MZ_Object> retObject1 = handleSerializeJsonObject(resultClass, response.data);
            retObject = retObject1;
        }

        if(retError && self.globalErrorHandler) {
            BOOL handled = self.globalErrorHandler(retObject, retError);
            if(handled) return;
        }
        if(self.globalCompletionHandler) {
            BOOL handled = self.globalCompletionHandler(retObject, retError);
            if(handled) return;
        }
        if(completion) {
            completion(retObject, retError);
        }
    }];
}
@end
